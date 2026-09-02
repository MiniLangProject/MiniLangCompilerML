// Measure the managed allocation cost of per-file versus shared cache hashing.
import std.fs as fs
import std.string as s
import std.time as time
import mlc.project as project

function main(args)
  if len(args) != 2 or (args[1] != "per-file" and args[1] != "shared") then
    print "usage: project_cache_hash_buffer <object-dir> <per-file|shared>"
    return 2
  end if
  names = fs.listDir(args[0])
  if typeof(names) != "array" then return 3 end if
  scratch = void
  if args[1] == "shared" then scratch = bytes(1048576, 0) end if
  count = 0
  before = heap_bytes_used()
  started = time.ticks()
  for each name in names
    if typeof(name) != "string" or not s.endsWith(s.toLowerAscii(name), ".mlo") then continue end if
    path = args[0] + "\\" + name
    if not fs.isFile(path) then continue end if
    identity = void
    if args[1] == "shared" then
      identity = project._file_content_id_with_buffer(path, scratch)
    else
      identity = project._file_content_id(path)
    end if
    if typeof(identity) != "string" then return 4 end if
    count = count + 1
  end for
  print "mode=" + args[1]
  print "files=" + count
  print "elapsed_ms=" + time.elapsed(started, time.ticks())
  print "heap_used_delta=" + (heap_bytes_used() - before)
  return 0
end function
