import mlc.tools as t

// Same field names as the internal vector, but a different nominal type.
struct VectorLookalike
  data,
  size,
  cap,
end struct

function check(cond, message)
  if cond then return true end if
  print "[FAIL] " + message
  return false
end function

function main(args)
  ok = true
  vec = t.arr_vec_new(4)
  for i = 0 to 4999
    vec = t.arr_vec_push(vec, i)
  end for
  vec = t.arr_vec_push(vec, void)
  vec = t.arr_vec_push(vec, "tail")

  if check(t.arr_vec_is(vec), "vector type detection") == false then ok = false end if
  if check(t.arr_vec_is(VectorLookalike([], 0, 0)) == false, "vector detection is nominal") == false then ok = false end if
  if check(t.arr_vec_count(vec) == 5002, "geometric growth count") == false then ok = false end if
  if check(t.arr_vec_get(vec, 0, -1) == 0, "first value") == false then ok = false end if
  if check(t.arr_vec_get(vec, 4097, -1) == 4097, "grown value") == false then ok = false end if
  if check(typeof(t.arr_vec_get(vec, 5000, 1)) == "void", "void value roundtrip") == false then ok = false end if
  if check(t.arr_vec_get(vec, 5001, "") == "tail", "last value") == false then ok = false end if
  if check(t.arr_vec_get(vec, 9000, 77) == 77, "out-of-range default") == false then ok = false end if

  vec = t.arr_vec_set(vec, 2500, 42)
  flat = t.arr_vec_finish(vec)
  if check(typeof(flat) == "array" and len(flat) == 5002, "materialized length") == false then ok = false end if
  if check(flat[2499] == 2499 and flat[2500] == 42 and flat[2501] == 2501, "set preserves order") == false then ok = false end if
  if check(typeof(flat[5000]) == "void" and flat[5001] == "tail", "materialized tail") == false then ok = false end if

  copied = t.arr_vec_from_array(["a", "b", "c"], 8)
  copied = t.arr_vec_push(copied, "d")
  copied_flat = t.arr_vec_finish(copied)
  if check(copied_flat == ["a", "b", "c", "d"], "array conversion") == false then ok = false end if

  old_cap = copied.cap
  copied = t.arr_vec_clear(copied)
  if check(t.arr_vec_count(copied) == 0 and copied.cap == old_cap, "clear retains capacity") == false then ok = false end if
  copied = t.arr_vec_push(copied, "reused")
  if check(t.arr_vec_finish(copied) == ["reused"], "push after clear reuses active prefix") == false then ok = false end if

  merged = t.arr_merge_variadic_parts([1, void], ["three"], 4)
  if check(typeof(merged) == "array" and len(merged) == 4, "variadic merge length") == false then ok = false end if
  if check(merged[0] == 1 and typeof(merged[1]) == "void" and merged[2] == "three" and merged[3] == 4, "variadic merge preserves order and void") == false then ok = false end if

  chunks = t.arr_chunk_new(2)
  chunks = t.arr_chunk_push(chunks, "first")
  chunks = t.arr_chunk_push(chunks, void)
  chunks = t.arr_chunk_push(chunks, "last")
  chunked_flat = t.arr_chunk_finish(chunks)
  if check(typeof(chunked_flat) == "array" and len(chunked_flat) == 3, "chunk finalization length") == false then ok = false end if
  if check(chunked_flat[0] == "first" and typeof(chunked_flat[1]) == "void" and chunked_flat[2] == "last", "chunk finalization preserves order and void") == false then ok = false end if

  if ok == false then return 1 end if
  print "array vector tests [OK]"
  return 0
end function
