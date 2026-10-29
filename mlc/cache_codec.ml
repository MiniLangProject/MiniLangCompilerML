// Copyright 2026 Nils Kopal. Licensed under the Apache License, Version 2.0.
//! Bounded data-only encoding for disposable compiler cache records.
package mlc.cache_codec
import mlc.tools as t
import std.checksum.crc32 as crc32
import std.checksum.crc32c as crc32c
import mlc.project as project

/// Compact growable encoder; small cache keys do not allocate a 64-KiB page.
struct Writer
  /// Capacity-backed bytes.
  data,
  /// Logical byte count.
  used,
  /// Whether every value has a supported representation.
  valid,
  /// AST visitor recursion depth, independent of primitive array serialization.
  ast_depth,
end struct

/// Bounded reader; no executable source or native pointers are deserialized.
struct Reader
  /// Input bytes.
  data,
  /// Next byte offset.
  pos,
  /// Whether all checks have passed.
  valid,
  /// Remaining node budget to bound malicious nesting and array expansion.
  remaining,
end struct

/// Start a new primitive-value encoder.
function writer()
  return Writer(bytes(256, 0), 0, true, 0)
end function

/// Grow geometrically with a bounded native copy, preserving only used bytes.
/// @param w Mutable primitive-value encoder.
/// @param additional Number of bytes needed by the next write.
function ensure(w, additional)
  need = w.used + additional
  if need > 67108864 then w.valid = false; return false end if
  if need <= len(w.data) then return true end if
  capacity = len(w.data)
  while capacity < need
    capacity = capacity * 2
  end while
  next_data = bytes(capacity, 0)
  if w.used > 0 then t._copy_native_bytes(nativeBytesPtr(next_data), nativeBytesPtr(w.data), w.used) end if
  w.data = next_data
  return true
end function

/// Append a little-endian scalar without a temporary bytes allocation.
/// @param w Mutable primitive-value encoder.
/// @param value Primitive value to encode or fingerprint.
/// @param width Little-endian integer width in bytes.
function appendNumber(w, value, width)
  if ensure(w, width) == false then return end if
  for i = 0 to width - 1
    w.data[w.used + i] = (value >> (i * 8)) & 255
  end for
  w.used = w.used + width
end function

/// Copy a string/bytes payload after its length has been written.
/// @param w Mutable primitive-value encoder.
/// @param value Primitive value to encode or fingerprint.
function appendPayload(w, value)
  size = len(value)
  if ensure(w, size) == false then return end if
  if size > 0 then
    source = nativeRawValue(value) + 8
    if typeof(value) == "bytes" then source = nativeBytesPtr(value) end if
    t._copy_native_bytes(nativeBytesPtr(w.data) + w.used, source, size)
  end if
  w.used = w.used + size
end function

/// Encode primitive data and arrays. Structs require an explicit projection.
/// @param w Mutable primitive-value encoder.
/// @param value Primitive value to encode or fingerprint.
function write(w, value)
  kind = typeof(value)
  if kind == "void" then
    appendNumber(w, 0, 2)
  else if kind == "bool" then
    tag = 1
    if value then tag = 2 end if
    appendNumber(w, tag, 2)
  else if kind == "int" then
    appendNumber(w, 3, 2)
    appendNumber(w, value, 8)
  else if kind == "string" then
    appendNumber(w, 4, 2)
    appendNumber(w, len(value), 4)
    appendPayload(w, value)
  else if kind == "bytes" then
    appendNumber(w, 5, 2)
    appendNumber(w, len(value), 4)
    appendPayload(w, value)
  else if kind == "array" then
    appendNumber(w, 6, 2)
    appendNumber(w, len(value), 4)
    for each item in value
      write(w, item)
    end for
  else
    w.valid = false
  end if
  return w
end function

/// Finish a record, returning void for unsupported values.
/// @param w Mutable primitive-value encoder.
function finish(w)
  if w.valid == false then return end if
  return slice(w.data, 0, w.used)
end function

/// Encode one complete primitive value.
/// @param value Primitive value to encode or fingerprint.
function encode(value)
  w = writer()
  write(w, value)
  return finish(w)
end function

/// Identify cache data using length and two independent native CRC polynomials.
/// @param data Encoded bytes to validate or copy.
function identity(data)
  if typeof(data) != "bytes" then return "" end if
  return len(data) + ":" + project._hex32(crc32.compute(data)) + ":" + project._hex32(crc32c.compute(data))
end function

/// Return a filename-safe identity for a primitive key.
/// @param value Primitive value to encode or fingerprint.
function key(value)
  raw = encode(value)
  if typeof(raw) != "bytes" then return "" end if
  return project._hex32(crc32.compute(raw)) + project._hex32(crc32c.compute(raw)) + "-" + len(raw)
end function

/// Copy a checked byte slice without per-byte interpreter work.
/// @param data Encoded bytes to validate or copy.
/// @param start First byte or record offset to include.
/// @param count Number of bytes to copy.
function slice(data, start, count)
  if typeof(data) != "bytes" or start < 0 or count < 0 or start > len(data) - count then return bytes(0) end if
  result = bytes(count, 0)
  if count > 0 then t._copy_native_bytes(nativeBytesPtr(result), nativeBytesPtr(data) + start, count) end if
  return result
end function

/// Read a small unsigned integer, validating bounds before each access.
/// @param rd Bounded reader and its remaining input budget.
/// @param width Little-endian integer width in bytes.
function number(rd, width)
  if rd.valid == false or rd.pos > len(rd.data) - width then rd.valid = false; return 0 end if
  result = 0
  for i = 0 to width - 1
    result = result | (rd.data[rd.pos + i] << (8 * i))
  end for
  rd.pos = rd.pos + width
  return result
end function

/// Decode one bounded tree. MiniLang integer payloads naturally wrap to 61 bits.
/// @param rd Bounded reader and its remaining input budget.
/// @param depth Current nesting depth in the encoded value.
function read(rd, depth)
  if depth > 128 or rd.remaining <= 0 or rd.valid == false then rd.valid = false; return end if
  rd.remaining = rd.remaining - 1
  tag = number(rd, 2)
  if tag == 0 then return end if
  if tag == 1 then return false end if
  if tag == 2 then return true end if
  if tag == 3 then return number(rd, 8) end if
  if tag == 4 or tag == 5 then
    count = number(rd, 4)
    if rd.valid == false or count < 0 or count > len(rd.data) - rd.pos then rd.valid = false; return end if
    raw = slice(rd.data, rd.pos, count)
    rd.pos = rd.pos + count
    if tag == 4 then return decode(raw) end if
    return raw
  end if
  if tag == 6 then
    count = number(rd, 4)
    if rd.valid == false or count > rd.remaining or count > (len(rd.data) - rd.pos) / 2 then rd.valid = false; return end if
    values = array(count)
    if count > 0 then
      for i = 0 to count - 1
        values[i] = read(rd, depth + 1)
        if rd.valid == false then return end if
      end for
    end if
    return values
  end if
  rd.valid = false
  return
end function

/// Decode the entire payload; trailing data and truncated records are invalid.
/// @param data Encoded bytes to validate or copy.
function decodeRecord(data)
  if typeof(data) != "bytes" or len(data) > 67108864 then return end if
  rd = Reader(data, 0, true, 2000000)
  result = read(rd, 0)
  if rd.valid == false or rd.pos != len(data) then return end if
  return result
end function
