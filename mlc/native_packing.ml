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

//! Dependency-free packing for compiler-generated fixed-address PE and ELF.
package mlc.native_packing
import std.compress.lz4 as lz4
import std.checksum.crc32 as crc
import mlc.tools as t
import mlc.pack_loader_bytes as loaders

const IMAGE_LIMIT = 1073741824
const MAGIC = "MLNPACK1"
const FOOTER_SIZE = 48

/// Align a positive file offset or virtual address to a power-of-two boundary.
/// @param value Offset or address to align.
/// @param alignment Required power-of-two alignment.
function _align(value, alignment)
  return ((value + alignment - 1) div alignment) * alignment
end function

/// Read little-endian fields only after the caller has checked their bounds.
/// @param data Source byte array.
/// @param offset Start of the 16-bit field.
function _u16(data, offset)
  return data[offset] | (data[offset + 1] << 8)
end function

/// Read a little-endian 32-bit field from a validated span.
/// @param data Source byte array.
/// @param offset Start of the field.
function _u32(data, offset)
  return data[offset] | (data[offset + 1] << 8) | (data[offset + 2] << 16) | (data[offset + 3] << 24)
end function

/// Read a little-endian 64-bit field from a validated span.
/// @param data Source byte array.
/// @param offset Start of the field.
function _u64(data, offset)
  return _u32(data, offset) | (_u32(data, offset + 4) << 32)
end function

/// Overwrite fixed-size integer fields without growing the image buffer.
/// @param data Image byte array to update.
/// @param offset Start of the 16-bit field.
/// @param value Unsigned value to store.
function _set16(data, offset, value)
  data[offset] = value & 255
  data[offset + 1] = (value >> 8) & 255
  return data
end function

/// Store a little-endian 32-bit field in an existing image.
/// @param data Image byte array to update.
/// @param offset Start of the field.
/// @param value Unsigned value to store.
function _set32(data, offset, value)
  copyBytes(data, offset, t.u32(value), 0, 4)
  return data
end function

/// Store a little-endian 64-bit field in an existing image.
/// @param data Image byte array to update.
/// @param offset Start of the field.
/// @param value Unsigned value to store.
function _set64(data, offset, value)
  copyBytes(data, offset, t.u64(value), 0, 8)
  return data
end function

/// Replace all eight-byte parameter markers in one checked-in loader image.
/// @param template Original loader bytes with placeholder markers.
/// @param values Addresses and lengths for the startup loader.
function _patch_loader(template, values)
  result = slice(template, 0, len(template))
  for i = 0 to 8
    marker = bytes(8, (i + 1) * 17)
    found = -1
    for at = 0 to len(result) - 8
      if slice(result, at, 8) == marker then found = at; break end if
    end for
    if found < 0 then return error(1, "invalid embedded pack loader marker") end if
    result = _set64(result, found, values[i])
  end for
  return result
end function

/// Mirror the embedded loader's 32-bit FNV-1a payload check.
/// @param data Compressed code bytes to hash.
function _fnv32(data)
  result = 2166136261
  for i = 0 to len(data) - 1
    result = ((result ^ data[i]) * 16777619) & 0xFFFFFFFF
  end for
  return result
end function

/// Enumerate the six fixed fields of each original PE section header.
/// @param image Compiler-generated PE image bytes.
function _pe_sections(image)
  if len(image) < 1024 or slice(image, 0, 2) != bytes("MZ") then return error(1, "invalid PE image") end if
  pe = _u32(image, 60)
  if pe < 64 or pe + 264 > len(image) then return error(1, "invalid PE header") end if
  if slice(image, pe, 4) != bytes([80, 69, 0, 0]) then return error(1, "invalid PE signature") end if
  if _u16(image, pe + 4) != 0x8664 or _u16(image, pe + 24) != 0x20B then return error(1, "only x64 PE32+ is supported") end if
  count = _u16(image, pe + 6)
  if count < 5 or count > 12 then return error(1, "unsupported PE sections") end if
  start = pe + 264
  if start + count * 40 > len(image) then return error(1, "truncated PE section headers") end if
  rows = []
  for i = 0 to count - 1
    pos = start + i * 40
    rows = rows + [[slice(image, pos, 8), _u32(image, pos + 8), _u32(image, pos + 12), _u32(image, pos + 16), _u32(image, pos + 20), _u32(image, pos + 36)]]
  end for
  return [pe, rows]
