package mlc.minilang_parser
import std.string as s
import mlc.tools as t

struct ParseError
  message,
  pos,
  filename,
end struct

struct Token
  kind,
  value,
  pos,
end struct

struct ParserChunkTail
  data,
  used,
  cap,
end struct

struct ParserChunkVoidSentinel
  tag,
end struct

// expression AST (initial self-hosting port)
struct Num
  node_kind,
  value,
  _pos,
  _filename,
end struct

struct Str
  node_kind,
  value,
  _pos,
  _filename,
end struct

struct Bool
  node_kind,
  value,
  _pos,
  _filename,
end struct

struct VoidLit
  node_kind,
  _pos,
  _filename,
end struct

struct Var
  node_kind,
  name,
  _pos,
  _filename,
end struct

struct ArrayLit
  node_kind,
  items,
  _pos,
  _filename,
end struct

struct Unary
  node_kind,
  op,
  right,
  _pos,
  _filename,
end struct

struct Bin
  node_kind,
  left,
  op,
  right,
  _pos,
  _filename,
end struct

struct IsType
  node_kind,
  expr,
  type_name,
  negated,
  _pos,
  _filename,
end struct

struct Call
  node_kind,
  callee,
  args,
  _pos,
  _filename,
end struct

struct Index
  node_kind,
  target,
  index,
  _pos,
  _filename,
end struct

struct Member
  node_kind,
  target,
  name,
  _pos,
  _filename,
end struct

// statement AST (subset port)
struct Import
  node_kind,
  path,
  alias,
  module,
  _pos,
  _filename,
end struct

struct NamespaceDecl
  node_kind,
  name,
  _pos,
  _filename,
end struct

struct NamespaceDef
  node_kind,
  name,
  body,
  _pos,
  _filename,
end struct

struct Print
  node_kind,
  expr,
  _pos,
  _filename,
end struct

struct Assign
  node_kind,
  name,
  expr,
  _pos,
  _filename,
end struct

struct SetMember
  node_kind,
  obj,
  field,
  expr,
  _pos,
  _filename,
end struct

struct SetIndex
  node_kind,
  target,
  index,
  expr,
  _pos,
  _filename,
end struct

struct ConstDecl
  node_kind,
  name,
  expr,
  _pos,
  _filename,
end struct

struct ExprStmt
  node_kind,
  expr,
  _pos,
  _filename,
end struct

struct FunctionDef
  node_kind,
  name,
  params,
  body,
  is_static,
  is_inline,
  _ml_locals,
  _ml_globals_declared,
  _ml_captures,
  _ml_capture_depth,
  _ml_nested_functions,
  _ml_parent_fn,
  _ml_boxed,
  _ml_env_slots,
  _ml_env_index,
  _ml_capture_index,
  _ml_env_hop,
  _pos,
  _filename,
end struct

struct Return
  node_kind,
  expr,
  _pos,
  _filename,
end struct

struct If
  node_kind,
  cond,
  then_body,
  elifs,
  else_body,
  _pos,
  _filename,
end struct

struct While
  node_kind,
  cond,
  body,
  _pos,
  _filename,
end struct

struct For
  node_kind,
  var,
  start,
  end_expr,
  body,
  _pos,
  _filename,
end struct

struct ForEach
  node_kind,
  var,
  iterable,
  body,
  _pos,
  _filename,
end struct

struct Break
  node_kind,
  count,
  _pos,
  _filename,
end struct

struct Continue
  node_kind,
  _pos,
  _filename,
end struct

struct GlobalDecl
  node_kind,
  names,
  _pos,
  _filename,
end struct

struct DoWhile
  node_kind,
  body,
  cond,
  _pos,
  _filename,
end struct

struct SwitchCase
  node_kind,
  kind,
  values,
  range_start,
  range_end,
  body,
  _pos,
  _filename,
end struct

struct Switch
  node_kind,
  expr,
  cases,
  default_body,
  _pos,
  _filename,
end struct

struct StructDef
  node_kind,
  name,
  fields,
  methods,
  _extern_field_types,
  _pos,
  _filename,
end struct

struct EnumDef
  node_kind,
  name,
  variants,
  values,
  _pos,
  _filename,
end struct

struct ExternParam
  node_kind,
  name,
  ty,
  is_out,
end struct

struct ExternFunctionDef
  node_kind,
  name,
  params,
  dll,
  symbol_name,
  ret_ty,
  _pos,
  _filename,
end struct

struct ParseKeepResult
  program,
  errors,
end struct

_keywords =[
"print", "if", "then", "else", "end", "while", "loop", "true", "false", "and", "or", "not",
"function", "return", "global", "const", "for", "to", "each", "in", "break", "continue",
"switch", "case", "default", "struct", "enum", "are", "namespace", "import", "as", "package",
"extern", "from", "returns", "symbol", "out", "static", "inline", "void", "is"
]

function newToken(kind, value, pos)
  return Token(kind, value, pos)
end function

function newParseError(message, pos, filename)
  return ParseError(message, pos, filename)
end function

function _substr(text, start, length)
  if typeof(text) != "string" then return "" end if
  if start < 0 then start = 0 end if
  if length <= 0 or start >= len(text) then return "" end if
  return s.substr(text, start, length)
end function

function _charCode(ch)
  b = bytes(ch)
  if len(b) <= 0 then return -1 end if
  return b[0]
end function

function _isDigit(ch)
  c = _charCode(ch)
  return c >= 48 and c <= 57
end function

function _isHexDigit(ch)
  c = _charCode(ch)
  return (c >= 48 and c <= 57) or(c >= 65 and c <= 70) or(c >= 97 and c <= 102)
end function

function _isAlpha(ch)
  c = _charCode(ch)
  return (c >= 65 and c <= 90) or(c >= 97 and c <= 122)
end function

function _isIdentStart(ch)
  return _isAlpha(ch) or ch == "_"
end function

function _isIdentPart(ch)
  return _isIdentStart(ch) or _isDigit(ch)
end function

function _isKeyword(word)
  for i = 0 to len(_keywords) - 1
    if _keywords[i] == word then
      return true
    end if
  end for
  return false
end function

function _unknownChar(code, pos)
  return ParseError("Unknown character: '" + _substr(code, pos, 10) + "'", pos, "")
end function

const TOKEN_CHUNK_CAP = 256
_parser_chunk_void_sentinel = ParserChunkVoidSentinel(0x50A9)

function _parser_chunk_wrap_value(value)
  if typeof(value) == "void" then
    return _parser_chunk_void_sentinel
  end if
  return value
end function

function _parser_chunk_unwrap_value(value)
  if typeof(value) == "struct" and value == _parser_chunk_void_sentinel then
    return
  end if
  if typeof(value) == "void" then
    return
  end if
  return value
end function

function _parser_chunk_tail_new(cap)
  ccap = cap
  if typeof(ccap) != "int" or ccap <= 0 then ccap = 64 end if
  return ParserChunkTail(array(ccap, 0), 0, ccap)
end function

function _parser_chunk_tail_from_array(arr, cap)
  t = _parser_chunk_tail_new(cap)
  if typeof(arr) != "array" or len(arr) <= 0 then return t end if
  copy_n = len(arr)
  if copy_n > t.cap then copy_n = t.cap end if
  for i = 0 to copy_n - 1
    t.data[i] = _parser_chunk_wrap_value(arr[i])
  end for
  t.used = copy_n
  return t
end function

function _parser_chunk_tail_len(tail)
  if typeof(tail) == "array" then return len(tail) end if
  if typeof(tail) != "struct" then return 0 end if
  if typeof(tail.used) != "int" or tail.used <= 0 then return 0 end if
  n = tail.used
  if typeof(tail.cap) == "int" and tail.cap >= 0 and n > tail.cap then n = tail.cap end if
  if typeof(tail.data) == "array" and n > len(tail.data) then n = len(tail.data) end if
  if n < 0 then n = 0 end if
  return n
end function

