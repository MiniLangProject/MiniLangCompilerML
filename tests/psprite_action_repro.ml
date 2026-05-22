struct pspdef_t
  state
  tics
  sx
  sy
end struct

struct player_t
  psprites
end struct

struct action_t
  acp1
  acp2
end struct

struct state_t
  tics
  action
end struct

ps_weapon = 0
WEAPONBOTTOM = 8388608
WEAPONTOP = 2097152

function A_Raise(player, psp)
  print "A_Raise psp type"
  print typeof(psp)
  psp.sy = WEAPONTOP
end function

function make_player()
  return player_t([pspdef_t(void, 0, 0, 0)])
end function

function set_psprite(player, state)
  psp = player.psprites[ps_weapon]
  psp.state = state
  psp.tics = state.tics
  if typeof(state.action.acp2) == "function" then
    state.action.acp2(player, psp)
  end if
  player.psprites[ps_weapon] = psp
end function

p = make_player()
st = state_t(1, action_t(void, A_Raise))
set_psprite(p, st)
print p.psprites[0].sy
