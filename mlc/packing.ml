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

//! Optional UPX packing with a deterministic, byte-exact restoration overlay.
package mlc.packing
import std.fs as fs
import std.string as s
import std.process as process
import std.checksum.crc32 as crc
import mlc.tools as t

/// Bound all executable buffers and restoration metadata before allocation.
const IMAGE_LIMIT = 1073741824
const META_LIMIT = 16777216
const BLOCK_SIZE = 4096

/// Packing switches removed from the ordinary compiler argument vector.
struct Options
  /// Remaining compiler arguments or the standalone input/output pair.
  args,
  /// Empty, compile, pack or unpack.
  mode,
  /// Explicit trusted host UPX executable.
  upx,
end struct

#if TARGET_OS == "windows"
/// Reserve one exclusive staging directory beside the requested destination.
/// @param path UTF-16 path to a new directory.
/// @param security Optional Windows security attributes; zero uses defaults.
/// @returns True if the directory was created.
extern function _mkdir(path as wstr, security as ptr) from "kernel32.dll" symbol "CreateDirectoryW" returns bool
/// Remove only an empty, exclusively owned staging directory.
/// @param path UTF-16 path to an empty owned directory.
/// @returns True if the directory was removed.
extern function _rmdir(path as wstr) from "kernel32.dll" symbol "RemoveDirectoryW" returns bool
/// Atomically publish without replacing another file.
/// @param source UTF-16 staging-file path.
/// @param destination UTF-16 destination that must not already exist.
/// @returns True if the move completed.
extern function _move(source as wstr, destination as wstr) from "kernel32.dll" symbol "MoveFileW" returns bool
/// Atomically replace a successfully compiled, explicitly packed output.
/// @param source UTF-16 staging-file path.
/// @param destination UTF-16 compiler-owned output path.
/// @param flags Windows move options permitting replacement.
/// @returns True if publication completed.
extern function _replace(source as wstr, destination as wstr, flags as u32) from "kernel32.dll" symbol "MoveFileExW" returns bool
/// Compare bounded blocks without allocating temporary byte slices.
/// @param left First readable memory range.
/// @param right Second readable memory range.
/// @param count Number of bytes available in both ranges.
/// @returns Zero for equal bytes, otherwise their comparison order.
extern function _memcmp(left as ptr, right as ptr, count as u64) from "msvcrt.dll" symbol "memcmp" returns i32
#else
/// Reserve a private staging directory atomically.
/// @param path Native path to a new staging directory.
/// @param mode Requested POSIX permission bits, subject to umask.
/// @returns Zero on success, otherwise minus one.
extern function _mkdir(path as cstr, mode as u32) from "libc.so.6" symbol "mkdir" returns i32
/// Remove only the empty staging directory.
/// @param path Native path to an empty owned directory.
/// @returns Zero on success, otherwise minus one.
extern function _rmdir(path as cstr) from "libc.so.6" symbol "rmdir" returns i32
/// Atomic no-overwrite publication of a validated image.
/// @param source Native staging-file path.
/// @param destination Native destination that must not already exist.
/// @returns Zero on success, otherwise minus one.
extern function _link(source as cstr, destination as cstr) from "libc.so.6" symbol "link" returns i32
/// Atomic publication when compile mode explicitly replaces its own output.
/// @param source Native staging-file path.
/// @param destination Native compiler-owned output path.
/// @returns Zero on success, otherwise minus one.
extern function _rename(source as cstr, destination as cstr) from "libc.so.6" symbol "rename" returns i32
/// Read ordinary source execute/read/write permissions.
/// @param path Native path to the original executable.
/// @param output Buffer for the Linux x64 stat layout.
/// @returns Zero on success, otherwise minus one.
extern function _stat(path as cstr, output as bytes) from "libc.so.6" symbol "stat" returns i32
/// Preserve ordinary permissions, never setuid/setgid bits.
/// @param path Native staging-file path.
/// @param mode Ordinary permission bits with privilege bits excluded.
/// @returns Zero on success, otherwise minus one.
extern function _chmod(path as cstr, mode as u32) from "libc.so.6" symbol "chmod" returns i32
/// Compare bounded blocks without temporary byte slices.
/// @param left First readable memory range.
/// @param right Second readable memory range.
/// @param count Number of bytes available in both ranges.
/// @returns Zero for equal bytes, otherwise their comparison order.
extern function _memcmp(left as ptr, right as ptr, count as u64) from "libc.so.6" symbol "memcmp" returns i32
#endif