function _parser_chunk_tail_to_array(tail)
  if typeof(tail) == "array" then return tail end if
  if typeof(tail) != "struct" or typeof(tail.data) != "array" then return [] end if
  n = _parser_chunk_tail_len(tail)
  if n <= 0 then return [] end if
  has_void = false
  for i = 0 to n - 1
    cell = tail.data[i]
    if typeof(cell) == "struct" and cell == _parser_chunk_void_sentinel then
      has_void = true
      break
    end if
    if typeof(cell) == "void" then
      has_void = true
      break
    end if
  end for
  if has_void == false then
    outv = array(n, 0)
    for i = 0 to n - 1
      outv[i] = tail.data[i]
    end for
    return outv
  end if
  parts = []
  blk = []
  blk_cap = 256
  for i = 0 to n - 1
    blk = blk + [_parser_chunk_unwrap_value(tail.data[i])]
    if len(blk) >= blk_cap then
      parts = parts + [blk]
      blk = []
    end if
  end for
  if len(blk) > 0 then
    parts = parts + [blk]
  end if
  return _chunked_merge_balanced(parts)
end function

function _chunked_push(chunks, tail, value, cap)
  if typeof(chunks) != "array" then chunks = [] end if
  ccap = cap
  if typeof(ccap) != "int" or ccap <= 0 then ccap = 64 end if
  t = tail
  if typeof(t) == "array" then t = _parser_chunk_tail_from_array(t, ccap) end if
  if typeof(t) != "struct" or typeof(t.data) != "array" then t = _parser_chunk_tail_new(ccap) end if
  if typeof(t.cap) != "int" or t.cap <= 0 then t.cap = ccap end if
  if typeof(t.used) != "int" or t.used < 0 then t.used = 0 end if
  if t.cap != ccap then
    if t.used > 0 then
      chunks = chunks + [_parser_chunk_tail_to_array(t)]
    end if
    t = _parser_chunk_tail_new(ccap)
  end if
  if t.used >= ccap then
    chunks = chunks + [_parser_chunk_tail_to_array(t)]
    t = _parser_chunk_tail_new(ccap)
  end if
  t.data[t.used] = _parser_chunk_wrap_value(value)
  t.used = t.used + 1
  return [chunks, t]
end function

function _chunked_merge_balanced(chunks)
  if typeof(chunks) != "array" then return [] end if
  if len(chunks) <= 0 then return [] end if
  outv = []
  for i = 0 to len(chunks) - 1
    if typeof(chunks[i]) == "array" then
      outv = outv + chunks[i]
    else
      outv = outv + [chunks[i]]
    end if
  end for
  return outv
end function

function _chunked_finish(chunks, tail)
  if typeof(chunks) != "array" then chunks = [] end if
  tail_arr = _parser_chunk_tail_to_array(tail)
  if typeof(tail_arr) == "array" and len(tail_arr) > 0 then
    chunks = chunks + [tail_arr]
  end if
  return _chunked_merge_balanced(chunks)
end function

function _token_push(chunks, tail, kind, value, pos)
  return _chunked_push(chunks, tail, Token(kind, value, pos), TOKEN_CHUNK_CAP)
end function

function tokenize(code)
  if typeof(code) != "string" then
    return ParseError("tokenize expects source string", 0, "")
  end if

  token_chunks = []
  token_tail = []
  i = 0
  n = len(code)
  while i < n
    ch = code[i]

    if ch == " " or ch == "\t" then
      i = i + 1
      continue
    end if
    if ch == "\n" then
      app = _token_push(token_chunks, token_tail, "NL", "\\n", i)
      token_chunks = app[0]
      token_tail = app[1]
      i = i + 1
      continue
    end if

    if ch == "/" and i + 1 < n and code[i + 1] == "/" then
      i = i + 2
      while i < n and code[i] != "\n"
        i = i + 1
      end while
      continue
    end if

    if ch == "/" and i + 1 < n and code[i + 1] == "*" then
      i = i + 2
      closed = false
      while i + 1 < n
        if code[i] == "\n" then
          app = _token_push(token_chunks, token_tail, "NL", "\\n", i)
          token_chunks = app[0]
          token_tail = app[1]
        end if
        if code[i] == "*" and code[i + 1] == "/" then
          i = i + 2
          closed = true
          break
        end if
        i = i + 1
      end while
      if closed == false then
        return _unknownChar(code, n - 1)
      end if
      continue
    end if

    if _isDigit(ch) then
      start = i
      if ch == "0" and i + 2 < n and(code[i + 1] == "x" or code[i + 1] == "X") and _isHexDigit(code[i + 2]) then
        i = i + 3
        while i < n and _isHexDigit(code[i])
          i = i + 1
        end while
        app = _token_push(token_chunks, token_tail, "NUMBER", _substr(code, start, i - start), start)
        token_chunks = app[0]
        token_tail = app[1]
        continue
      end if
      if ch == "0" and i + 2 < n and(code[i + 1] == "b" or code[i + 1] == "B") and(code[i + 2] == "0" or code[i + 2] == "1") then
        i = i + 3
        while i < n and(code[i] == "0" or code[i] == "1")
          i = i + 1
        end while
        app = _token_push(token_chunks, token_tail, "NUMBER", _substr(code, start, i - start), start)
        token_chunks = app[0]
        token_tail = app[1]
        continue
      end if
      while i < n and _isDigit(code[i])
        i = i + 1
      end while
      if i + 1 < n and code[i] == "." and _isDigit(code[i + 1]) then
        i = i + 1
        while i < n and _isDigit(code[i])
          i = i + 1
        end while
      end if
      app = _token_push(token_chunks, token_tail, "NUMBER", _substr(code, start, i - start), start)
      token_chunks = app[0]
      token_tail = app[1]
      continue
    end if

    if ch == "\"" then
      start = i
      i = i + 1
      closed = false
      while i < n
        c = code[i]
        if c == "\\" then
          if i + 1 >= n then
            return _unknownChar(code, start)
          end if
          i = i + 2
          continue
        end if
        if c == "\"" then
          i = i + 1
          closed = true
          break
        end if
        i = i + 1
      end while
      if closed == false then
        return _unknownChar(code, start)
      end if
      app = _token_push(token_chunks, token_tail, "STRING", _substr(code, start, i - start), start)
      token_chunks = app[0]
      token_tail = app[1]
      continue
    end if

    if _isIdentStart(ch) then
      start = i
      i = i + 1
      while i < n and _isIdentPart(code[i])
        i = i + 1
      end while
      text = _substr(code, start, i - start)
      if _isKeyword(text) then
        app = _token_push(token_chunks, token_tail, "KW", text, start)
        token_chunks = app[0]
        token_tail = app[1]
      else
        app = _token_push(token_chunks, token_tail, "IDENT", text, start)
        token_chunks = app[0]
        token_tail = app[1]
      end if
      continue
    end if

    if i + 1 < n then
      two = ch + code[i + 1]
      if two == "==" or two == "!=" or two == ">=" or two == "<=" or two == "<<" or two == ">>" then
        app = _token_push(token_chunks, token_tail, "OP", two, i)
        token_chunks = app[0]
        token_tail = app[1]
        i = i + 2
        continue
      end if
    end if

    if ch == "." then
      app = _token_push(token_chunks, token_tail, "DOT", ".", i)
      token_chunks = app[0]
      token_tail = app[1]
      i = i + 1
      continue
    end if
    if ch == "(" then
      app = _token_push(token_chunks, token_tail, "LPAREN", "(", i)
      token_chunks = app[0]
      token_tail = app[1]
      i = i + 1
      continue
    end if
    if ch == ")" then
      app = _token_push(token_chunks, token_tail, "RPAREN", ")", i)
      token_chunks = app[0]
      token_tail = app[1]
      i = i + 1
      continue
    end if
    if ch == "[" then
      app = _token_push(token_chunks, token_tail, "LBRACK", "[", i)
      token_chunks = app[0]
      token_tail = app[1]
      i = i + 1
      continue
    end if
    if ch == "]" then
      app = _token_push(token_chunks, token_tail, "RBRACK", "]", i)
      token_chunks = app[0]
      token_tail = app[1]
      i = i + 1
      continue
    end if
    if ch == "," then
      app = _token_push(token_chunks, token_tail, "COMMA", ",", i)
      token_chunks = app[0]
      token_tail = app[1]
      i = i + 1
      continue
    end if
    if ch == ";" then
      app = _token_push(token_chunks, token_tail, "SEMI", ";", i)
      token_chunks = app[0]
      token_tail = app[1]
      i = i + 1
      continue
    end if

    if ch == "+" or ch == "-" or ch == "*" or ch == "/" or ch == "%" or ch == "=" or ch == "<" or ch == ">" or ch == "&" or ch == "|" or ch == "^" or ch == "~" then
      app = _token_push(token_chunks, token_tail, "OP", ch, i)
      token_chunks = app[0]
      token_tail = app[1]
      i = i + 1
      continue
    end if

    return _unknownChar(code, i)
  end while

  app = _token_push(token_chunks, token_tail, "EOF", "", n)
  token_chunks = app[0]
  token_tail = app[1]
  return _chunked_finish(token_chunks, token_tail)
