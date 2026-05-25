package mlc.pe
import mlc.tools as t

const KERNEL32 = "kernel32.dll"
const MSVCRT = "msvcrt.dll"

const IMAGE_SCN_CNT_CODE = 0x00000020
const IMAGE_SCN_CNT_INITIALIZED_DATA = 0x00000040
const IMAGE_SCN_CNT_UNINITIALIZED_DATA = 0x00000080

struct PESection
  name,
  data,
  characteristics,
  virt_addr,
  virt_size,
  raw_addr,
  raw_size,
end struct

struct PEBuilder
  image_base,
  section_alignment,
  file_alignment,
  sections,
  entry_rva,
  import_rva,
  import_size,
  subsystem,
end struct

struct NamedInt
  name,
  value,
end struct

struct ImportDll
  dll,
  funcs,
end struct

struct IatSymbol
  dll,
  func,
  rva,
end struct

struct IdataResult
  data,
  import_dir_rva,
  idata_total_size,
  iat_symbols,
end struct

function _bytes_from_array(arr)
  b = bytes(len(arr), 0)
  if len(arr) <= 0 then return b end if
  for i = 0 to len(arr) - 1
    b[i] = arr[i] & 0xFF
  end for
  return b
end function

function _bytes_pad_to(b, size)
  if len(b) >= size then return b end if
  return b + bytes(size - len(b), 0)
end function

function _bytes_ljust(b, size)
  return _bytes_pad_to(b, size)
end function

function _bytes_write_at(dst, offset, src)
  if len(src) <= 0 then return dst end if
  copyBytes(dst, offset, src, 0, len(src))
  return dst
end function

function _named_get(arr, name, default_value)
  if typeof(arr) == "struct" then
    return t.fastmap_get(arr, name, default_value)
  end if
  if len(arr) <= 0 then return default_value end if
  for i = 0 to len(arr) - 1
    if arr[i].name == name then return arr[i].value end if
  end for
  return default_value
end function

function _named_set(arr, name, value)
  mapv = arr
  if typeof(mapv) != "struct" then
    mapv = t.fastmap_new(64)
    if typeof(arr) == "array" and len(arr) > 0 then
      for i = 0 to len(arr) - 1
        it = arr[i]
        if typeof(it) == "struct" and typeof(it.name) == "string" then
          mapv = t.fastmap_set(mapv, it.name, it.value)
        end if
      end for
    end if
  end if
  return t.fastmap_set(mapv, name, value)
end function

function _imports_get_funcs(imports, dll)
  if len(imports) <= 0 then return [] end if
  for i = 0 to len(imports) - 1
    if imports[i].dll == dll then
      return imports[i].funcs
    end if
  end for
  return []
end function

function _section_name_bytes(name)
  nm = bytes(name)
  if len(nm) >= 8 then
    return nm
  end if
  return _bytes_ljust(nm, 8)
end function

function _next_section_raw_addr(pe)
  if len(pe.sections) <= 0 then
    return 0
  end if
  last = pe.sections[len(pe.sections) - 1]
  return last.raw_addr + last.raw_size
end function

function _find_section_by_name(pe, name)
  if len(pe.sections) <= 0 then return 0 end if
  for i = 0 to len(pe.sections) - 1
    if pe.sections[i].name == name then
      return pe.sections[i]
    end if
  end for
  return 0
end function

function newPEBuilder()
  return PEBuilder(
  0x140000000,
  0x1000,
  0x200,
  [],
  0,
  0,
  0,
  3
)
end function

function add_section(pe, name, data, characteristics)
  sec = PESection(name, data, characteristics, 0, 0, 0, 0)
  pe.sections = pe.sections +[sec]
  return pe
end function

function layout(pe)
  dos_stub = 0x80
  pe_sig = 4
  coff = 20
  opt = 0xF0
  shdr = 40 * len(pe.sections)
  headers_size = t.align_up(dos_stub + pe_sig + coff + opt + shdr, pe.file_alignment)

  rva = t.align_up(headers_size, pe.section_alignment)
  raw = headers_size

  if len(pe.sections) > 0 then
    for i = 0 to len(pe.sections) - 1
      sec = pe.sections[i]
      sec.virt_addr = rva
      if sec.virt_size == 0 then
        sec.virt_size = len(sec.data)
      end if
      sec.raw_addr = raw
      sec.raw_size = t.align_up(len(sec.data), pe.file_alignment)
      pe.sections[i] = sec

      rva = t.align_up(rva + sec.virt_size, pe.section_alignment)
      raw = raw + sec.raw_size
    end for
  end if
  return pe
end function

