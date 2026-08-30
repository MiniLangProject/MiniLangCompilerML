import mlc.minilang_parser as parser
import std.string as s

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

  slash = decode(bytes([92]))
  raw_escapes = "A" + slash + "n" + slash + "x42" + slash + "u00e9" + slash + "U0001F642" + slash + "q"
  decoded_escapes = parser._decode_string_raw(raw_escapes, 0)
  if decoded_escapes != "A\nB\u00e9\U0001F642q" then return fail("linear escape decoding semantics") end if

  // A large literal-shaped input guards against restoring per-character
  // immutable concatenation in the parser's escape decoder.
  long_raw = s.repeat("x", 131072)
  long_decoded = parser._decode_string_raw(long_raw, 0)
  if long_decoded != long_raw then return fail("linear long-string decoding") end if

  print "[OK] packed token columns, symbol ids and linear string decoding"
  return 0
end function