end function

function _repeat(text, n)
  rep = ""
  for i = 1 to n
    rep = rep + text
  end for
  return rep
end function

function _line_col(source, pos)
  if pos < 0 then pos = 0 end if
  if pos > len(source) then pos = len(source) end if
  line = 1
  col = 1
  for i = 0 to pos - 1
    if source[i] == "\n" then
      line = line + 1
      col = 1
    else
      col = col + 1
    end if
  end for
  return [line, col]
end function

function format_error(source, filename, pos, message, kind)
  if pos < 0 then pos = 0 end if
  if pos > len(source) then pos = len(source) end if
  lc = _line_col(source, pos)
  line_no = lc[0]
  col_no = lc[1]

  line_start = pos
  while line_start > 0 and source[line_start - 1] != "\n"
    line_start = line_start - 1
  end while
  line_end = pos
  while line_end < len(source) and source[line_end] != "\n"
    line_end = line_end + 1
  end while

  line_text = _substr(source, line_start, line_end - line_start)
  caret = _repeat(" ", col_no - 1) + "^"

  return kind + ": " + message + "\n" +"  at " + filename + ":" + line_no + ":" + col_no + "\n" +"  " + line_text + "\n" +"  " + caret
end function

_tokens =[]
_i = 0
_source = ""
_filename = ""
_last_error = 0
_has_last_error = false
_func_depth = 0
_ns_depth = 0
_seen_package = false
_seen_nonpackage_toplevel_stmt = false
_collect_errors = false
_max_errors = 50
_errors =[]

function _set_error(message, pos)
  global _last_error, _has_last_error, _filename
  if _has_last_error then return end if
  _last_error = ParseError(message, pos, _filename)
  _has_last_error = true
end function

function _clear_error()
  global _last_error, _has_last_error
  _last_error = 0
  _has_last_error = false
end function

function _has_error()
  global _has_last_error
  return _has_last_error
end function

function _reset(tokens, source, filename, collect_errors, max_errors)
  global _tokens, _i, _source, _filename, _func_depth, _ns_depth, _seen_package, _seen_nonpackage_toplevel_stmt, _collect_errors, _max_errors, _errors
  _tokens = tokens
  _i = 0
  _source = source
  _filename = filename
  _func_depth = 0
  _ns_depth = 0
  _seen_package = false
  _seen_nonpackage_toplevel_stmt = false
  _collect_errors = collect_errors
  _max_errors = max_errors
  _errors =[]
  _clear_error()
end function

function _peek()
  global _tokens, _i
  if len(_tokens) <= 0 then return Token("EOF", "", 0) end if
  if _i >= len(_tokens) then return _tokens[len(_tokens) - 1] end if
  return _tokens[_i]
end function

function _peek2()
  global _tokens, _i
  if len(_tokens) <= 0 then return Token("EOF", "", 0) end if
  if _i + 1 < len(_tokens) then return _tokens[_i + 1] end if
  return _tokens[len(_tokens) - 1]
end function

function _advance()
  global _tokens, _i
  t = _peek()
  if _i < len(_tokens) then _i = _i + 1 end if
  return t
end function

function _match_kind(kind)
  t = _peek()
  if t.kind != kind then return false end if
  _advance()
  return true
end function

function _match_value(kind, value)
  t = _peek()
  if t.kind != kind then return false end if
  if t.value != value then return false end if
  _advance()
  return true
end function

function _expect_kind(kind)
  t = _peek()
  if t.kind != kind then
    _set_error("Expected " + kind + ", got " + t.kind + ":" + t.value, t.pos)
    return
  end if
  return _advance()
end function

function _expect_value(kind, value)
  t = _peek()
  if t.kind != kind or t.value != value then
    _set_error("Expected " + kind + " " + value + ", got " + t.kind + ":" + t.value, t.pos)
    return
  end if
  return _advance()
end function

function _skip_newlines()
  while _match_kind("NL")
  end while
end function

function _hex_value(ch)
  c = _charCode(ch)
  if c >= 48 and c <= 57 then return c - 48 end if
  if c >= 65 and c <= 70 then return c - 65 + 10 end if
  if c >= 97 and c <= 102 then return c - 97 + 10 end if
  return -1
end function

function _charFromCode(v)
  if v < 0 then return "" end if
  b = bytes(1, 0)
  b[0] = v & 255
  d = decode(b)
  if typeof(d) != "string" then return "" end if
  return d
end function

function _decode_string_raw(raw, pos)
  decoded = ""
  i = 0
  while i < len(raw)
    ch = raw[i]
    if ch != "\\" then
      decoded = decoded + ch
      i = i + 1
      continue
    end if
    if i + 1 >= len(raw) then
      _set_error("Invalid escape at end of string", pos + i)
      return
    end if
    esc = raw[i + 1]
    if esc == "n" then decoded = decoded + "\n" ; i = i + 2 ; continue end if
    if esc == "r" then decoded = decoded + "\r" ; i = i + 2 ; continue end if
    if esc == "t" then decoded = decoded + "\t" ; i = i + 2 ; continue end if
    if esc == "0" then decoded = decoded + "\0" ; i = i + 2 ; continue end if
    if esc == "\\" then decoded = decoded + "\\" ; i = i + 2 ; continue end if
    if esc == "\"" then decoded = decoded + "\"" ; i = i + 2 ; continue end if
    if esc == "x" then
      if i + 3 >= len(raw) then _set_error("Invalid \\x escape", pos + i) ; return end if
      h1 = _hex_value(raw[i + 2])
      h2 = _hex_value(raw[i + 3])
      if h1 < 0 or h2 < 0 then _set_error("Invalid \\x escape", pos + i) ; return end if
      decoded = decoded + _charFromCode(h1 * 16 + h2)
      i = i + 4
      continue
    end if
    decoded = decoded + esc
    i = i + 2
  end while
  return decoded
end function

function _decode_string_token(tok)
  if tok.kind != "STRING" then
    _set_error("Expect STRING literal", tok.pos)
    return
  end if
  raw = _substr(tok.value, 1, len(tok.value) - 2)
  return _decode_string_raw(raw, tok.pos)
end function

function _parse_base_int(raw, start_index, base)
  v = 0
  for i = start_index to len(raw) - 1
    d = _hex_value(raw[i])
    if d < 0 or d >= base then return end if
    v = v * base + d
  end for
  return v
end function

function _parse_int_literal(raw)
  if _substr(raw, 0, 2) == "0x" or _substr(raw, 0, 2) == "0X" then
    return _parse_base_int(raw, 2, 16)
  end if
  if _substr(raw, 0, 2) == "0b" or _substr(raw, 0, 2) == "0B" then
    return _parse_base_int(raw, 2, 2)
  end if
  return toNumber(raw)
end function

function _parse_float_literal(raw)
  return toFloat(raw)
end function

function _precedence(op)
  if op == "or" then return 1 end if
  if op == "and" then return 2 end if
  if op == "|" then return 3 end if
  if op == "^" then return 4 end if
  if op == "&" then return 5 end if
  if op == "==" or op == "!=" or op == "is" then return 6 end if
  if op == ">" or op == "<" or op == ">=" or op == "<=" then return 7 end if
  if op == "<<" or op == ">>" then return 8 end if
  if op == "+" or op == "-" then return 9 end if
  if op == "*" or op == "/" or op == "%" then return 10 end if
  return -1
end function

function _parse_expr_list(end_kind)
  items_chunks = []
  items_tail = []
  _skip_newlines()
  if _match_kind(end_kind) then return _chunked_finish(items_chunks, items_tail) end if
  while true
    it = _parse_expr(0)
    if _has_error() then return end if
    app = _chunked_push(items_chunks, items_tail, it, 32)
    items_chunks = app[0]
    items_tail = app[1]
    _skip_newlines()
    if _match_kind("COMMA") then
      _skip_newlines()
      if _match_kind(end_kind) then break end if
      continue
    end if
    _expect_kind(end_kind)
    if _has_error() then return end if
    break
  end while
  return _chunked_finish(items_chunks, items_tail)