end function

/// Convert an original PE import RVA to its file offset.
/// @param rows Parsed PE section descriptions.
/// @param rva Virtual address relative to the image base.
function _pe_file_offset(rows, rva)
  for each row in rows
    size = row[1]
    if row[3] > size then size = row[3] end if
    if rva >= row[2] and rva < row[2] + size then return row[4] + rva - row[2] end if
  end for
  return -1
end function

/// Locate the loader's two existing kernel32 IAT slots by imported symbol.
/// @param image PE image bytes.
/// @param pe File offset of the PE header.
/// @param rows Parsed PE section descriptions.
function _pe_loader_imports(image, pe, rows)
  import_rva = _u32(image, pe + 24 + 120)
  descriptor = _pe_file_offset(rows, import_rva)
  if descriptor < 0 then return error(1, "PE import directory is missing") end if
  protect = -1
  exit_process = -1
  steps = 0
  while descriptor + 20 <= len(image) and steps < 64
    original_thunk = _u32(image, descriptor)
    name_rva = _u32(image, descriptor + 12)
    first_thunk = _u32(image, descriptor + 16)
    if name_rva == 0 then break end if
    thunk_offset = _pe_file_offset(rows, original_thunk)
    if thunk_offset < 0 then return error(1, "invalid PE import thunk") end if
    for i = 0 to 255
      if thunk_offset + i * 8 + 8 > len(image) then return error(1, "truncated PE import thunk") end if
      name_entry = _u64(image, thunk_offset + i * 8)
      if name_entry == 0 then break end if
      name_offset = _pe_file_offset(rows, name_entry)
      if name_offset < 0 or name_offset + 2 + 15 > len(image) then return error(1, "invalid PE import name") end if
      if slice(image, name_offset + 2, 14) == bytes("VirtualProtect") then protect = first_thunk + i * 8 end if
      if slice(image, name_offset + 2, 11) == bytes("ExitProcess") then exit_process = first_thunk + i * 8 end if
    end for
    descriptor = descriptor + 20
    steps = steps + 1
  end while
  if protect < 0 or exit_process < 0 then return error(1, "rebuild with a compiler that imports VirtualProtect before native packing") end if
  return [protect, exit_process]
end function

