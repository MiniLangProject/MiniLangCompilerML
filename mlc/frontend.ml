package mlc.frontend
import std.fs as fs
import std.string as s
import mlc.minilang_parser as parser
import mlc.tools as t

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

function _append_piece(chunks, tail, piece, last_nonspace)
  app = t.arr_chunked_push(chunks, tail, piece, 512)
  chunks = app[0]
  tail = app[1]

  if typeof(piece) == "string" and len(piece) > 0 then
    j = len(piece) - 1
    while j >= 0
      ch = piece[j]
      if _isSpace(ch) == false then
        last_nonspace = ch
        break
      end if
      j = j - 1
    end while
  end if

  return [chunks, tail, last_nonspace]
end function

function normalize_code_for_tokenizer(src)
  if typeof(src) != "string" then
    return ""
  end if

  code = s.replaceAll(src, "\r\n", "\n")
  if s.contains(code, "-") == false then
    return code
  end if
  chunks = []
  tail = []
  last_nonspace = ""
  i = 0
  n = len(code)
  in_string = false
  in_line_comment = false
  escape = false

  while i < n
    c = code[i]

    if in_line_comment then
      app0 = _append_piece(chunks, tail, c, last_nonspace)
      chunks = app0[0]
      tail = app0[1]
      last_nonspace = app0[2]
      if c == "\n" then in_line_comment = false end if
      i = i + 1
      continue
    end if

    if in_string == false and c == "/" and i + 1 < n and code[i + 1] == "/" then
      app1 = _append_piece(chunks, tail, c + code[i + 1], last_nonspace)
      chunks = app1[0]
      tail = app1[1]
      last_nonspace = app1[2]
      i = i + 2
      in_line_comment = true
      continue
    end if

    if in_string then
      app2 = _append_piece(chunks, tail, c, last_nonspace)
      chunks = app2[0]
      tail = app2[1]
      last_nonspace = app2[2]
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
      app3 = _append_piece(chunks, tail, c, last_nonspace)
      chunks = app3[0]
      tail = app3[1]
      last_nonspace = app3[2]
      in_string = true
      i = i + 1
      continue
    end if

    if c == "-" and i + 1 < n and _isDigit(code[i + 1]) then
      p = last_nonspace
      if _isAlphaNum(p) or p == "_" or p == ")" or p == "]" then
        if p != "" then
          app4 = _append_piece(chunks, tail, " ", last_nonspace)
          chunks = app4[0]
          tail = app4[1]
          last_nonspace = app4[2]
        end if
        app5 = _append_piece(chunks, tail, "-", last_nonspace)
        chunks = app5[0]
        tail = app5[1]
        last_nonspace = app5[2]
        if _isSpace(code[i + 1]) == false then
          app6 = _append_piece(chunks, tail, " ", last_nonspace)
          chunks = app6[0]
          tail = app6[1]
          last_nonspace = app6[2]
        end if
        i = i + 1
        continue
      end if
    end if

    app7 = _append_piece(chunks, tail, c, last_nonspace)
    chunks = app7[0]
    tail = app7[1]
    last_nonspace = app7[2]
    i = i + 1
  end while

  pieces = t.arr_chunked_finish(chunks, tail)
  if typeof(pieces) != "array" or len(pieces) <= 0 then
    return ""
  end if
  return s.join(pieces, "")
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
