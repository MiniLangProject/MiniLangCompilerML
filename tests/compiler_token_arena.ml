import mlc.minilang_parser as parser

function fail(message)
  print "[FAIL] compiler token arena: " + message
  return 1
end function

function main(args)
  tokens = parser.tokenize("alpha = alpha + beta\n")
  if typeof(tokens) != "struct" then return fail("tokenize result") end if
  if typeof(tokens.kinds) != "bytes" or typeof(tokens.value_ids) != "bytes" or typeof(tokens.positions) != "bytes" then return fail("packed columns") end if
  if tokens.count != 7 or len(tokens.value_ids) != tokens.cap * 4 or len(tokens.positions) != tokens.cap * 4 then return fail("column dimensions") end if

  alpha0 = parser._token_u32_read(tokens.value_ids, 0)
  alpha1 = parser._token_u32_read(tokens.value_ids, 2)
  beta = parser._token_u32_read(tokens.value_ids, 4)
  newline = parser._token_u32_read(tokens.value_ids, 5)
  if alpha0 <= 0 or alpha0 != alpha1 then return fail("module-local identifier reuse") end if
  if beta <= 0 or beta == alpha0 then return fail("distinct symbol ids") end if
  if newline != 0 then return fail("fixed token value elision") end if
  if parser._token_u32_read(tokens.positions, 2) != 8 then return fail("packed source position") end if

  print "[OK] packed token columns and module-local symbol ids"
  return 0
end function
