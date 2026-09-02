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

// Deterministic fixed-address ELF64 image writer for Linux x86-64.
//! Provides the mlc elf package.

package mlc.elf
import mlc.tools as t

/// Represents elflayout.
struct ELFLayout
  /// Stores the base member of `ELFLayout`.
  base,
  /// Stores the text off member of `ELFLayout`.
  text_off,
  /// Stores the rdata off member of `ELFLayout`.
  rdata_off,
  /// Stores the data off member of `ELFLayout`.
  data_off,
  /// Stores the dynamic off member of `ELFLayout`.
  dynamic_off,
  /// Stores the bss off member of `ELFLayout`.
  bss_off,
end struct

/// Represents dynamic blob.
struct DynamicBlob
  /// Stores the data member of `DynamicBlob`.
  data,
  /// Stores the interp offset member of `DynamicBlob`.
  interp_offset,
  /// Stores the interp size member of `DynamicBlob`.
  interp_size,
  /// Stores the table offset member of `DynamicBlob`.
  table_offset,
  /// Stores the table size member of `DynamicBlob`.
  table_size,
end struct

/// Represents string offset.
struct StringOffset
  /// Stores the value member of `StringOffset`.
  value,
  /// Stores the offset member of `StringOffset`.
  offset,
end struct

/// Lay out page-aligned load segments and keep the dynamic table adjacent to initialized data. Offsets are RVAs relative to the fixed image base.
/// @param text_size Value supplied for `text_size`.
/// @param rdata_size Value supplied for `rdata_size`.
/// @param data_size Value supplied for `data_size`.
/// @param dynamic_size Value supplied for `dynamic_size`.
function plan(text_size, rdata_size, data_size, dynamic_size)
  text_off = 0x1000
  rdata_off = t.align_up(text_off + text_size, 0x1000)
  data_off = t.align_up(rdata_off + rdata_size, 0x1000)
  dynamic_off = t.align_up(data_off + data_size, 8)
  bss_off = t.align_up(dynamic_off + dynamic_size, 16)
  return ELFLayout(0x400000, text_off, rdata_off, data_off, dynamic_off, bss_off)
end function

/// Implements array has.
/// @internal
function _array_has(values, wanted)
  if len(values) <= 0 then return false end if
  for i = 0 to len(values) - 1
    if values[i] == wanted then return true end if
  end for
  return false
end function

/// Resolve one already-interned dynamic string without allocating a map for the normally small Linux import surface.
/// @internal
function _string_offset(offsets, wanted)
  if len(offsets) <= 0 then return -1 end if
  for i = 0 to len(offsets) - 1
    if offsets[i].value == wanted then return offsets[i].offset end if
  end for
  return -1
end function

/// Extend a serialized metadata blob to the alignment required by ELF64 words.
/// @internal
function _pad_blob(blob, alignment)
  aligned = t.align_up(len(blob), alignment)
  if aligned > len(blob) then blob = blob + bytes(aligned - len(blob), 0) end if
  return blob
end function

/// Serialize PT_INTERP contents, SysV symbol/hash tables, RELA relocations and the DT_* vector as one deterministic data-segment blob. Import order remains significant because it is part of Python/self-hosted binary parity.
/// @internal
function _dynamic_blob(imports, image_base, data_off, blob_off)
  interp = bytes("/lib64/ld-linux-x86-64.so.2\0")
  blob = interp
  libraries = []
  symbols = []
  if len(imports) > 0 then
    for i = 0 to len(imports) - 1
      item = imports[i]
      if _array_has(libraries, item.library) == false then libraries = libraries + [item.library] end if
      if _array_has(symbols, item.symbol_name) == false then symbols = symbols + [item.symbol_name] end if
    end for
  end if

  blob = _pad_blob(blob, 8)
  dynstr_off = len(blob)
  dynstr = bytes(1, 0)
  offsets = []
  combined = libraries + symbols
  if len(combined) > 0 then
    for i = 0 to len(combined) - 1
      value = combined[i]
      if _string_offset(offsets, value) >= 0 then continue end if
      offsets = offsets + [StringOffset(value, len(dynstr))]
      dynstr = dynstr + bytes(value) + bytes(1, 0)
    end for
  end if
  blob = blob + dynstr

  blob = _pad_blob(blob, 8)
  dynsym_off = len(blob)
  blob = blob + bytes(24, 0)
  if len(symbols) > 0 then
    for i = 0 to len(symbols) - 1
      blob = blob + t.u32(_string_offset(offsets, symbols[i]))
      blob = blob + bytes([0x12, 0]) + t.u16(0) + t.u64(0) + t.u64(0)
    end for
  end if

  // One SysV hash bucket forms a compact valid chain for every symbol.
  blob = _pad_blob(blob, 8)
  hash_off = len(blob)
  nchain = len(symbols) + 1
  first_symbol = 0
  if len(symbols) > 0 then first_symbol = 1 end if
  blob = blob + t.u32(1) + t.u32(nchain) + t.u32(first_symbol) + t.u32(0)
  if len(symbols) > 0 then
    for i = 1 to len(symbols)
      next_symbol = 0
      if i < len(symbols) then next_symbol = i + 1 end if
      blob = blob + t.u32(next_symbol)
    end for
  end if

  blob = _pad_blob(blob, 8)
  rela_off = len(blob)
  if len(imports) > 0 then
    for i = 0 to len(imports) - 1
      item = imports[i]
      symbol_index = 0
      for si = 0 to len(symbols) - 1
        if symbols[si] == item.symbol_name then symbol_index = si + 1 end if
      end for
      relocation_offset = image_base + data_off + item.slot_offset
      relocation_info = (symbol_index << 32) | 6
      blob = blob + t.u64(relocation_offset) + t.u64(relocation_info) + t.u64(0)
    end for
  end if
  rela_size = len(imports) * 24

  blob = _pad_blob(blob, 8)
  table_off = len(blob)
  blob_addr = image_base + blob_off
  entry_count = 0
  if len(libraries) > 0 then
    for i = 0 to len(libraries) - 1
      blob = blob + t.u64(1) + t.u64(_string_offset(offsets, libraries[i]))
      entry_count = entry_count + 1
    end for
  end if
  entries = [
    [4, blob_addr + hash_off], [5, blob_addr + dynstr_off], [6, blob_addr + dynsym_off],
    [10, len(dynstr)], [11, 24], [7, blob_addr + rela_off], [8, rela_size], [9, 24], [0, 0]
  ]
  for i = 0 to len(entries) - 1
    blob = blob + t.u64(entries[i][0]) + t.u64(entries[i][1])
    entry_count = entry_count + 1
  end for
  return DynamicBlob(blob, 0, len(interp), table_off, entry_count * 16)