/// Decode a previously bounds-checked little-endian u32 field.
/// @param data Byte buffer whose field bounds have already been validated.
/// @param offset Zero-based byte offset of the four-byte field.
function u32at(data, offset)
  return data[offset] | (data[offset + 1] << 8) | (data[offset + 2] << 16) | (data[offset + 3] << 24)
end function

/// Parse optional packing modes before normal compilation/project caching.
/// @param args Original command-line argument vector without the executable name.
function parseOptions(args)
  result = Options([], "", "")
  i = 0
  while i < len(args)
    arg = args[i]
    if arg == "--pack" or arg == "--pack=upx" or arg == "--pack-exe" or arg == "--unpack-exe" then
      if result.mode != "" then return error(1, "packing modes are mutually exclusive") end if
      result.mode = "compile"
      if arg == "--pack-exe" then result.mode = "pack" end if
      if arg == "--unpack-exe" then result.mode = "unpack" end if
    else if arg == "--upx" then
      i = i + 1
      if i >= len(args) then return error(1, "--upx requires one executable path") end if
      if args[i] == "" or s.startsWith(args[i], "--") or result.upx != "" then return error(1, "--upx requires one executable path") end if
      result.upx = args[i]
    else if s.startsWith(arg, "--pack=") then
      return error(1, "only --pack=upx is supported")
    else
      result.args = result.args + [arg]
    end if
    i = i + 1
  end while
  if result.upx != "" and result.mode == "" then return error(1, "--upx requires a packing mode") end if
  if result.mode != "" then
    if result.upx == "" then
      env = process.environment("MINILANG_UPX")
      if typeof(env) == "string" then result.upx = env end if
    end if
    if result.upx == "" or fs.isFile(result.upx) == false then return error(1, "set --upx PATH or MINILANG_UPX to a trusted UPX executable") end if
    if result.mode != "compile" and len(result.args) != 2 then return error(1, "--pack-exe/--unpack-exe require INPUT OUTPUT") end if
  end if
  return result
end function

/// Read an image only after validating its on-disk size.
/// @param path Existing executable file to read within the image-size limit.
function readImage(path)
  size = fs.fileSize(path)
  if typeof(size) != "int" or size <= 0 or size > IMAGE_LIMIT or fs.isFile(path) == false then return error(1, "input must be a regular file between 1 byte and 1 GiB") end if
  return fs.readAllBytes(path)
end function

/// Store only original 4-KiB blocks normalized by UPX, plus whole-file CRCs.
/// CRCs detect accidental corruption; they do not authenticate hostile files.
/// @param original Unmodified executable bytes before packing.
/// @param packed UPX-packed executable bytes before adding metadata.
/// @param restored UPX-unpacked bytes used to identify normalized blocks.
function makeOverlay(original, packed, restored)
  patches = t.byte_pages_new()
  count = 0
  start = 0
  while start < len(original)
    size = len(original) - start
    if size > BLOCK_SIZE then size = BLOCK_SIZE end if
    equal = false
    if start + size <= len(restored) then equal = _memcmp(nativeBytesPtr(original) + start, nativeBytesPtr(restored) + start, size) == 0 end if
    if equal == false then
      patches = t.byte_pages_append_u32(patches, start)
      patches = t.byte_pages_append_u32(patches, size)
      patches = t.byte_pages_append(patches, slice(original, start, size))
      count = count + 1
      if t.byte_pages_len(patches) > META_LIMIT - 24 then return error(1, "UPX normalization requires too much restoration metadata") end if
    end if
    start = start + BLOCK_SIZE
  end while
  metadata = t.u32(len(original)) + t.u32(len(packed)) + t.u32(len(restored)) + t.u32(crc.compute(original)) + t.u32(crc.compute(packed)) + t.u32(count) + t.byte_pages_to_bytes(patches)
  return metadata + bytes("MLPACK01") + t.u32(len(metadata)) + t.u32(crc.compute(metadata))