end function

function _parse_primary()
  t = _peek()

  if t.kind == "LPAREN" then
    sp = t.pos
    _advance()
    e = _parse_expr(0)
    if _has_error() then return end if
    _expect_kind("RPAREN")
    if _has_error() then return end if
    if typeof(e._pos) != "int" then e._pos = sp end if
    return e
  end if

  if t.kind == "LBRACK" then
    sp = t.pos
    _advance()
    items = _parse_expr_list("RBRACK")
    if _has_error() then return end if
    return ArrayLit("ArrayLit", items, sp, _filename)
  end if

  if t.kind == "NUMBER" then
    sp = t.pos
    _advance()
    if _match_number_has_dot(t.value) then
      return Num("Num", _parse_float_literal(t.value), sp, _filename)
    end if
    return Num("Num", _parse_int_literal(t.value), sp, _filename)
  end if

  if t.kind == "STRING" then
    sp = t.pos
    _advance()
    raw = _substr(t.value, 1, len(t.value) - 2)
    val = _decode_string_raw(raw, t.pos)
    if _has_error() then return end if
    return Str("Str", val, sp, _filename)
  end if

  if t.kind == "KW" and(t.value == "true" or t.value == "false") then
    sp = t.pos
    _advance()
    return Bool("Bool", t.value == "true", sp, _filename)
  end if

  if t.kind == "KW" and t.value == "void" then
    sp = t.pos
    _advance()
    return VoidLit("VoidLit", sp, _filename)
  end if

  if t.kind == "IDENT" then
    sp = t.pos
    _advance()
    return Var("Var", t.value, sp, _filename)
  end if

  _set_error("Unexpected expression: " + t.kind + ":" + t.value, t.pos)
end function

function _match_number_has_dot(text)
  if len(text) <= 0 then return false end if
  for i = 0 to len(text) - 1
    if text[i] == "." then return true end if
  end for
  return false
end function

function _containsDot(text)
  if len(text) <= 0 then return false end if
  for i = 0 to len(text) - 1
    if text[i] == "." then return true end if
  end for
  return false
end function

function _parse_postfix()
  expr = _parse_primary()
  if _has_error() then return end if
  while true
    tok = _peek()
    if tok.kind == "LPAREN" then
      sp = expr._pos
      if typeof(sp) != "int" then sp = tok.pos end if
      _advance()
      args = _parse_expr_list("RPAREN")
      if _has_error() then return end if
      expr = Call("Call", expr, args, sp, _filename)
      continue
    end if
    if tok.kind == "LBRACK" then
      sp = expr._pos
      if typeof(sp) != "int" then sp = tok.pos end if
      _advance()
      _skip_newlines()
      idx = _parse_expr(0)
      if _has_error() then return end if
      _skip_newlines()
      _expect_kind("RBRACK")
      if _has_error() then return end if
      expr = Index("Index", expr, idx, sp, _filename)
      continue
    end if
    if tok.kind == "DOT" then
      sp = expr._pos
      if typeof(sp) != "int" then sp = tok.pos end if
      _advance()
      nm = _expect_kind("IDENT")
      if _has_error() then return end if
      expr = Member("Member", expr, nm.value, sp, _filename)
      continue
    end if
    break
  end while
  return expr
end function

function _parse_unary()
  t = _peek()
  if t.kind == "OP" and t.value == "-" then
    sp = t.pos
    _advance()
    _skip_newlines()
    r = _parse_unary()
    if _has_error() then return end if
    return Unary("Unary", "-", r, sp, _filename)
  end if
  if t.kind == "OP" and t.value == "~" then
    sp = t.pos
    _advance()
    _skip_newlines()
    r = _parse_unary()
    if _has_error() then return end if
    return Unary("Unary", "~", r, sp, _filename)
  end if
  if t.kind == "KW" and t.value == "not" then
    sp = t.pos
    _advance()
    _skip_newlines()
    r = _parse_unary()
    if _has_error() then return end if
    return Unary("Unary", "not", r, sp, _filename)
  end if
  return _parse_postfix()
end function

function _canonical_type_name(raw_ty)
  if raw_ty == "integer" then return "int" end if
  if raw_ty == "boolean" then return "bool" end if
  if raw_ty == "str" then return "string" end if
  return raw_ty
end function

function _is_allowed_type_name(ty)
  return ty == "int" or ty == "float" or ty == "bool" or ty == "string" or ty == "array" or ty == "bytes" or ty == "function" or ty == "struct" or ty == "enum" or ty == "error" or ty == "void" or ty == "unknown"
end function

function _parse_expr(min_prec)
  left = _parse_unary()
  if _has_error() then return end if
  while true
    tok = _peek()
    op = ""
    if tok.kind == "OP" then op = tok.value end if
    if tok.kind == "KW" and(tok.value == "and" or tok.value == "or" or tok.value == "is") then op = tok.value end if
    if op == "" then break end if
    prec = _precedence(op)
    if prec < min_prec or prec < 0 then break end if
    _advance()
    _skip_newlines()

    if op == "is" then
      is_start = tok.pos
      is_not = false
      if _peek().kind == "KW" and _peek().value == "not" then
        is_not = true
        _advance()
        _skip_newlines()
      end if

      ty_tok = _peek()
      if ty_tok.kind != "IDENT" and ty_tok.kind != "KW" then
        _set_error("Expected type name after 'is'", ty_tok.pos)
        return
      end if

      ty_raw = _advance().value
      while _match_kind("DOT")
        seg = _expect_kind("IDENT")
        if _has_error() then return end if
        ty_raw = ty_raw + "." + seg.value
      end while

      ty_l = s.toLowerAscii(ty_raw)
      ty_canon = ty_raw
      if _containsDot(ty_raw) == false then
        ty_canon = _canonical_type_name(ty_l)
      end if

      sp = left._pos
      if typeof(sp) != "int" then sp = is_start end if

      if _is_allowed_type_name(ty_canon) then
        tvar = Var("Var", "typeof", is_start, _filename)
        tcall = Call("Call", tvar,[left], sp, _filename)
        rhs = Str("Str", ty_canon, ty_tok.pos, _filename)
        cmp = Bin("Bin", tcall, "==", rhs, sp, _filename)
        if is_not then
          left = Unary("Unary", "not", cmp, sp, _filename)
        else
          left = cmp
        end if
      else
        left = IsType("IsType", left, ty_raw, is_not, sp, _filename)
      end if
      continue
    end if

    right = _parse_expr(prec + 1)
    if _has_error() then return end if
    sp = left._pos
    if typeof(sp) != "int" then sp = tok.pos end if
    left = Bin("Bin", left, op, right, sp, _filename)
  end while
  return left
end function

function _parse_ident_list(end_kind)
  items_chunks = []
  items_tail = []
  _skip_newlines()
  if _match_kind(end_kind) then return _chunked_finish(items_chunks, items_tail) end if
  while true
    t = _expect_kind("IDENT")
    if _has_error() then return end if
    app = _chunked_push(items_chunks, items_tail, t.value, 32)
    items_chunks = app[0]
    items_tail = app[1]
    _skip_newlines()
    if _match_kind("COMMA") then
      _skip_newlines()
      if _match_kind(end_kind) then break end if
      continue
    end if
    _expect_kind(end_kind)
    if _has_error() then return end if
    break
  end while
  return _chunked_finish(items_chunks, items_tail)
end function

function _skip_stmt_seps()
  while true
    if _match_kind("NL") then continue end if
    if _match_kind("SEMI") then continue end if
    break
  end while
end function

function _expect_block_nl()
  if _match_kind("NL") or _match_kind("SEMI") then
    _skip_stmt_seps()
    return
  end if
end function

function _is_end_of(what)
  return _peek().kind == "KW" and _peek().value == "end" and _peek2().kind == "KW" and _peek2().value == what
end function

function _expect_end_of(what)
  _expect_value("KW", "end")
  if _has_error() then return end if
  _expect_value("KW", what)
end function

function _parse_dotted_name()
  t = _expect_kind("IDENT")
  if _has_error() then return end if
  out_name = t.value
  while _match_kind("DOT")
    seg = _expect_kind("IDENT")
    if _has_error() then return end if
    out_name = out_name + "." + seg.value
  end while
  return out_name