/// Build a PE with unchanged original RVAs and a separate unpacking entry.
/// @param original Compiler-generated PE image bytes.
function _pack_pe(original)
  parsed = try(_pe_sections(original))
  if typeof(parsed) == "error" then return parsed end if
  pe = parsed[0]
  rows = parsed[1]
  opt = pe + 24
  count = len(rows)
  if count != 5 then return error(1, "only compiler-generated five-section PE images can be packed") end if
  header_size = _u32(original, opt + 60)
  file_align = _u32(original, opt + 36)
  section_align = _u32(original, opt + 32)
  if file_align != 512 or section_align != 4096 or header_size < pe + 264 + (count + 2) * 40 or header_size > 4096 then return error(1, "unsupported PE layout") end if
  text_row = rows[0]
  if slice(text_row[0], 0, 5) != bytes(".text") or text_row[4] != header_size or text_row[3] <= 0 or text_row[4] + text_row[3] > len(original) then return error(1, "invalid original PE text") end if
  imports = try(_pe_loader_imports(original, pe, rows))
  if typeof(imports) == "error" then return imports end if
  compressed = try(lz4.encode(slice(original, text_row[4], text_row[3])))
  if typeof(compressed) == "error" then return compressed end if
  loader_va = 0
  for each row in rows
    ending = _align(row[2] + row[1], section_align)
    if ending > loader_va then loader_va = ending end if
  end for
  template = loaders.windows()
  packed_va = _align(loader_va + len(template), section_align)
  base = _u64(original, opt + 24)
  entry = _u32(original, opt + 16)
  stub = try(_patch_loader(template, [base + packed_va, base + text_row[2], text_row[3], len(compressed), base + entry, base + imports[0], base + imports[1], _align(text_row[1], section_align), _fnv32(compressed)]))
  if typeof(stub) == "error" then return stub end if
  cursor = header_size
  new_rows = []
  new_rows = new_rows + [[text_row[0], text_row[1], text_row[2], 0, 0, text_row[5]]]
  for i = 1 to count - 1
    row = rows[i]
    new_rows = new_rows + [[row[0], row[1], row[2], row[3], cursor, row[5]]]
    cursor = cursor + row[3]
  end for
  stub_raw = _align(len(stub), file_align)
  packed_raw = _align(len(compressed), file_align)
  new_rows = new_rows + [[bytes([46, 108, 111, 97, 100, 101, 114, 0]), len(stub), loader_va, stub_raw, cursor, 0x60000020]]
  stub_off = cursor
  cursor = cursor + stub_raw
  new_rows = new_rows + [[bytes([46, 112, 97, 99, 107, 101, 100, 0]), len(compressed), packed_va, packed_raw, cursor, 0x40000040]]
  packed_off = cursor
  cursor = cursor + packed_raw
  image = bytes(cursor, 0)
  copyBytes(image, 0, original, 0, header_size)
  for i = 1 to count - 1
    row = rows[i]
    if row[3] > 0 then
      if row[4] + row[3] > len(original) then return error(1, "invalid original PE section") end if
      copyBytes(image, new_rows[i][4], original, row[4], row[3])
    end if
  end for
  copyBytes(image, stub_off, stub, 0, len(stub))
  copyBytes(image, packed_off, compressed, 0, len(compressed))
  for i = 0 to len(new_rows) - 1
    row = new_rows[i]
    pos = pe + 264 + i * 40
    copyBytes(image, pos, row[0], 0, 8)
    image = _set32(image, pos + 8, row[1])
    image = _set32(image, pos + 12, row[2])
    image = _set32(image, pos + 16, row[3])
    image = _set32(image, pos + 20, row[4])
    image = _set32(image, pos + 36, row[5])
  end for
  image = _set16(image, pe + 6, len(new_rows))
  image = _set32(image, opt + 16, loader_va)
  image = _set32(image, opt + 56, _align(packed_va + len(compressed), section_align))
  return [image, text_row[4], text_row[3], packed_off, len(compressed)]
end function

/// Read generated ELF64 program headers, including the dynamic loader records.
/// @param image Compiler-generated ELF image bytes.
function _elf_rows(image)
  if len(image) < 4096 or slice(image, 0, 4) != bytes([127, 69, 76, 70]) then return error(1, "invalid ELF image") end if
  if image[4] != 2 or image[5] != 1 or _u16(image, 16) != 2 or _u16(image, 18) != 62 then return error(1, "only fixed-address x64 ELF is supported") end if
  phoff = _u64(image, 32)
  count = _u16(image, 56)
  if phoff != 64 or (count != 4 and count != 6 and count != 8) or phoff + (count + 2) * 56 > 4096 then return error(1, "unsupported ELF program headers") end if
  rows = []
  for i = 0 to count - 1
    pos = phoff + i * 56
    rows = rows + [[_u32(image, pos), _u32(image, pos + 4), _u64(image, pos + 8), _u64(image, pos + 16), _u64(image, pos + 24), _u64(image, pos + 32), _u64(image, pos + 40), _u64(image, pos + 48)]]
  end for
  return rows
end function

