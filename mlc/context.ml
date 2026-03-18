package mlc.context

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

function newBreakableCtx(kind, break_label, continue_label, break_depth, continue_depth)
  return BreakableCtx(kind, break_label, continue_label, break_depth, continue_depth)
end function