end function

/// Validate lengths, checksums and all sorted non-overlapping restoration blocks
/// before running UPX. Only trusted executables belong in this workflow.
/// @param image Packed executable bytes including the restoration footer.
function parseOverlay(image)
  length = len(image)
  if length < 40 then return error(1, "not a MiniLang packed executable") end if
  if slice(image, length - 16, 8) != bytes("MLPACK01") then return error(1, "not a MiniLang packed executable") end if
  size = u32at(image, length - 8)
  checksum = u32at(image, length - 4)
  if size < 24 or size > META_LIMIT or size > length - 16 then return error(1, "invalid restoration metadata length") end if
  metadata = slice(image, length - 16 - size, size)
  if crc.compute(metadata) != checksum then return error(1, "restoration metadata checksum mismatch") end if
  original_size = u32at(metadata, 0)
  packed_size = u32at(metadata, 4)
  restored_size = u32at(metadata, 8)
  original_crc = u32at(metadata, 12)
  packed_crc = u32at(metadata, 16)
  count = u32at(metadata, 20)
  if original_size <= 0 or original_size > IMAGE_LIMIT or restored_size <= 0 or restored_size > IMAGE_LIMIT or packed_size <= 0 or packed_size != length - size - 16 then return error(1, "invalid packed image lengths") end if
  packed = slice(image, 0, packed_size)
  if crc.compute(packed) != packed_crc then return error(1, "packed image checksum mismatch") end if
  if count > (size - 24) div 9 then return error(1, "invalid restoration record count") end if
  patches = t.arr_vec_new(16)
  cursor = 24
  last_end = 0
  i = 0
  while i < count
    if cursor + 8 > size then return error(1, "truncated restoration record") end if
    start = u32at(metadata, cursor)
    part_size = u32at(metadata, cursor + 4)
    cursor = cursor + 8
    if part_size <= 0 or part_size > BLOCK_SIZE or start < last_end or start + part_size > original_size or cursor + part_size > size then return error(1, "invalid restoration block") end if
    patches = t.arr_vec_push(patches, [start, slice(metadata, cursor, part_size)])
    cursor = cursor + part_size
    last_end = start + part_size
    i = i + 1
  end while
  if cursor != size then return error(1, "trailing restoration data") end if
  return [packed, original_size, restored_size, original_crc, t.arr_vec_finish(patches)]
end function

/// Restore original bytes, including header/import-table normalization by UPX.
/// @param restored Raw bytes produced by the UPX decompressor.
/// @param info Validated restoration metadata returned by the overlay parser.
function restoreImage(restored, info)
  if len(restored) != info[2] then return error(1, "unexpected UPX unpacked size") end if
  output = bytes(info[1], 0)
  size = len(restored)
  if size > len(output) then size = len(output) end if
  copyBytes(output, 0, restored, 0, size)
  for each patch in info[4] copyBytes(output, patch[0], patch[1], 0, len(patch[1])) end for
  if crc.compute(output) != info[3] then return error(1, "restored executable checksum mismatch") end if
  return output
end function

/// Create an exclusive sibling directory; never reuse another invocation's files.
/// @param destination Output path whose parent will hold private staging files.
function stageDirectory(destination)
  for index = 0 to 99
    path = destination + ".mlpack-" + process.id() + "-" + index
#if TARGET_OS == "windows"
    if _mkdir(path, 0) then return path end if
#else
    if _mkdir(path, 448) == 0 then return path end if
#endif
  end for
  return error(1, "cannot create private packing directory")
end function

/// Remove only four exact private files and their empty parent; no recursion.
/// @param folder Exclusively owned staging directory to remove if empty.
function cleanup(folder)
  for each name in ["payload.bin", "packed.bin", "roundtrip.bin", "result.bin"]
    path = folder + "/" + name
    if fs.isFile(path) then ignored = try(fs.delete(path)) end if
  end for
  ignored_dir = _rmdir(folder)
end function

