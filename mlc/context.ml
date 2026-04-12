package mlc.context

const BREAKABLE_KIND_LOOP = "loop"
const BREAKABLE_KIND_SWITCH = "switch"

const BREAKABLE_CTX_DEFAULT_CONTINUE_LABEL = void
const BREAKABLE_CTX_DEFAULT_BREAK_DEPTH = 0
const BREAKABLE_CTX_DEFAULT_CONTINUE_DEPTH = 0

struct LoopCtx
  break_label,
  continue_label,
end struct

struct BreakableCtx
  kind,
  break_label,
  continue_label,
  break_depth,
  continue_depth,
end struct

function newLoopCtx(break_label, continue_label)
  return LoopCtx(break_label, continue_label)
end function

function _normalizeBreakableCtx(kind, break_label, continue_label, break_depth, continue_depth)
  // Python parity: continue_label is optional, depths default to 0.
  if typeof(continue_label) != "string" and typeof(continue_label) != "void" then
    continue_label = BREAKABLE_CTX_DEFAULT_CONTINUE_LABEL
  end if
  if typeof(break_depth) != "int" or break_depth < 0 then
    break_depth = BREAKABLE_CTX_DEFAULT_BREAK_DEPTH
  end if
  if typeof(continue_depth) != "int" or continue_depth < 0 then
    continue_depth = BREAKABLE_CTX_DEFAULT_CONTINUE_DEPTH
  end if
  return BreakableCtx(kind, break_label, continue_label, break_depth, continue_depth)
end function

function newBreakableCtx(kind, break_label, continue_label, break_depth, continue_depth)
  return _normalizeBreakableCtx(kind, break_label, continue_label, break_depth, continue_depth)
end function
