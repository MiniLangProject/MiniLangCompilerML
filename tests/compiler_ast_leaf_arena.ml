import mlc.minilang_parser as parser
import mlc.tools as t

function fail(message)
  print "[FAIL] compiler AST leaf arena: " + message
  return 1
end function

function main(args)
  t.ast_leaf_reset()
  expr = parser.parse_expression("alpha + 41", "arena-test.ml")
  if t.ast_is_bin(expr) == false or t.ast_kind(expr) != "Bin" or t.ast_op(expr) != "+" then return fail("binary NodeId") end if
  if t.ast_is_leaf(t.ast_left(expr)) == false or t.ast_kind(t.ast_left(expr)) != "Var" then return fail("variable NodeId") end if
  if t.ast_name(t.ast_left(expr)) != "alpha" then return fail("variable symbol") end if
  if t.ast_is_leaf(t.ast_right(expr)) == false or t.ast_kind(t.ast_right(expr)) != "Num" then return fail("number NodeId") end if
  if t.ast_value(t.ast_right(expr)) != 41 then return fail("number payload") end if
  if t.ast_pos(t.ast_right(expr)) != 8 or t.ast_filename(t.ast_right(expr)) != "arena-test.ml" then return fail("packed location") end if

  expr2 = parser.parse_expression("alpha", "arena-test.ml")
  stats = t.ast_leaf_stats()
  if t.ast_name(expr2) != "alpha" or stats[2] != 2 or stats[3] != 1 then return fail("symbol/operator/file interning") end if
  if stats[5] != 1 then return fail("binary arena count") end if
  print "[OK] compact AST leaf/binary NodeIds, symbols and locations"
  return 0
end function