end function

function _peek_non_nl()
  global _tokens, _i
  j = _i
  while j < len(_tokens) and _tokens[j].kind == "NL"
    j = j + 1
  end while
  if j >= len(_tokens) then
    return _tokens[len(_tokens) - 1]
  end if
  return _tokens[j]
end function

function _parse_extern_param()
  is_out = false
  if _peek().kind == "KW" and _peek().value == "out" then
    is_out = true
    _advance()
  end if
  t = _peek()
  if t.kind != "IDENT" and t.kind != "KW" then
    _set_error("external parameter expects a type or '<name> as <type>'", t.pos)
    return
  end if
  first = _advance().value
  if _peek().kind == "KW" and _peek().value == "as" then
    _advance()
    ty_tok = _peek()
    if ty_tok.kind != "IDENT" and ty_tok.kind != "KW" then
      _set_error("external parameter expects a type name after 'as'", ty_tok.pos)
      return
    end if
    ty = _advance().value
    return ExternParam("ExternParam", first, ty, is_out)
  end if
  return ExternParam("ExternParam", 0, first, is_out)
end function

function _parse_extern_param_list(end_kind)
  items_chunks = []
  items_tail = []
  _skip_newlines()
  if _match_kind(end_kind) then return _chunked_finish(items_chunks, items_tail) end if
  while true
    p = _parse_extern_param()
    if _has_error() then return end if
    app = _chunked_push(items_chunks, items_tail, p, 32)
    items_chunks = app[0]
    items_tail = app[1]
    _skip_newlines()
    if _match_kind("COMMA") then
      _skip_newlines()
      if _match_kind(end_kind) then break end if
      continue
    end if
    _expect_kind(end_kind)
    if _has_error() then return end if
    break
  end while
  return _chunked_finish(items_chunks, items_tail)
end function

function _parse_namespace_def(start_pos)
  global _ns_depth, _func_depth
  _expect_value("KW", "namespace")
  if _has_error() then return end if
  if _func_depth > 0 then
    _set_error("'namespace' is only permitted at the top level", start_pos)
    return
  end if

  ns_name = _parse_dotted_name()
  if _has_error() then return end if
  _expect_block_nl()

  _ns_depth = _ns_depth + 1
  body_chunks = []
  body_tail = []
  _skip_stmt_seps()
  while not _is_end_of("namespace")
    if _peek().kind == "EOF" then
      _set_error("namespace ends unexpectedly (missing 'end namespace'?)", _peek().pos)
      break
    end if
    t = _peek()
    if t.kind == "KW" and t.value == "import" then
      _set_error("'import' is not allowed inside a namespace", t.pos)
      if _collect_errors then
        _record_error(_last_error)
        _clear_error()
        _sync_stmt([], "namespace")
        if len(_errors) >= _max_errors then
          break
        end if
        _skip_stmt_seps()
        continue
      end if
      break
    end if

    if t.kind == "KW" and(t.value == "function" or t.value == "struct" or t.value == "enum" or t.value == "namespace" or t.value == "extern" or t.value == "const") then
      if _collect_errors then
        st = _parse_stmt_recover([], "namespace")
        if st != 0 then
          app = _chunked_push(body_chunks, body_tail, st, 32)
          body_chunks = app[0]
          body_tail = app[1]
        else
          if len(_errors) >= _max_errors then
            break
          end if
        end if
      else
        st = _parse_stmt()
        if _has_error() then break end if
        app = _chunked_push(body_chunks, body_tail, st, 32)
        body_chunks = app[0]
        body_tail = app[1]
      end if
      _skip_stmt_seps()
      continue
    end if

    if t.kind == "IDENT" then
      st = 0
      if _collect_errors then
        st = _parse_stmt_recover([], "namespace")
        if st == 0 then
          if len(_errors) >= _max_errors then
            break
          end if
          _skip_stmt_seps()
          continue
        end if
      else
        st = _parse_stmt()
        if _has_error() then break end if
      end if
      if st.node_kind == "Assign" then
        app2 = _chunked_push(body_chunks, body_tail, st, 32)
        body_chunks = app2[0]
        body_tail = app2[1]
        _skip_stmt_seps()
        continue
      end if
      _set_error("Inside a namespace, only declarations/globals are allowed (e.g. 'x = ...')", t.pos)
      if _collect_errors then
        _record_error(_last_error)
        _clear_error()
        _sync_stmt([], "namespace")
        if len(_errors) >= _max_errors then
          break
        end if
        _skip_stmt_seps()
        continue
      end if
      break
    end if

    _set_error("Inside a namespace, only declarations are allowed", t.pos)
    if _collect_errors then
      _record_error(_last_error)
      _clear_error()
      _sync_stmt([], "namespace")
      if len(_errors) >= _max_errors then
        break
      end if
      _skip_stmt_seps()
      continue
    end if
    break
  end while
  _ns_depth = _ns_depth - 1
  if _has_error() then return end if
  _expect_end_of("namespace")
  if _has_error() then return end if
  return NamespaceDef("NamespaceDef", ns_name, _chunked_finish(body_chunks, body_tail), start_pos, _filename)
end function

function _parse_block_until_end(end_type, start_pos)
  stmts_chunks = []
  stmts_tail = []
  _skip_stmt_seps()
  while true
    if _is_end_of(end_type) then break end if
    if _peek().kind == "EOF" then
      _set_error("Block ended unexpectedly (missing 'end " + end_type + "'?)", _peek().pos)
      return
    end if
    if _collect_errors then
      st = _parse_stmt_recover([], end_type)
      if st != 0 then
        app = _chunked_push(stmts_chunks, stmts_tail, st, 64)
        stmts_chunks = app[0]
        stmts_tail = app[1]
      else
        if len(_errors) >= _max_errors then
          break
        end if
      end if
    else
      st = _parse_stmt()
      if _has_error() then return end if
      app2 = _chunked_push(stmts_chunks, stmts_tail, st, 64)
      stmts_chunks = app2[0]
      stmts_tail = app2[1]
    end if
    _skip_stmt_seps()
  end while
  return _chunked_finish(stmts_chunks, stmts_tail)
end function

function _contains(arr, value)
  if len(arr) <= 0 then return false end if
  for i = 0 to len(arr) - 1
    if arr[i] == value then return true end if
  end for
  return false
end function

function _record_error(err)
  global _errors, _max_errors
  if typeof(err) != "struct" then return end if
  if len(_errors) >= _max_errors then return end if
  _errors = _errors +[err]
end function

function _sync_stmt(stop_keywords, end_type)
  global _i
  start_i = _i
  while true
    t = _peek()
    if t.kind == "EOF" then
      return
    end if

    if t.kind == "NL" or t.kind == "SEMI" then
      _skip_stmt_seps()
      return
    end if

    if t.kind == "KW" then
      if _contains(stop_keywords, t.value) then
        return
      end if
      if t.value == "end" or t.value == "else" or t.value == "case" or t.value == "default" then
        return
      end if
      if typeof(end_type) == "string" and _is_end_of(end_type) then
        return
      end if
    end if

    _advance()
    if _i == start_i and _peek().kind != "EOF" then
      _advance()
    end if
    start_i = _i
  end while
end function

function _is_case_value_continuation_start(tok)
  if tok.kind == "NUMBER" or tok.kind == "STRING" or tok.kind == "LPAREN" or tok.kind == "LBRACK" then
    return true
  end if
  if tok.kind == "OP" and(tok.value == "-" or tok.value == "~") then
    return true
  end if
  if tok.kind == "KW" and(tok.value == "true" or tok.value == "false" or tok.value == "not") then
    return true
  end if
  return false
end function