function build(pe)
  pe = layout(pe)

  size_of_image = 0
  if len(pe.sections) > 0 then
    for i = 0 to len(pe.sections) - 1
      sec = pe.sections[i]
      end_rva = t.align_up(sec.virt_addr + sec.virt_size, pe.section_alignment)
      if end_rva > size_of_image then
        size_of_image = end_rva
      end if
    end for
  end if

  // DOS header
  dos = bytes("MZ")
  dos = dos + _bytes_from_array([0x90, 0x00, 0x03, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00])
  dos = dos + _bytes_from_array([0xB8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00])
  dos = _bytes_pad_to(dos, 0x3C)
  dos = dos + t.u32(0x80)
  dos = _bytes_pad_to(dos, 0x80)

  pehdr = bytes("PE\0\0")

  // COFF header
  machine = 0x8664
  num_sections = len(pe.sections)
  coffh = t.u16(machine)
  coffh = coffh + t.u16(num_sections)
  coffh = coffh + t.u32(0) + t.u32(0) + t.u32(0)
  coffh = coffh + t.u16(0xF0)
  coffh = coffh + t.u16(0x0022)

  // Optional header (PE32+)
  magic = 0x20B
  major_linker = 14
  minor_linker = 0

  size_code = 0
  size_init_data = 0
  size_uninit_data = 0
  if len(pe.sections) > 0 then
    for i = 0 to len(pe.sections) - 1
      sec = pe.sections[i]
      vs = t.align_up(sec.virt_size, pe.section_alignment)
      if (sec.characteristics & IMAGE_SCN_CNT_CODE) != 0 then
        size_code = size_code + vs
      end if
      if (sec.characteristics & IMAGE_SCN_CNT_INITIALIZED_DATA) != 0 then
        size_init_data = size_init_data + vs
      end if
      if (sec.characteristics & IMAGE_SCN_CNT_UNINITIALIZED_DATA) != 0 then
        size_uninit_data = size_uninit_data + vs
      end if
    end for
  end if

  addr_entry = pe.entry_rva
  base_of_code = 0
  tsec = _find_section_by_name(pe, ".text")
  if typeof(tsec) == "struct" then
    base_of_code = tsec.virt_addr
  end if

  size_headers = t.align_up(0x80 + 4 + 20 + 0xF0 + 40 * len(pe.sections), pe.file_alignment)
  subsystem = pe.subsystem
  if subsystem == 0 then subsystem = 3 end if
  dll_chars = 0x0100 | 0x8000

  opt = bytes(0)
  opt = opt + t.u16(magic)
  opt = opt + _bytes_from_array([major_linker & 0xFF, minor_linker & 0xFF])
  opt = opt + t.u32(size_code)
  opt = opt + t.u32(size_init_data)
  opt = opt + t.u32(size_uninit_data)
  opt = opt + t.u32(addr_entry)
  opt = opt + t.u32(base_of_code)
  opt = opt + t.u64(pe.image_base)
  opt = opt + t.u32(pe.section_alignment)
  opt = opt + t.u32(pe.file_alignment)
  opt = opt + t.u16(6) + t.u16(0) + t.u16(0) + t.u16(0) + t.u16(6) + t.u16(0)
  opt = opt + t.u32(0)
  opt = opt + t.u32(size_of_image)
  opt = opt + t.u32(size_headers)
  opt = opt + t.u32(0)
  opt = opt + t.u16(subsystem) + t.u16(dll_chars)
  opt = opt + t.u64(0x100000)
  opt = opt + t.u64(0x1000)
  opt = opt + t.u64(0x100000)
  opt = opt + t.u64(0x1000)
  opt = opt + t.u32(0)
  opt = opt + t.u32(16)

  for i = 0 to 15
    rva = 0
    sz = 0
    if i == 1 then
      rva = pe.import_rva
      sz = pe.import_size
    end if
    opt = opt + t.u32(rva)
    opt = opt + t.u32(sz)
  end for

  if len(opt) != 0xF0 then
    return error(1, "Optional header size mismatch")
  end if

  // section headers
  sh = bytes(0)
  if len(pe.sections) > 0 then
    for i = 0 to len(pe.sections) - 1
      sec = pe.sections[i]
      sh = sh + _section_name_bytes(sec.name)
      sh = sh + t.u32(sec.virt_size)
      sh = sh + t.u32(sec.virt_addr)
      sh = sh + t.u32(sec.raw_size)
      sh = sh + t.u32(sec.raw_addr)
      sh = sh + t.u32(0) + t.u32(0)
      sh = sh + t.u16(0) + t.u16(0)
      sh = sh + t.u32(sec.characteristics)
    end for
  end if

  header = dos + pehdr + coffh + opt + sh

  total_size = size_headers
  if len(pe.sections) > 0 then
    for i = 0 to len(pe.sections) - 1
      sec = pe.sections[i]
      end_pos = sec.raw_addr + sec.raw_size
      if end_pos > total_size then total_size = end_pos end if
    end for
  end if

  image = bytes(total_size, 0)
  image = _bytes_write_at(image, 0, header)

  if len(pe.sections) > 0 then
    for i = 0 to len(pe.sections) - 1
      sec = pe.sections[i]
      if sec.raw_size <= 0 then continue end if
      image = _bytes_write_at(image, sec.raw_addr, sec.data)
    end for
  end if

  return image