/// Execute the trusted external packer with fixed, reproducible options.
/// @param upx Explicit trusted host-compatible UPX executable path.
/// @param arguments Fixed packing, testing or unpacking arguments.
/// @param runner Host command-execution callback supplied by the compiler driver.
function runTool(upx, arguments, runner)
  result = runner(upx, ["--no-env", "--no-progress"] + arguments)
  if result != 0 then return error(1, "UPX failed; destination unchanged") end if
  return true
end function

/// Stage, validate and atomically publish a packed/unpacked executable.
/// Standalone mode never overwrites a destination, even on publication races.
/// @param source Existing input executable path.
/// @param destination Requested output executable path.
/// @param upx Explicit trusted host-compatible UPX executable path.
/// @param unpack True to restore an image; false to pack it.
/// @param replace True only when compile mode may replace its own output.
/// @param runner Host command-execution callback supplied by the compiler driver.
function transform(source, destination, upx, unpack, replace, runner)
  if replace == false and fs.exists(destination) then return error(1, "destination already exists; choose a new output path") end if
  original = try(readImage(source))
  if typeof(original) == "error" then return original end if
  info = void
  if unpack then
    info = try(parseOverlay(original))
    if typeof(info) == "error" then return info end if
  else
    if len(original) < 4 then return error(1, "only PE/ELF executables can be packed") end if
    if slice(original, 0, 2) != bytes("MZ") and slice(original, 0, 4) != bytes([127, 69, 76, 70]) then return error(1, "only PE/ELF executables can be packed") end if
    if len(original) >= 16 and slice(original, len(original) - 16, 8) == bytes("MLPACK01") then return error(1, "input is already MiniLang-packed") end if
  end if
  folder = try(stageDirectory(destination))
  if typeof(folder) == "error" then return folder end if
  defer cleanup(folder)
  payload = folder + "/payload.bin"
  packed_path = folder + "/packed.bin"
  roundtrip = folder + "/roundtrip.bin"
  result_path = folder + "/result.bin"
  output = void
  if unpack then
    written = try(fs.writeAllBytes(payload, info[0]))
    if typeof(written) == "error" then return written end if
    ran = try(runTool(upx, ["-d", "-o", roundtrip, payload], runner))
    if typeof(ran) == "error" then return ran end if
    restored = try(readImage(roundtrip))
    if typeof(restored) == "error" then return restored end if
    output = try(restoreImage(restored, info))
    if typeof(output) == "error" then return output end if
  else
    ran = try(runTool(upx, ["--best", "--no-lzma", "--overlay=copy", "-o", packed_path, source], runner))
    if typeof(ran) == "error" then return ran end if
    ran = try(runTool(upx, ["-t", packed_path], runner))
    if typeof(ran) == "error" then return ran end if
    ran = try(runTool(upx, ["-d", "-o", roundtrip, packed_path], runner))
    if typeof(ran) == "error" then return ran end if
    packed = try(readImage(packed_path))
    if typeof(packed) == "error" then return packed end if
    restored = try(readImage(roundtrip))
    if typeof(restored) == "error" then return restored end if
    overlay = try(makeOverlay(original, packed, restored))
    if typeof(overlay) == "error" then return overlay end if
    output = packed + overlay
    if len(output) >= len(original) then return error(1, "packing would not make this executable smaller") end if
  end if
  written = try(fs.writeAllBytes(result_path, output))
  if typeof(written) == "error" then return written end if
#if TARGET_OS == "linux"
  attributes = bytes(144, 0)
  if _stat(source, attributes) != 0 then return error(1, "cannot read executable permissions") end if
  if _chmod(result_path, u32at(attributes, 24) & 511) != 0 then return error(1, "cannot preserve executable permissions") end if
  published = false
  if replace then published = _rename(result_path, destination) == 0 else published = _link(result_path, destination) == 0 end if
#else
  published = false
  if replace then published = _replace(result_path, destination, 1) else published = _move(result_path, destination) end if
#endif
  if published == false then return error(1, "cannot publish packed result; destination unchanged") end if
  action = "packed"
  if unpack then action = "unpacked" end if
  print "OK: " + action + " " + destination + " (" + len(original) + " -> " + len(output) + " bytes)"
  return true
end function
