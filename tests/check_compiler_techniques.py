"""Integration gate for the paired compiler optimizations on Windows."""
from __future__ import annotations

import argparse
import hashlib
import subprocess
import sys
import tempfile
from pathlib import Path


def run(command: list[str], cwd: Path) -> str:
    result = subprocess.run(command, cwd=cwd, text=True, capture_output=True,
                            encoding='utf-8', errors='replace', timeout=180)
    if result.returncode:
        raise AssertionError(f'{command!r}: {result.returncode}\n{result.stdout}\n{result.stderr}')
    return result.stdout


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ml-compiler', type=Path, required=True)
    parser.add_argument('--python-repo', type=Path, required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    py = [sys.executable, str((args.python_repo / 'mlc_win64.py').resolve())]
    ml = [str(args.ml_compiler.resolve())]

    with tempfile.TemporaryDirectory(prefix='compiler-techniques-', dir=root / 'build') as tmp:
        work = Path(tmp)
        source = root / 'tests' / 'compiler_techniques.ml'
        outputs: list[Path] = []
        for name, compiler, flags in (
            ('python', py, []), ('ml-mono', ml, ['--no-object-pipeline']),
            ('ml-mlo', ml, ['--object-pipeline'])):
            image = work / f'{name}.exe'
            run([*compiler, str(source), str(image), '-I', str(root), *flags], root)
            assert run([str(image)], root).splitlines() == ['abc', 'ac', 'a42c', '336', '28', '1300']
            outputs.append(image)
        assert len({digest(path) for path in outputs}) == 1, 'default byte parity'

        for name, compiler in (('python', py), ('ml', ml)):
            cache = work / f'cache-{name}'
            for repeat in range(2):
                image = work / f'{name}-cache-{repeat}.exe'
                run([*compiler, str(source), str(image), '-I', str(root),
                     '--incremental-cache', str(cache)], root)
                assert digest(image) == digest(outputs[0]), 'incremental byte parity'

        # Exercise the lexer cache itself: the Python side uses it only for
        # larger sources, while the small fixture above covers function reuse.
        large = work / 'large.ml'
        large.write_text(source.read_text(encoding='utf-8') + '\n// cache filler\n' * 5000,
                         encoding='utf-8')
        for name, compiler in (('python', py), ('ml', ml)):
            cache = work / f'large-cache-{name}'
            images = []
            for repeat in range(2):
                image = work / f'{name}-large-{repeat}.exe'
                run([*compiler, str(large), str(image), '-I', str(root),
                     '--incremental-cache', str(cache)], root)
                images.append(image)
            assert digest(images[0]) == digest(images[1]), 'lexer cache byte parity'
            token_files = list(cache.rglob('*.mtok'))
            assert token_files, 'lexer cache record written'
            token_files[0].write_bytes(b'damaged cache record')
            recovered = work / f'{name}-large-recovered.exe'
            run([*compiler, str(large), str(recovered), '-I', str(root),
                 '--incremental-cache', str(cache)], root)
            assert digest(recovered) == digest(images[0]), 'corrupt lexer cache fallback'

        hot = 'function hot(x as int) returns int\n  return x + 1\nend function\n'
        body = 'function main(args)\n  total = 0\n  for i = 0 to 999\n'
        body += '    total += hot(i)\n' * 12
        body += '  end for\n  print total\n'
        training = work / 'training.ml'
        training.write_text(hot + body + '  for each stat in callStats()\n'
                            '    print "[call-profile] name=" + stat.name + " calls=" + stat.calls\n'
                            '  end for\nend function\n', encoding='utf-8')
        profiles: list[Path] = []
        for name, compiler in (('python', py), ('ml', ml)):
            image = work / f'{name}-training.exe'
            run([*compiler, str(training), str(image), '--profile-calls'], root)
            profiles.append(image)
        assert digest(profiles[0]) == digest(profiles[1]), 'profile byte parity'
        training_output = run([str(profiles[0])], root)
        assert '[call-profile] name=hot calls=12000' in training_output
        profile = work / 'calls.txt'
        profile.write_text(training_output, encoding='utf-8')

        production = work / 'production.ml'
        production.write_text(hot + body + 'end function\n', encoding='utf-8')
        pgo_images: list[Path] = []
        for name, compiler in (('python', py), ('ml', ml)):
            image = work / f'{name}-pgo.exe'
            run([*compiler, str(production), str(image), '--pgo-profile', str(profile)], root)
            assert run([str(image)], root).strip() == '6006000'
            pgo_images.append(image)
        assert digest(pgo_images[0]) == digest(pgo_images[1]), 'PGO byte parity'
        default = work / 'production-default.exe'
        run([*py, str(production), str(default)], root)
        assert digest(default) != digest(pgo_images[0]), 'PGO changed the inline budget'

    print('PASS compiler techniques: semantics, cache, profile, PGO, and byte parity')


if __name__ == '__main__':
    main()