function _parse_block_until(stop_keywords, end_type, start_pos)
  stmts_chunks = []
  stmts_tail = []
  _skip_stmt_seps()
  while true
    t = _peek()
    if t.kind == "KW" and _contains(stop_keywords, t.value) then break end if
    if typeof(end_type) == "string" and _is_end_of(end_type) then break end if
    if t.kind == "EOF" then
      if typeof(end_type) == "string" then
        _set_error("Block ended unexpectedly (missing 'end " + end_type + "'?)", t.pos)
      else
        _set_error("Block ended unexpectedly", t.pos)
      end if
      return
    end if
    if _collect_errors then
      st = _parse_stmt_recover(stop_keywords, end_type)
      if st != 0 then
        app = _chunked_push(stmts_chunks, stmts_tail, st, 64)
        stmts_chunks = app[0]
        stmts_tail = app[1]
      else
        if len(_errors) >= _max_errors then
          break
        end if
      end if
    else
      st = _parse_stmt()
      if _has_error() then return end if
      app2 = _chunked_push(stmts_chunks, stmts_tail, st, 64)
      stmts_chunks = app2[0]
      stmts_tail = app2[1]
    end if
    _skip_stmt_seps()
  end while
  return _chunked_finish(stmts_chunks, stmts_tail)
end function