end function

/// Measure the exact metadata payload with the same serializer used by build().
/// @param imports Value supplied for `imports`.
function dynamic_size(imports)
  if typeof(imports) != "array" or len(imports) <= 0 then return 0 end if
  return len(_dynamic_blob(imports, 0, 0, 0).data)
end function

/// Encode one ELF64 program header. File and virtual offsets intentionally use the same fixed-address layout so no section-header table is required.
/// @internal
function _ph(kind, flags, off, filesz, memsz, base, alignment)
  return t.u32(kind) + t.u32(flags) + t.u64(off) + t.u64(base + off) +
         t.u64(base + off) + t.u64(filesz) + t.u64(memsz) + t.u64(alignment)
end function

/// Assemble a minimal deterministic ET_EXEC image with RX text, read-only data, RW initialized/BSS storage and optional dynamic-loader metadata.
/// @param text Text to process.
/// @param rdata Value supplied for `rdata`.
/// @param data Data to process.
/// @param bss_size Value supplied for `bss_size`.
/// @param entry_offset Value supplied for `entry_offset`.
/// @param imports Value supplied for `imports`.
function build(text, rdata, data, bss_size, entry_offset, imports)
  dyn_size = dynamic_size(imports)
  layout = plan(len(text), len(rdata), len(data), dyn_size)
  has_dynamic = dyn_size > 0
  dynamic = DynamicBlob(bytes(0), 0, 0, 0, 0)
  phnum = 4
  if has_dynamic then
    dynamic = _dynamic_blob(imports, layout.base, layout.data_off, layout.dynamic_off)
    phnum = 6
  end if

  ident = bytes([0x7F, 0x45, 0x4C, 0x46, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0])
  header = ident + t.u16(2) + t.u16(62) + t.u32(1)
  header = header + t.u64(layout.base + layout.text_off + entry_offset)
  header = header + t.u64(64) + t.u64(0) + t.u32(0)
  header = header + t.u16(64) + t.u16(56) + t.u16(phnum) + t.u16(0) + t.u16(0) + t.u16(0)
  data_filesz = layout.bss_off - layout.data_off
  if has_dynamic then
    header = header + _ph(3, 4, layout.dynamic_off + dynamic.interp_offset, dynamic.interp_size, dynamic.interp_size, layout.base, 1)
  end if
  header = header + _ph(1, 4, 0, layout.text_off, layout.text_off, layout.base, 0x1000)
  header = header + _ph(1, 5, layout.text_off, len(text), len(text), layout.base, 0x1000)
  header = header + _ph(1, 4, layout.rdata_off, len(rdata), len(rdata), layout.base, 0x1000)
  header = header + _ph(1, 6, layout.data_off, data_filesz, data_filesz + bss_size, layout.base, 0x1000)
  if has_dynamic then
    header = header + _ph(2, 6, layout.dynamic_off + dynamic.table_offset, dynamic.table_size, dynamic.table_size, layout.base, 8)
  end if
  if len(header) > layout.text_off then return error(1, "ELF headers overlap .text") end if

  image = bytes(layout.bss_off, 0)
  copyBytes(image, 0, header, 0, len(header))
  copyBytes(image, layout.text_off, text, 0, len(text))
  copyBytes(image, layout.rdata_off, rdata, 0, len(rdata))
  copyBytes(image, layout.data_off, data, 0, len(data))
  if has_dynamic then copyBytes(image, layout.dynamic_off, dynamic.data, 0, len(dynamic.data)) end if
  return image
end function
