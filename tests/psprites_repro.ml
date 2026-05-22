struct pspdef_t
  state
  tics
  sx
  sy
end struct

struct player_t
  psprites
end struct

ps_weapon = 0
ps_flash = 1
NUMPSPRITES = 2
WEAPONBOTTOM = 8388608

function make_player()
  ps = []
  i = 0
  while i < NUMPSPRITES
    ps = ps + [pspdef_t(void, 0, 0, 0)]
    i = i + 1
  end while
  return player_t(ps)
end function

function ensure_psprites(player)
  if player.psprites is void then
    player.psprites = []
  end if
  i = len(player.psprites)
  while i < NUMPSPRITES
    player.psprites = player.psprites + [pspdef_t(void, 0, 0, 0)]
    i = i + 1
  end while
end function

function bring_up(player)
  ensure_psprites(player)
  player.psprites[ps_weapon].sy = WEAPONBOTTOM
end function

function move_psprites(player)
  ensure_psprites(player)
  player.psprites[ps_flash].sy = player.psprites[ps_weapon].sy
end function

p = make_player()
print typeof(p.psprites)
print len(p.psprites)
print typeof(p.psprites[0])
print p.psprites[0].sy
bring_up(p)
print typeof(p.psprites[0])
print p.psprites[0].sy
move_psprites(p)
print p.psprites[1].sy
