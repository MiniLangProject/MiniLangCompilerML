package mlc.frontend
import std.fs as fs
import std.string as s
import mlc.minilang_parser as parser

struct FrontendParseResult
  source,
  program,
  errors,
end struct

function _isSpace(ch)
  return ch == " " or ch == "\t" or ch == "\n" or ch == "\r"
end function

function _isDigit(ch)
  b = bytes(ch)
  if len(b) <= 0 then return false end if
  c = b[0]
  return c >= 48 and c <= 57
end function

function _isAlpha(ch)
  b = bytes(ch)
  if len(b) <= 0 then return false end if
  c = b[0]
  return (c >= 65 and c <= 90) or(c >= 97 and c <= 122)
end function

function _isAlphaNum(ch)
  return _isAlpha(ch) or _isDigit(ch)
end function

function _prev_nonspace_char(text)
  if len(text) <= 0 then return "" end if
  j = len(text) - 1
  while j >= 0 and _isSpace(text[j])
    j = j - 1
  end while
  if j < 0 then return "" end if
  return text[j]
end function

function normalize_code_for_tokenizer(src)
  if typeof(src) != "string" then
    return ""
  end if

  code = s.replaceAll(src, "\r\n", "\n")
  normalized = ""
  i = 0
  n = len(code)
  in_string = false
  in_line_comment = false
  escape = false

  while i < n
    c = code[i]

    if in_line_comment then
      normalized = normalized + c
      if c == "\n" then in_line_comment = false end if
      i = i + 1
      continue
    end if

    if in_string == false and c == "/" and i + 1 < n and code[i + 1] == "/" then
      normalized = normalized + c + code[i + 1]
      i = i + 2
      in_line_comment = true
      continue
    end if

    if in_string then
      normalized = normalized + c
      if escape then
        escape = false
      else
        if c == "\\" then
          escape = true
        else
          if c == "\"" then
            in_string = false
          end if
        end if
      end if
      i = i + 1
      continue
    end if

    if c == "\"" then
      normalized = normalized + c
      in_string = true
      i = i + 1
      continue
    end if

    if c == "-" and i + 1 < n and _isDigit(code[i + 1]) then
      p = _prev_nonspace_char(normalized)
      if _isAlphaNum(p) or p == "_" or p == ")" or p == "]" then
        if len(normalized) > 0 and _isSpace(normalized[len(normalized) - 1]) == false then
          normalized = normalized + " "
        end if
        normalized = normalized + "-"
        if _isSpace(code[i + 1]) == false then
          normalized = normalized + " "
        end if
        i = i + 1
        continue
      end if
    end if

    normalized = normalized + c
    i = i + 1
  end while

  return normalized
end function

function parse_program(path)
  r = fs.readAllText(path)
  if typeof(r) == "error" then
    return r
  end if
  code = normalize_code_for_tokenizer(r)
  prog = parser.parse_program(code, path)
  if typeof(prog) == "struct" and typeof(prog.message) == "string" then
    return FrontendParseResult(code,[], [prog])
  end if
  return FrontendParseResult(code, prog,[])
end function

function load_minilang_frontend(path)
  // MiniLang self-hosted frontend is linked statically as package import.
  // Keep the function for API compatibility with the Python compiler layout.
  if fs.exists(path) then
    return true
  end if
  return false
end function

function parse_program_keepgoing(path, max_errors)
  r = fs.readAllText(path)
  if typeof(r) == "error" then
    return r
  end if
  code = normalize_code_for_tokenizer(r)
  keep = parser.parse_program_keepgoing(code, path, max_errors)
  if typeof(keep) == "struct" then
    return FrontendParseResult(code, keep.program, keep.errors)
  end if
  return FrontendParseResult(code,[], [parser.newParseError("keepgoing parser returned invalid result", 0, path)])
end function
