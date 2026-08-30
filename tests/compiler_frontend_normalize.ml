// Regression coverage for the capacity-backed frontend source normalizer.
import mlc.frontend as frontend

function assert_equal(actual, expected, label)
  if actual == expected then return true end if
  print "[FAIL] " + label
  print "  expected=" + expected
  print "  actual=" + actual
  return false
end function

function main(args)
  unchanged = "print \"h\u00e9llo\"\n"
  if not assert_equal(frontend.normalize_code_for_tokenizer(unchanged), unchanged, "normalizer no-op UTF-8 path") then return 1 end if

  source = "x-1\r\n10-2\r\ncall()-3\r\n// comment-4\r\ns = \"text-5\\\"-6\"\r\n-7\r\narr[0]-8\r\n"
  expected = "x - 1\n10 - 2\ncall() - 3\n// comment-4\ns = \"text-5\\\"-6\"\n-7\narr[0] - 8\n"
  if not assert_equal(frontend.normalize_code_for_tokenizer(source), expected, "normalizer CRLF/string/comment/minus semantics") then return 1 end if

  print "[OK] capacity-backed frontend normalization"
  return 0
end function