end function

function build_idata(imports, base_rva)
  dlls_b = t.arr_chunk_new(32)
  if len(imports) > 0 then
    for i = 0 to len(imports) - 1
      dlls_b = t.arr_chunk_push(dlls_b, imports[i].dll)
    end for
  end if
  dlls = t.arr_chunk_finish(dlls_b)

  desc_count = len(dlls)
  buf_p = t.byte_pages_new()
  buf_p = t.byte_pages_append(buf_p, bytes(20 *(desc_count + 1), 0))

  ilt_rva = t.fastmap_new(64)
  iat_rva = t.fastmap_new(64)
  dll_name_rva = t.fastmap_new(64)
  hn_rva = t.fastmap_new(256)
  iat_symbols_b = t.arr_chunk_new(64)

  // ILT
  if len(dlls) > 0 then
    for di = 0 to len(dlls) - 1
      dll = dlls[di]
      cur = base_rva + t.byte_pages_len(buf_p)
      ilt_rva = _named_set(ilt_rva, dll, cur)
      funcs = _imports_get_funcs(imports, dll)
      buf_p = t.byte_pages_append(buf_p, bytes(8 *(len(funcs) + 1), 0))
    end for
  end if

  // IAT
  if len(dlls) > 0 then
    for di = 0 to len(dlls) - 1
      dll = dlls[di]
      cur = base_rva + t.byte_pages_len(buf_p)
      iat_rva = _named_set(iat_rva, dll, cur)
      funcs = _imports_get_funcs(imports, dll)
      base_iat = cur
      if len(funcs) > 0 then
        for fi = 0 to len(funcs) - 1
          iat_symbols_b = t.arr_chunk_push(iat_symbols_b, IatSymbol(dll, funcs[fi], base_iat + fi * 8))
        end for
      end if
      buf_p = t.byte_pages_append(buf_p, bytes(8 *(len(funcs) + 1), 0))
    end for
  end if
  iat_symbols = t.arr_chunk_finish(iat_symbols_b)

  // DLL names
  if len(dlls) > 0 then
    for di = 0 to len(dlls) - 1
      dll = dlls[di]
      dll_name_rva = _named_set(dll_name_rva, dll, base_rva + t.byte_pages_len(buf_p))
      buf_p = t.byte_pages_append(buf_p, bytes(dll))
      buf_p = t.byte_pages_append(buf_p, bytes(1, 0))
    end for
  end if

  // Hint/Name entries
  if len(dlls) > 0 then
    for di = 0 to len(dlls) - 1
      dll = dlls[di]
      funcs = _imports_get_funcs(imports, dll)
      if len(funcs) > 0 then
        for fi = 0 to len(funcs) - 1
          fn = funcs[fi]
          key = dll +"|" + fn
          hn_rva = _named_set(hn_rva, key, base_rva + t.byte_pages_len(buf_p))
          buf_p = t.byte_pages_append(buf_p, t.u16(0))
          buf_p = t.byte_pages_append(buf_p, bytes(fn))
          buf_p = t.byte_pages_append(buf_p, bytes(1, 0))
          if (t.byte_pages_len(buf_p) % 2) == 1 then
            buf_p = t.byte_pages_append(buf_p, bytes(1, 0))
          end if
        end for
      end if
    end for
  end if

  // Patch ILT/IAT entries
  if len(dlls) > 0 then
    for di = 0 to len(dlls) - 1
      dll = dlls[di]
      funcs = _imports_get_funcs(imports, dll)
      ilt_start = _named_get(ilt_rva, dll, 0) - base_rva
      iat_start = _named_get(iat_rva, dll, 0) - base_rva
      if len(funcs) > 0 then
        for fi = 0 to len(funcs) - 1
          fn = funcs[fi]
          key = dll +"|" + fn
          entry = _named_get(hn_rva, key, 0)
          buf_p = t.byte_pages_write_at(buf_p, ilt_start + fi * 8, t.u64(entry))
          buf_p = t.byte_pages_write_at(buf_p, iat_start + fi * 8, t.u64(entry))
        end for
      end if
    end for
  end if

  // Import descriptors
  if len(dlls) > 0 then
    for di = 0 to len(dlls) - 1
      dll = dlls[di]
      d_off = di * 20
      orig_first_thunk = _named_get(ilt_rva, dll, 0)
      name_rva = _named_get(dll_name_rva, dll, 0)
      first_thunk = _named_get(iat_rva, dll, 0)
      desc = t.u32(orig_first_thunk)
      desc = desc + t.u32(0) + t.u32(0)
      desc = desc + t.u32(name_rva)
      desc = desc + t.u32(first_thunk)
      buf_p = t.byte_pages_write_at(buf_p, d_off, desc)
    end for
  end if

  buf = t.byte_pages_to_bytes(buf_p)
  import_dir_rva = base_rva
  return IdataResult(buf, import_dir_rva, len(buf), iat_symbols)
end function