function _parse_stmt()
  global _func_depth, _ns_depth, _seen_package, _seen_nonpackage_toplevel_stmt
  start_pos = _peek().pos
  t = _peek()

  if t.kind == "KW" and t.value == "package" then
    if _func_depth > 0 or _ns_depth > 0 then
      _set_error("'package' is only allowed at top level", t.pos)
      return
    end if
    if _seen_package then
      _set_error("'package' may only appear once per file", t.pos)
      return
    end if
    if _seen_nonpackage_toplevel_stmt then
      _set_error("'package' must be the first statement in the file", t.pos)
      return
    end if
    _seen_package = true
    _advance()
    name = _parse_dotted_name()
    if _has_error() then return end if
    return NamespaceDecl("NamespaceDecl", name, start_pos, _filename)
  end if

  if t.kind == "KW" and t.value == "namespace" then
    return _parse_namespace_def(start_pos)
  end if

  if t.kind == "KW" and t.value == "import" then
    if _func_depth > 0 or _ns_depth > 0 then
      _set_error("'import' is only allowed at top level", t.pos)
      return
    end if
    _advance()
    module_name = 0
    path = ""
    if _peek().kind == "STRING" then
      st = _advance()
      path = _decode_string_token(st)
      if _has_error() then return end if
    else
      module_name = _parse_dotted_name()
      if _has_error() then return end if
      path = _replaceDotsWithSlash(module_name) + ".ml"
    end if
    alias = 0
    if _peek().kind == "KW" and _peek().value == "as" then
      _advance()
      a = _expect_kind("IDENT")
      if _has_error() then return end if
      alias = a.value
    end if
    return Import("Import", path, alias, module_name, start_pos, _filename)
  end if

  if t.kind == "KW" and t.value == "const" then
    _advance()
    n = _expect_kind("IDENT")
    if _has_error() then return end if
    _expect_value("OP", "=")
    if _has_error() then return end if
    e = _parse_expr(0)
    if _has_error() then return end if
    return ConstDecl("ConstDecl", n.value, e, start_pos, _filename)
  end if

  if t.kind == "KW" and t.value == "print" then
    _advance()
    e = _parse_expr(0)
    if _has_error() then return end if
    return Print("Print", e, start_pos, _filename)
  end if

  if t.kind == "KW" and t.value == "break" then
    _advance()
    if _peek().kind == "NUMBER" and not _match_number_has_dot(_peek().value) then
      nraw = _advance().value
      n = _parse_int_literal(nraw)
      if typeof(n) != "int" then n = 1 end if
      if n < 1 then n = 1 end if
      return Break("Break", n, start_pos, _filename)
    end if
    return Break("Break", 1, start_pos, _filename)
  end if

  if t.kind == "KW" and t.value == "continue" then
    _advance()
    return Continue("Continue", start_pos, _filename)
  end if

  if t.kind == "KW" and t.value == "global" then
    if _func_depth <= 0 then
      _set_error("'global' is only allowed inside functions", t.pos)
      return
    end if
    _advance()
    n0 = _expect_kind("IDENT")
    if _has_error() then return end if
    names_chunks = []
    names_tail = []
    appn0 = _chunked_push(names_chunks, names_tail, n0.value, 16)
    names_chunks = appn0[0]
    names_tail = appn0[1]
    while _match_kind("COMMA")
      if _peek().kind == "NL" or _peek().kind == "SEMI" or _peek().kind == "EOF" then
        break
      end if
      ni = _expect_kind("IDENT")
      if _has_error() then return end if
      appn = _chunked_push(names_chunks, names_tail, ni.value, 16)
      names_chunks = appn[0]
      names_tail = appn[1]
    end while
    return GlobalDecl("GlobalDecl", _chunked_finish(names_chunks, names_tail), start_pos, _filename)
  end if

  if t.kind == "KW" and t.value == "return" then
    _advance()
    nxt = _peek()
    if nxt.kind == "NL" or nxt.kind == "SEMI" or nxt.kind == "EOF" then
      return Return("Return", 0, start_pos, _filename)
    end if
    if nxt.kind == "KW" and(nxt.value == "end" or nxt.value == "else" or nxt.value == "case" or nxt.value == "default") then
      return Return("Return", 0, start_pos, _filename)
    end if
    e = _parse_expr(0)
    if _has_error() then return end if
    return Return("Return", e, start_pos, _filename)
  end if

  if t.kind == "KW" and t.value == "extern" then
    if _func_depth > 0 then
      _set_error("'extern' is only allowed at top-level / inside namespace", t.pos)
      return
    end if
    _advance()

    if _peek().kind == "KW" and _peek().value == "struct" then
      _advance()
      nm = _expect_kind("IDENT")
      if _has_error() then return end if
      _expect_block_nl()
      fields_chunks = []
      fields_tail = []
      field_tys_chunks = []
      field_tys_tail = []
      while not _is_end_of("struct")
        _skip_stmt_seps()
        if _is_end_of("struct") then break end if
        if _peek().kind == "EOF" then
          _set_error("extern struct ended unexpectedly (missing 'end struct'?)", _peek().pos)
          return
        end if
        fn = _expect_kind("IDENT")
        if _has_error() then return end if
        _expect_value("KW", "as")
        if _has_error() then return end if
        ty_tok = _peek()
        if ty_tok.kind != "IDENT" and ty_tok.kind != "KW" then
          _set_error("extern struct field expects typename after 'as'", ty_tok.pos)
          return
        end if
        fty = _advance().value
        appf = _chunked_push(fields_chunks, fields_tail, fn.value, 16)
        fields_chunks = appf[0]
        fields_tail = appf[1]
        appty = _chunked_push(field_tys_chunks, field_tys_tail, fty, 16)
        field_tys_chunks = appty[0]
        field_tys_tail = appty[1]
        _expect_block_nl()
      end while
      _expect_end_of("struct")
      if _has_error() then return end if
      return StructDef("StructDef", nm.value, _chunked_finish(fields_chunks, fields_tail), [], _chunked_finish(field_tys_chunks, field_tys_tail), start_pos, _filename)
    end if

    _expect_value("KW", "function")
    if _has_error() then return end if
    nm = _expect_kind("IDENT")
    if _has_error() then return end if
    _expect_kind("LPAREN")
    if _has_error() then return end if
    params = _parse_extern_param_list("RPAREN")
    if _has_error() then return end if

    if not(_peek().kind == "KW" and _peek().value == "from") then
      _set_error("extern function expects 'from \"...\"'", _peek().pos)
      return
    end if
    _advance()

    dll_tok = _expect_kind("STRING")
    if _has_error() then return end if
    dll = _decode_string_token(dll_tok)
    if _has_error() then return end if

    sym_name = 0
    if _peek().kind == "KW" and _peek().value == "symbol" then
      _advance()
      st = _expect_kind("STRING")
      if _has_error() then return end if
      sym_name = _decode_string_token(st)
      if _has_error() then return end if
    end if

    ret_ty = "int"
    if _peek().kind == "KW" and _peek().value == "returns" then
      _advance()
      rt = _peek()
      if rt.kind != "IDENT" and rt.kind != "KW" then
        _set_error("returns expects typename", rt.pos)
        return
      end if
      ret_ty = _advance().value
    end if

    return ExternFunctionDef("ExternFunctionDef", nm.value, params, dll, sym_name, ret_ty, start_pos, _filename)
  end if

  if t.kind == "KW" and t.value == "struct" then
    _advance()
    nm = _expect_kind("IDENT")
    if _has_error() then return end if
    if _peek().kind == "KW" and _peek().value == "are" then
      _advance()
    end if
    _expect_block_nl()

    fields_chunks = []
    fields_tail = []
    methods_chunks = []
    methods_tail = []
    while not _is_end_of("struct")
      _skip_stmt_seps()
      if _is_end_of("struct") then break end if
      if _peek().kind == "EOF" then
        _set_error("struct ended unexpectedly (missing 'end struct'?)", _peek().pos)
        return
      end if

      if _peek().kind == "KW" and(_peek().value == "function" or _peek().value == "static") then
        mpos = _peek().pos
        is_static = false
        if _peek().value == "static" then
          is_static = true
          _advance()
          _skip_newlines()
          _expect_value("KW", "function")
          if _has_error() then return end if
        else
          _advance()
        end if

        is_inline = false
        if _peek().kind == "KW" and _peek().value == "inline" then
          is_inline = true
          _advance()
        end if

        mn = _expect_kind("IDENT")
        if _has_error() then return end if
        _expect_kind("LPAREN")
        if _has_error() then return end if
        mp = _parse_ident_list("RPAREN")
        if _has_error() then return end if
        _expect_block_nl()
        _func_depth = _func_depth + 1
        mb = _parse_block_until_end("function", mpos)
        _func_depth = _func_depth - 1
        if _has_error() then return end if
        _expect_end_of("function")
        if _has_error() then return end if
        appm = _chunked_push(methods_chunks, methods_tail, FunctionDef("FunctionDef", mn.value, mp, mb, is_static, is_inline, [], [], [], [], [], 0, [], [], [], [], false, mpos, _filename), 16)
        methods_chunks = appm[0]
        methods_tail = appm[1]
        continue
      end if

      f = _expect_kind("IDENT")
      if _has_error() then return end if
      appf0 = _chunked_push(fields_chunks, fields_tail, f.value, 16)
      fields_chunks = appf0[0]
      fields_tail = appf0[1]
      while _match_kind("COMMA")
        if _peek().kind == "NL" then
          nxt = _peek_non_nl()
          if nxt.kind != "IDENT" then break end if
          _skip_newlines()
        end if
        if _peek().kind != "IDENT" then break end if
        fi = _expect_kind("IDENT")
        if _has_error() then return end if
        appf = _chunked_push(fields_chunks, fields_tail, fi.value, 16)
        fields_chunks = appf[0]
        fields_tail = appf[1]
      end while
      _expect_block_nl()
    end while

    _expect_end_of("struct")
    if _has_error() then return end if
    return StructDef(
      "StructDef",
      nm.value,
      _chunked_finish(fields_chunks, fields_tail),
      _chunked_finish(methods_chunks, methods_tail),
      [],
      start_pos,
      _filename
    )
  end if

  if t.kind == "KW" and t.value == "enum" then
    _advance()
    nm = _expect_kind("IDENT")
    if _has_error() then return end if
    if _peek().kind == "KW" and _peek().value == "are" then
      _advance()
    end if
    _expect_block_nl()

    variants_chunks = []
    variants_tail = []
    values_chunks = []
    values_tail = []
    while not _is_end_of("enum")
      _skip_stmt_seps()
      if _is_end_of("enum") then break end if
      if _peek().kind == "EOF" then
        _set_error("enum ended unexpectedly (missing 'end enum'?)", _peek().pos)
        return
      end if
      vn = _expect_kind("IDENT")
      if _has_error() then return end if
      vv = void
      if _match_value("OP", "=") then
        vv = _parse_expr(0)
        if _has_error() then return end if
      end if
      appv0 = _chunked_push(variants_chunks, variants_tail, vn.value, 32)
      variants_chunks = appv0[0]
      variants_tail = appv0[1]
      appval0 = _chunked_push(values_chunks, values_tail, vv, 32)
      values_chunks = appval0[0]
      values_tail = appval0[1]

      while _match_kind("COMMA")
        if _peek().kind == "NL" then
          nxt = _peek_non_nl()
          if nxt.kind != "IDENT" then break end if
          _skip_newlines()
        end if
        if _peek().kind != "IDENT" then break end if
        vn2 = _expect_kind("IDENT")
        if _has_error() then return end if
        vv2 = void
        if _match_value("OP", "=") then
          vv2 = _parse_expr(0)
          if _has_error() then return end if
        end if
        appv = _chunked_push(variants_chunks, variants_tail, vn2.value, 32)
        variants_chunks = appv[0]
        variants_tail = appv[1]
        appval = _chunked_push(values_chunks, values_tail, vv2, 32)
        values_chunks = appval[0]
        values_tail = appval[1]
      end while
      _expect_block_nl()
    end while

    _expect_end_of("enum")
    if _has_error() then return end if
    return EnumDef(
      "EnumDef",
      nm.value,
      _chunked_finish(variants_chunks, variants_tail),
      _chunked_finish(values_chunks, values_tail),
      start_pos,
      _filename
    )
  end if

  if t.kind == "KW" and t.value == "function" then
    _advance()
    is_inline = false
    if _peek().kind == "KW" and _peek().value == "inline" then
      is_inline = true
      _advance()
    end if
    nm = _expect_kind("IDENT")
    if _has_error() then return end if
    _expect_kind("LPAREN")
    if _has_error() then return end if
    params = _parse_ident_list("RPAREN")
    if _has_error() then return end if
    _expect_block_nl()
    _func_depth = _func_depth + 1
    body = _parse_block_until_end("function", start_pos)
    _func_depth = _func_depth - 1
    if _has_error() then return end if
    _expect_end_of("function")
    if _has_error() then return end if
  return FunctionDef("FunctionDef", nm.value, params, body, false, is_inline, [], [], [], [], [], 0, [], [], [], [], false, start_pos, _filename)
  end if

  if t.kind == "KW" and t.value == "loop" then
    global _i
    _advance()
    _expect_block_nl()
    body_chunks = []
    body_tail = []
    _skip_stmt_seps()
    while true
      if _peek().kind == "KW" and _peek().value == "while" then
        save_i = _i
        _advance()
        cond = _parse_expr(0)
        if _has_error() then return end if
        _skip_stmt_seps()
        if _is_end_of("loop") then
          _expect_end_of("loop")
          if _has_error() then return end if
          return DoWhile("DoWhile", _chunked_finish(body_chunks, body_tail), cond, start_pos, _filename)
        end if
        _i = save_i
      end if

      if _is_end_of("loop") then
        _expect_end_of("loop")
        if _has_error() then return end if
        _expect_value("KW", "while")
        if _has_error() then return end if
        cond = _parse_expr(0)
        if _has_error() then return end if
        return DoWhile("DoWhile", _chunked_finish(body_chunks, body_tail), cond, start_pos, _filename)
      end if

      if _peek().kind == "EOF" then
        _set_error("loop ended unexpectedly (missing 'end loop'?)", _peek().pos)
        return
      end if

      st = _parse_stmt()
      if _has_error() then return end if
      appb = _chunked_push(body_chunks, body_tail, st, 64)
      body_chunks = appb[0]
      body_tail = appb[1]
      _skip_stmt_seps()
    end while
  end if

  if t.kind == "KW" and t.value == "switch" then
    _advance()
    ex = _parse_expr(0)
    if _has_error() then return end if
    _expect_block_nl()
    cases_chunks = []
    cases_tail = []
    default_body =[]

    while true
      if _peek().kind == "KW" and _peek().value == "case" then
        case_pos = _peek().pos
        _advance()

        if _peek().kind == "KW" and _peek().value == "default" then
          _advance()
          _expect_block_nl()
          default_body = _parse_block_until_end("case", case_pos)
          if _has_error() then return end if
          _expect_end_of("case")
          if _has_error() then return end if
          _skip_stmt_seps()
          continue
        end if

        first = _parse_expr(0)
        if _has_error() then return end if

        if _peek().kind == "KW" and _peek().value == "to" then
          _advance()
          end_expr = _parse_expr(0)
          if _has_error() then return end if
          _expect_block_nl()
          body = _parse_block_until_end("case", case_pos)
          if _has_error() then return end if
          _expect_end_of("case")
          if _has_error() then return end if
          appcr = _chunked_push(cases_chunks, cases_tail, SwitchCase("SwitchCase", "range", [], first, end_expr, body, case_pos, _filename), 32)
          cases_chunks = appcr[0]
          cases_tail = appcr[1]
          _skip_stmt_seps()
          continue
        end if

        vals_chunks = []
        vals_tail = []
        appv0 = _chunked_push(vals_chunks, vals_tail, first, 16)
        vals_chunks = appv0[0]
        vals_tail = appv0[1]
        while _match_kind("COMMA")
          if _peek().kind == "NL" then
            nxt = _peek_non_nl()
            if not _is_case_value_continuation_start(nxt) then
              break
            end if
            _skip_newlines()
          end if
          v = _parse_expr(0)
          if _has_error() then return end if
          appv = _chunked_push(vals_chunks, vals_tail, v, 16)
          vals_chunks = appv[0]
          vals_tail = appv[1]
        end while

        _expect_block_nl()
        body = _parse_block_until_end("case", case_pos)
        if _has_error() then return end if
        _expect_end_of("case")
        if _has_error() then return end if
        appcv = _chunked_push(
          cases_chunks,
          cases_tail,
          SwitchCase("SwitchCase", "values", _chunked_finish(vals_chunks, vals_tail), 0, 0, body, case_pos, _filename),
          32
        )
        cases_chunks = appcv[0]
        cases_tail = appcv[1]
        _skip_stmt_seps()
        continue
      end if

      break
    end while

    _expect_end_of("switch")
    if _has_error() then return end if
    return Switch("Switch", ex, _chunked_finish(cases_chunks, cases_tail), default_body, start_pos, _filename)
  end if

  if t.kind == "KW" and t.value == "if" then
    _advance()
    cond = _parse_expr(0)
    if _has_error() then return end if
    _expect_value("KW", "then")
    if _has_error() then return end if
    then_body = _parse_block_until(["else"], "if", start_pos)
    if _has_error() then return end if

    elifs_chunks = []
    elifs_tail = []
    else_body =[]
    while _peek().kind == "KW" and _peek().value == "else"
      _advance()
      if _peek().kind == "KW" and _peek().value == "if" then
        _advance()
        ec = _parse_expr(0)
        if _has_error() then return end if
        _expect_value("KW", "then")
        if _has_error() then return end if
        eb = _parse_block_until(["else"], "if", start_pos)
        if _has_error() then return end if
        appe = _chunked_push(elifs_chunks, elifs_tail, [ec, eb], 16)
        elifs_chunks = appe[0]
        elifs_tail = appe[1]
        continue
      end if
      else_body = _parse_block_until([], "if", start_pos)
      if _has_error() then return end if
      break
    end while

    _expect_end_of("if")
    if _has_error() then return end if
    return If("If", cond, then_body, _chunked_finish(elifs_chunks, elifs_tail), else_body, start_pos, _filename)
  end if

  if t.kind == "KW" and t.value == "while" then
    _advance()
    cond = _parse_expr(0)
    if _has_error() then return end if
    _expect_block_nl()
    body = _parse_block_until_end("while", start_pos)
    if _has_error() then return end if
    _expect_end_of("while")
    if _has_error() then return end if
    return While("While", cond, body, start_pos, _filename)
  end if

  if t.kind == "KW" and t.value == "for" then
    _advance()
    if _peek().kind == "KW" and _peek().value == "each" then
      _advance()
      vn = _expect_kind("IDENT")
      if _has_error() then return end if
      _expect_value("KW", "in")
      if _has_error() then return end if
      it = _parse_expr(0)
      if _has_error() then return end if
      _expect_block_nl()
      body = _parse_block_until_end("for", start_pos)
      if _has_error() then return end if
      _expect_end_of("for")
      if _has_error() then return end if
      return ForEach("ForEach", vn.value, it, body, start_pos, _filename)
    end if
    vn = _expect_kind("IDENT")
    if _has_error() then return end if
    _expect_value("OP", "=")
    if _has_error() then return end if
    st = _parse_expr(0)
    if _has_error() then return end if
    _expect_value("KW", "to")
    if _has_error() then return end if
    en = _parse_expr(0)
    if _has_error() then return end if
    _expect_block_nl()
    body = _parse_block_until_end("for", start_pos)
    if _has_error() then return end if
    _expect_end_of("for")
    if _has_error() then return end if
    return For("For", vn.value, st, en, body, start_pos, _filename)
  end if

  if t.kind == "IDENT" then
    expr = _parse_postfix()
    if _has_error() then return end if
    if _match_value("OP", "=") then
      rhs = _parse_expr(0)
      if _has_error() then return end if
      if expr.node_kind == "Var" then
        return Assign("Assign", expr.name, rhs, start_pos, _filename)
      end if
      if expr.node_kind == "Member" then
        return SetMember("SetMember", expr.target, expr.name, rhs, start_pos, _filename)
      end if
      if expr.node_kind == "Index" then
        return SetIndex("SetIndex", expr.target, expr.index, rhs, start_pos, _filename)
      end if
      _set_error("Invalid assignment target (lvalue)", start_pos)
      return
    end if
    if expr.node_kind == "Call" then
      return ExprStmt("ExprStmt", expr, start_pos, _filename)
    end if
    _set_error("Only assignments or function calls are allowed as a statement", start_pos)
    return
  end if

  _set_error("Unknown statement: " + t.kind + ":" + t.value, t.pos)
