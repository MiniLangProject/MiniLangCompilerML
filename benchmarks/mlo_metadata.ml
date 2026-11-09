/// Runtime and allocation benchmark; run before/after binaries alternately.
/// Heap deltas measure bump-pointer growth, not cumulative allocation or RSS.
#if TARGET_OS == "windows"
extern function counter(output as bytes) from "kernel32.dll" symbol "QueryPerformanceCounter" returns i32
extern function frequency(output as bytes) from "kernel32.dll" symbol "QueryPerformanceFrequency" returns i32
#else
extern function counter(clockId as i32, output as bytes) from "libc.so.6" symbol "clock_gettime" returns i32
#endif

/// Decode the native timer's nonnegative 64-bit fields without allocating.
function readCounter(buffer, offset as int) returns int
  value = 0
  for i = 0 to 7
    value = value | (buffer[offset + i] << (8 * i))
  end for
  return value
end function

/// Reuse caller-owned scratch memory, keeping timing out of the heap delta.
function ticks(buffer) returns int
#if TARGET_OS == "windows"
  counter(buffer)
  return readCounter(buffer, 0)
#else
  counter(1, buffer)
  return readCounter(buffer, 0) * 1000000000 + readCounter(buffer, 8)
#endif
end function

// Isolate metadata integer writes from code generation and disk output.
import mlc.tools as tools

function main(args)
  timer = bytes(16)
  ticksPerSecond = 1000000000
#if TARGET_OS == "windows"
  frequency(timer)
  ticksPerSecond = readCounter(timer, 0)
#endif
  pages = tools.byte_pages_new()
  gc_set_limit(0)
  before = heap_bytes_used()
  started = ticks(timer)
  for i = 0 to 999999
    pages = tools.byte_pages_append_u32(pages, i)
  end for
  finished = ticks(timer)
  allocated = heap_bytes_used() - before
  elapsed = ((finished - started) * 1000) / ticksPerSecond
  result = tools.byte_pages_to_bytes(pages)
  checksum = len(result) + tools._ast_u32_read(result, 999999)
  print "mlo-u32 ms=" + elapsed + " bytes=" + allocated + " checksum=" + checksum
  return 0
end function