/// Keep original virtual addresses so all text/data references remain valid.
/// @param original Compiler-generated ELF image bytes.
function _pack_elf(original)
  rows = try(_elf_rows(original))
  if typeof(rows) == "error" then return rows end if
  if len(rows) != 4 and len(rows) != 6 then return error(1, "ELF image is already packed") end if
  header_index = -1
  text_index = -1
  for i = 0 to len(rows) - 1
    row = rows[i]
    if row[0] == 1 and row[2] == 0 then header_index = i end if
    if row[0] == 1 and row[1] == 5 then text_index = i end if
  end for
  if header_index < 0 or text_index < 0 then return error(1, "unsupported ELF load segments") end if
  text_row = rows[text_index]
  if text_row[2] != 4096 or text_row[5] <= 0 or text_row[5] != text_row[6] or text_row[2] + text_row[5] > len(original) then return error(1, "invalid original ELF text") end if
  compressed = try(lz4.encode(slice(original, text_row[2], text_row[5])))
  if typeof(compressed) == "error" then return compressed end if
  new_rows = []
  for each row in rows
    new_rows = new_rows + [[row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7]]]
  end for
  cursor = 4096
  for i = 0 to len(rows) - 1
    old_row = rows[i]
    if i == text_index then
      new_row = new_rows[i]
      new_row[2] = 4096
      new_row[5] = 0
      new_rows[i] = new_row
    else if old_row[0] == 1 and i != header_index then
      new_offset = _align(cursor, 4096)
      cursor = new_offset + old_row[5]
      new_row = new_rows[i]
      new_row[2] = new_offset
      new_rows[i] = new_row
      for j = 0 to len(rows) - 1
        other = rows[j]
        if (other[0] == 2 or other[0] == 3) and other[2] >= old_row[2] and other[2] < old_row[2] + old_row[5] then
          changed = new_rows[j]
          changed[2] = new_offset + other[2] - old_row[2]
          new_rows[j] = changed
        end if
      end for
    end if
  end for
  loader_va = 0
  for each row in rows
    if row[0] == 1 and row[3] + row[6] > loader_va then loader_va = row[3] + row[6] end if
  end for
  loader_va = _align(loader_va, 4096)
  template = loaders.linux()
  loader_off = _align(cursor, 4096)
  cursor = loader_off + len(template)
  packed_va = _align(loader_va + len(template), 4096)
  packed_off = _align(cursor, 4096)
  cursor = packed_off + len(compressed)
  stub = try(_patch_loader(template, [packed_va, text_row[3], text_row[5], len(compressed), _u64(original, 24), 0, 0, _align(text_row[6], 4096), _fnv32(compressed)]))
  if typeof(stub) == "error" then return stub end if
  new_rows = new_rows + [[1, 5, loader_off, loader_va, loader_va, len(stub), len(stub), 4096]]
  new_rows = new_rows + [[1, 4, packed_off, packed_va, packed_va, len(compressed), len(compressed), 4096]]
  image = bytes(cursor, 0)
  copyBytes(image, 0, original, 0, 4096)
  for i = 0 to len(rows) - 1
    row = rows[i]
    if row[0] == 1 and i != header_index and i != text_index then
      if row[2] + row[5] > len(original) then return error(1, "invalid original ELF segment") end if
      copyBytes(image, new_rows[i][2], original, row[2], row[5])
    end if
  end for
  copyBytes(image, loader_off, stub, 0, len(stub))
  copyBytes(image, packed_off, compressed, 0, len(compressed))
  image = _set64(image, 24, loader_va)
  image = _set16(image, 56, len(new_rows))
  for i = 0 to len(new_rows) - 1
    row = new_rows[i]
    pos = 64 + i * 56
    image = _set32(image, pos, row[0])
    image = _set32(image, pos + 4, row[1])
    for j = 2 to 7 image = _set64(image, pos + 8 + (j - 2) * 8, row[j]) end for
  end for
  return [image, text_row[2], text_row[5], packed_off, len(compressed)]
end function