end function

function _parse_stmt_recover(stop_keywords, end_type)
  global _i
  start_i = _i
  st = _parse_stmt()
  if _has_error() then
    _record_error(_last_error)
    _clear_error()
    _sync_stmt(stop_keywords, end_type)
    if _i == start_i and _peek().kind != "EOF" then
      _advance()
      _skip_stmt_seps()
    end if
    return 0
  end if
  return st
end function

function _replaceDotsWithSlash(name)
  if len(name) <= 0 then return "" end if
  slash_name = ""
  for i = 0 to len(name) - 1
    if name[i] == "." then
      slash_name = slash_name + "/"
    else
      slash_name = slash_name + name[i]
    end if
  end for
  return slash_name
end function

function parse_expression(source, filename)
  toks = tokenize(source)
  if typeof(toks) == "struct" and typeof(toks.message) == "string" then
    toks.filename = filename
    return toks
  end if
  _reset(toks, source, filename, false, 50)
  _skip_newlines()
  e = _parse_expr(0)
  if _has_error() then return _last_error end if
  _skip_newlines()
  if _peek().kind != "EOF" then
    return ParseError("Trailing tokens after expression", _peek().pos, filename)
  end if
  return e
end function

function parse_program(source, filename)
  toks = tokenize(source)
  if typeof(toks) == "struct" and typeof(toks.message) == "string" then
    toks.filename = filename
    return toks
  end if
  _reset(toks, source, filename, false, 50)
  stmts_chunks = []
  stmts_tail = []
  _skip_stmt_seps()
  while _peek().kind != "EOF"
    st = _parse_stmt()
    if _has_error() then return _last_error end if
    app = _chunked_push(stmts_chunks, stmts_tail, st, 128)
    stmts_chunks = app[0]
    stmts_tail = app[1]
    if _func_depth == 0 and st.node_kind != "NamespaceDecl" then
      _seen_nonpackage_toplevel_stmt = true
    end if
    _skip_stmt_seps()
  end while
  return _chunked_finish(stmts_chunks, stmts_tail)
end function

function parse_program_keepgoing(source, filename, max_errors)
  toks = tokenize(source)
  if typeof(toks) == "struct" and typeof(toks.message) == "string" then
    toks.filename = filename
    return ParseKeepResult([], [toks])
  end if

  limit = max_errors
  if typeof(limit) != "int" or limit <= 0 then
    limit = 50
  end if

  _reset(toks, source, filename, true, limit)

  stmts_chunks = []
  stmts_tail = []
  _skip_stmt_seps()
  while _peek().kind != "EOF"
    st = _parse_stmt_recover([], 0)
    if st != 0 then
      app = _chunked_push(stmts_chunks, stmts_tail, st, 128)
      stmts_chunks = app[0]
      stmts_tail = app[1]
      if _func_depth == 0 and st.node_kind != "NamespaceDecl" then
        _seen_nonpackage_toplevel_stmt = true
      end if
    else
      if len(_errors) >= _max_errors then
        break
      end if
    end if
    _skip_stmt_seps()
  end while

  if _has_error() then
    _record_error(_last_error)
    _clear_error()
  end if

  return ParseKeepResult(_chunked_finish(stmts_chunks, stmts_tail), _errors)
end function
