/*
Copyright 2026 Nils Kopal

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// Source loading, line mapping and parser integration for compiler clients.
//! Provides the mlc frontend package.

package mlc.frontend
import std.fs as fs
import mlc.minilang_parser as parser
import mlc.tools as t

/// Source text, parsed program and normalized diagnostics returned together.
struct FrontendParseResult
  /// Source associated with `FrontendParseResult`.
  source,
  /// Program associated with `FrontendParseResult`.
  program,
  /// Errors associated with `FrontendParseResult`.
  errors,
end struct

/// Process inline in the shared MiniLang front end.
/// @internal
function inline _is_space_byte(ch)
  return ch == 32 or ch == 9 or ch == 10 or ch == 13
end function

/// Process inline in the shared MiniLang front end.
/// @internal
function inline _is_digit_byte(ch)
  return ch >= 48 and ch <= 57
end function

/// Process inline in the shared MiniLang front end.
/// @internal
function inline _is_alnum_byte(ch)
  return (ch >= 48 and ch <= 57) or (ch >= 65 and ch <= 90) or (ch >= 97 and ch <= 122)
end function

/// Process normalize frontend error in the shared MiniLang front end.
/// @internal
function _normalize_frontend_error(err, fallback_path)
  if typeof(err) != "struct" then
    return err
  end if
  if typeof(err.message) != "string" then
    return err
  end if
  fn = ""
  if typeof(err.filename) == "string" then
    fn = err.filename
  end if
  if fn != "" then
    return err
  end if
  p = 0
  if typeof(err.pos) == "int" then
    p = err.pos
  end if
  return parser.newParseError(err.message, p, fallback_path)
end function

/// Process normalize frontend errors in the shared MiniLang front end.
/// @internal
function _normalize_frontend_errors(errors, fallback_path)
  if typeof(errors) != "array" or len(errors) <= 0 then
    return []
  end if

  chunks = []
  tail = []
  for i = 0 to len(errors) - 1
    err = _normalize_frontend_error(errors[i], fallback_path)
    app = t.arr_chunked_push(chunks, tail, err, 32)
    chunks = app[0]
    tail = app[1]
  end for
  return t.arr_chunked_finish(chunks, tail)
end function

/// Normalize comments/newlines while preserving source offsets for diagnostics. Operate on one capacity-backed UTF-8 byte buffer: the previous character- string builder allocated one managed string and one array slot per source byte, which dominated frontend memory on large self-hosted compilations.
/// @param src Value supplied for `src`.
function normalize_code_for_tokenizer(src)
  if typeof(src) != "string" then
    return ""
  end if

  raw = bytes(src)
  n = len(raw)
  if n <= 0 then return "" end if

  // Preserve the no-op fast path. Only CRLF pairs and minus tokens can change
  // the source; all other UTF-8 bytes can be returned without another copy.
  needs_rewrite = false
  for scan = 0 to n - 1
    ch_scan = raw[scan]
    if ch_scan == 45 then
      needs_rewrite = true
      break
    end if
    if ch_scan == 13 and scan + 1 < n and raw[scan + 1] == 10 then
      needs_rewrite = true
      break
    end if
  end for
  if needs_rewrite == false then return src end if

  // At most two separator spaces are inserted for each consumed '-' byte, so
  // twice the input size plus a small guard is a strict practical upper bound.
  output_buf = bytes((n * 2) + 16, 0)
  out_pos = 0
  last_nonspace = -1
  i = 0
  in_string = false
  in_line_comment = false
  escape = false

  while i < n
    c = raw[i]

    // Match the historical replaceAll("\r\n", "\n") preprocessing without
    // allocating a second complete source string.
    if c == 13 and i + 1 < n and raw[i + 1] == 10 then
      c = 10
      i = i + 1
    end if

    if in_line_comment then
      output_buf[out_pos] = c
      out_pos = out_pos + 1
      if _is_space_byte(c) == false then last_nonspace = c end if
      if c == 10 then in_line_comment = false end if
      i = i + 1
      continue
    end if

    if in_string == false and c == 47 and i + 1 < n and raw[i + 1] == 47 then
      output_buf[out_pos] = 47
      output_buf[out_pos + 1] = 47
      out_pos = out_pos + 2
      last_nonspace = 47
      i = i + 2
      in_line_comment = true
      continue
    end if

    if in_string then
      output_buf[out_pos] = c
      out_pos = out_pos + 1
      if _is_space_byte(c) == false then last_nonspace = c end if
      if escape then
        escape = false
      else
        if c == 92 then
          escape = true
        else
          if c == 34 then
            in_string = false
          end if
        end if
      end if
      i = i + 1
      continue
    end if

    if c == 34 then
      output_buf[out_pos] = c
      out_pos = out_pos + 1
      last_nonspace = c
      in_string = true
      i = i + 1
      continue
    end if

    if c == 45 and i + 1 < n and _is_digit_byte(raw[i + 1]) then
      p = last_nonspace
      if _is_alnum_byte(p) or p == 95 or p == 41 or p == 93 then
        output_buf[out_pos] = 32
        output_buf[out_pos + 1] = 45
        output_buf[out_pos + 2] = 32
        out_pos = out_pos + 3
        last_nonspace = 45
        i = i + 1
        continue
      end if
    end if

    output_buf[out_pos] = c
    out_pos = out_pos + 1
    if _is_space_byte(c) == false then last_nonspace = c end if
    i = i + 1
  end while

  if out_pos <= 0 then return "" end if
  if out_pos < len(output_buf) then output_buf = slice(output_buf, 0, out_pos) end if
  decoded = decode(output_buf)
  if typeof(decoded) != "string" then return "" end if
  return decoded
end function

/// Load and parse one file, returning syntax failures in the result record.
/// @param path Path to operate on.
function parse_program(path)
  r = fs.readAllText(path)
  if typeof(r) == "error" then
    return r
  end if
  code = normalize_code_for_tokenizer(r)
  source_for_tokens = parser.preprocess_compile_directives(code, path)
  if typeof(source_for_tokens) == "struct" and typeof(try(source_for_tokens.message)) == "string" then
    return FrontendParseResult(code, [], [_normalize_frontend_error(source_for_tokens, path)])
  end if
  prog = parser.parse_program(source_for_tokens, path)
  if typeof(prog) == "struct" and typeof(prog.message) == "string" then
    return FrontendParseResult(code,[], [_normalize_frontend_error(prog, path)])
  end if
  return FrontendParseResult(code, prog,[])
end function

/// Report frontend availability; the self-host build links it statically.
/// @param path Path to operate on.
function load_minilang_frontend(path)
  // The self-hosted port links the parser statically, so we return the
  // equivalent "loaded successfully" result instead of probing the filesystem.
  return true
end function

/// Parse one file while collecting up to max_errors syntax diagnostics.
/// @param path Path to operate on.
/// @param max_errors Value supplied for `max_errors`.
function parse_program_keepgoing(path, max_errors)
  r = fs.readAllText(path)
  if typeof(r) == "error" then
    return r
  end if
  code = normalize_code_for_tokenizer(r)
  source_for_tokens = parser.preprocess_compile_directives(code, path)
  if typeof(source_for_tokens) == "struct" and typeof(try(source_for_tokens.message)) == "string" then
    return FrontendParseResult(code, [], [_normalize_frontend_error(source_for_tokens, path)])
  end if
  keep = parser.parse_program_keepgoing(source_for_tokens, path, max_errors)
  if typeof(keep) == "struct" then
    return FrontendParseResult(code, keep.program, _normalize_frontend_errors(keep.errors, path))
  end if
  return FrontendParseResult(code,[], [parser.newParseError("keepgoing parser returned invalid result", 0, path)])
end function
