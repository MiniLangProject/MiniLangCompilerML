# MiniLang: pathologisch langsame Codegenerierung einer String-Verkettung

## Kurzfassung

MiniLang Compiler 1.2.11 kompiliert eine lange, linksassoziative `+`-Kette mit
Werten unterschiedlicher Typen in Hollowkeep extrem langsam. Der Compiler
verbraucht dabei CPU und meldet keinen Fehler. Es handelt sich nach den
bisherigen Messungen nicht um einen Deadlock. Wird dieselbe Berechnung in kurze
Zuweisungen aufgeteilt, fällt die Codegenerierungszeit des betroffenen
Funktionspakets von rund 59,5 Sekunden auf 0,25 Sekunden.

## Fundstelle

- Projekt: `C:\Users\nilsk\Desktop\DungeonCrawler`
- Datei: `src/ui/menu.ml`
- Funktion: `hollowkeep.ui.menu.draw`
- Ausdruck: die Berechnung von `key` aus `state.page`, weiteren Menüwerten,
  `settings.serialize(state.draft)`, `loc.revision` und `quitFlow.phase`
- Compiler: `C:\Users\nilsk\Desktop\MiniLangCompilerOptimization\MiniLangCompilerML\build\mlc_win64.exe`, Version 1.2.11

Der Originalausdruck beginnt so:

```minilang
key = state.page+":"+state.selected+":"+state.started+":"+state.message+":"+selectedSaveSlot+":"+saveSlotScroll+":"+validSaveCount+":"+creationState.classId+":"+creationState.heroName+":"+creationState.editing+":"+settings.serialize(state.draft)+":"+loc.revision+":"+quitFlow.phase
```

## Reproduktion

Aus `C:\Users\nilsk\Desktop\DungeonCrawler` in PowerShell:

```powershell
& '..\MiniLangCompilerOptimization\MiniLangCompilerML\build\mlc_win64.exe' `
  'src/ui/menu.ml' 'build/menu-repro.exe' `
  -I '..\MiniLangCompilerOptimization\MiniPixels\src' `
  -I '..\MiniLangCompilerOptimization\MiniLangCompilerML' `
  -I 'build/generated' `
  --target windows-x64 --object-pipeline --profile-compiler-batches
```

Im Profil ist das Paket `object_function_batch=19` mit
`first=hollowkeep.ui.menu.draw` auffällig. Beim vollständigen Hollowkeep-Build
werden die Objekte bis `237_hollowkeep.ui.menu.mlo` ausgegeben; das folgende
Paket hat in mehreren Versuchen länger als 30 Minuten keine neue Ausgabe
erzeugt, während der Compiler weiter CPU-Zeit verbrauchte. Der vollständige
Build wurde deshalb manuell beendet; das ist kein vom Compiler gemeldeter
Quellcodefehler.

## Messungen

Alle Paketwerte stammen aus isolierten Builds von `src/ui/menu.ml` mit
`--object-pipeline --profile-compiler-batches`. Die Änderungen an der
Hollowkeep-Quelldatei waren nur vorübergehende Diagnosevarianten und wurden
anschließend vollständig zurückgenommen.

| Variante der `key`-Berechnung | Codegen des Pakets | Gesamter isolierter Build |
| --- | ---: | ---: |
| Originalausdruck | 59.485 ms | 77.125 ms |
| `settings.serialize(...)` durch Konstante ersetzt, lange Kette beibehalten | 80.578 ms | 97.875 ms |
| Leeren String vorangestellt (`""+state.page+...`) | 41.125 ms | 58.610 ms |
| Identische Verkettung in kurze `key = key + ...`-Zuweisungen aufgeteilt | **219 ms** | **16.203 ms** |
| Gesamten Ausdruck durch Konstante ersetzt | 157 ms | 17.578 ms |

Ein isolierter Build des Originalmoduls mit `--no-object-pipeline` benötigte
insgesamt 102.547 ms. Der Engpass ist also nicht ausschließlich in der
Objekt-Pipeline. Der `settings.serialize`-Aufruf allein erklärt ihn ebenfalls
nicht. Das Voranstellen eines statischen Strings hilft etwas, beseitigt ihn
aber nicht.

## Vermutete Untersuchungsstellen

Dies ist eine **Hypothese**, noch keine nachgewiesene interne Ursache: Bei
langen `+`-Bäumen könnten Typ-/Operatoranalyse oder Codegenerierung dieselben
linken Teilbäume wiederholt untersuchen. Zu prüfen sind insbesondere
`_opt_expr_known_type`, `_emit_expr_bin` und
`_try_emit_left_string_concat_chain` in
`mlc/codegen/codegen_expr.ml`. Der schnelle Pfad für String-Ketten scheint
hier nicht ausreichend zu greifen, vor allem wenn der erste Operand kein
statisch bekannter String ist.

## Erwartetes Ergebnis / Akzeptanzkriterien

1. Die Ursache im Compiler bestimmen und dort beheben, nicht nur den
   Hollowkeep-Ausdruck umschreiben.
2. Einen kleinen Regressionstest für eine lange linksassoziative
   gemischttypige String-Verkettung hinzufügen; beide Compiler-Pipelines
   prüfen.
3. Auswertungsreihenfolge, Fehlerweitergabe, String-Konvertierung und
   gegebenenfalls überladene Operatoren unverändert lassen.
4. Vorher-/Nachher-Zeiten des Regressionstests und des isolierten
   Hollowkeep-Menü-Builds messen. Das betroffene Funktionspaket sollte nicht
   mehr um Größenordnungen langsamer sein als die aufgeteilte Variante.
5. Danach den vollständigen Hollowkeep-Build durchführen und prüfen, dass
   die neue EXE den aktuellen Source-Hash enthält.

Bis zu einem Compiler-Fix ist die Aufteilung der `key`-Berechnung in kurze
Zuweisungen ein belegter Workaround; sie ist im Hollowkeep-Quelltext derzeit
**nicht** übernommen.