/// Restore a native-packed image exactly, including original file padding.
/// This is also run before publication to prove the supported layout roundtrips.
/// @param image Complete packed PE or ELF bytes.
function unpackImage(image)
  length = len(image)
  if length < FOOTER_SIZE or slice(image, length - 8, 8) != bytes(MAGIC) then return error(1, "not a native MiniLang packed image") end if
  meta = length - FOOTER_SIZE
  original_size = _u32(image, meta)
  text_off = _u32(image, meta + 4)
  text_size = _u32(image, meta + 8)
  packed_off = _u32(image, meta + 12)
  packed_size = _u32(image, meta + 16)
  base_size = _u32(image, meta + 20)
  prefix_size = _u32(image, meta + 24)
  original_crc = _u32(image, meta + 28)
  base_crc = _u32(image, meta + 32)
  prefix_crc = _u32(image, meta + 36)
  if original_size <= 0 or original_size > IMAGE_LIMIT or base_size <= 0 or base_size > IMAGE_LIMIT or prefix_size <= 0 or prefix_size > 4096 then return error(1, "invalid packed image lengths") end if
  if base_size + prefix_size + FOOTER_SIZE != length or text_off != prefix_size or text_size > original_size - text_off or packed_off > base_size or packed_size > base_size - packed_off then return error(1, "invalid packed image spans") end if
  base = slice(image, 0, base_size)
  prefix = slice(image, base_size, prefix_size)
  if crc.compute(base) != base_crc or crc.compute(prefix) != prefix_crc then return error(1, "packed image checksum mismatch") end if
  decoded = try(lz4.decode(slice(base, packed_off, packed_size), text_size))
  if typeof(decoded) == "error" then return error(1, "invalid packed text block") end if
  result = bytes(original_size, 0)
  copyBytes(result, 0, prefix, 0, prefix_size)
  copyBytes(result, text_off, decoded, 0, text_size)
  if slice(prefix, 0, 2) == bytes("MZ") then
    old_parsed = try(_pe_sections(prefix))
    new_parsed = try(_pe_sections(base))
    if typeof(old_parsed) == "error" or typeof(new_parsed) == "error" then return error(1, "invalid packed PE sections") end if
    old_rows = old_parsed[1]
    new_rows = new_parsed[1]
    for each old_row in old_rows
      if slice(old_row[0], 0, 5) == bytes(".text") or old_row[3] == 0 then continue end if
      found = false
      for each new_row in new_rows
        if old_row[0] != new_row[0] then continue end if
        if old_row[3] != new_row[3] or old_row[4] + old_row[3] > original_size or new_row[4] + old_row[3] > base_size then return error(1, "invalid packed PE section") end if
        copyBytes(result, old_row[4], base, new_row[4], old_row[3])
        found = true
        break
      end for
      if found == false then return error(1, "missing packed PE section") end if
    end for
  else if slice(prefix, 0, 4) == bytes([127, 69, 76, 70]) then
    old_rows = try(_elf_rows(prefix))
    new_rows = try(_elf_rows(base))
    if typeof(old_rows) == "error" or typeof(new_rows) == "error" then return error(1, "invalid packed ELF segments") end if
    for each old_row in old_rows
      if old_row[0] != 1 or old_row[2] == 0 or old_row[1] == 5 then continue end if
      found = false
      for each new_row in new_rows
        if new_row[0] != 1 or old_row[3] != new_row[3] then continue end if
        if old_row[5] != new_row[5] or old_row[2] + old_row[5] > original_size or new_row[2] + old_row[5] > base_size then return error(1, "invalid packed ELF segment") end if
        copyBytes(result, old_row[2], base, new_row[2], old_row[5])
        found = true
        break
      end for
      if found == false then return error(1, "missing packed ELF segment") end if
    end for
  else
    return error(1, "invalid original image header")
  end if
  if crc.compute(result) != original_crc then return error(1, "restored image checksum mismatch") end if
  return result
end function

/// Compress only code; leave OS imports and dynamic linker tables readable.
/// No external compressor or decompression library is used on either host.
/// @param original Compiler-generated PE or ELF bytes.
function packImage(original)
  if typeof(original) != "bytes" or len(original) <= 0 or len(original) > IMAGE_LIMIT then return error(1, "invalid input image size") end if
  if len(original) >= 8 and slice(original, len(original) - 8, 8) == bytes(MAGIC) then return error(1, "image is already packed") end if
  layout = void
  if slice(original, 0, 2) == bytes("MZ") then
    layout = try(_pack_pe(original))
  else if slice(original, 0, 4) == bytes([127, 69, 76, 70]) then
    layout = try(_pack_elf(original))
  else
    return error(1, "only MiniLang PE/ELF images are supported")
  end if
  if typeof(layout) == "error" then return layout end if
  base = layout[0]
  text_off = layout[1]
  text_size = layout[2]
  packed_off = layout[3]
  packed_size = layout[4]
  prefix = slice(original, 0, text_off)
  size = len(base) + len(prefix) + FOOTER_SIZE
  if size >= len(original) then return error(1, "packing would not make this executable smaller") end if
  output = bytes(size, 0)
  copyBytes(output, 0, base, 0, len(base))
  copyBytes(output, len(base), prefix, 0, len(prefix))
  meta = size - FOOTER_SIZE
  values = [len(original), text_off, text_size, packed_off, packed_size, len(base), len(prefix), crc.compute(original), crc.compute(base), crc.compute(prefix)]
  for i = 0 to 9 output = _set32(output, meta + i * 4, values[i]) end for
  copyBytes(output, size - 8, bytes(MAGIC), 0, 8)
  restored = try(unpackImage(output))
  if typeof(restored) == "error" or restored != original then return error(1, "packed image did not roundtrip") end if
  return output
end function
