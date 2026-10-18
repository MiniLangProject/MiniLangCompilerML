// Restoration format checks require no external UPX installation.
import mlc.packing as p
import mlc.tools as t
import std.checksum.crc32 as crc

function checkedMetadata(packed, metadata)
  return packed + metadata + bytes("MLPACK01") + t.u32(len(metadata)) + t.u32(crc.compute(metadata))
end function

function rejected(image)
  return typeof(try(p.parseOverlay(image))) == "error"
end function

function main(args)
  packed = bytes("MZ compressed test payload")
  for each size in [1, 4095, 4096, 4097, 9000]
    original = bytes(size, 37)
    restored = bytes(size + 3, 37)
    restored[0] = 99
    restored[size - 1] = 123
    image = packed + p.makeOverlay(original, packed, restored)
    info = p.parseOverlay(image)
    if p.restoreImage(restored, info) != original then return 1 end if
    image[0] = image[0] ^ 1
    if rejected(image) == false then return 2 end if
    image[0] = image[0] ^ 1
    image[len(image) - 1] = image[len(image) - 1] ^ 1
    if rejected(image) == false then return 3 end if
  end for
  if rejected(bytes(0)) == false then return 4 end if
  header = t.u32(10) + t.u32(len(packed)) + t.u32(10) + t.u32(0) + t.u32(crc.compute(packed))
  for each records in [t.u32(100), t.u32(1) + t.u32(11) + t.u32(1) + bytes(1), t.u32(1) + t.u32(0) + t.u32(0), t.u32(0) + bytes(1)]
    if rejected(checkedMetadata(packed, header + records)) == false then return 5 end if
  end for
  overlap = t.u32(2) + t.u32(0) + t.u32(2) + bytes(2) + t.u32(1) + t.u32(1) + bytes(1)
  if rejected(checkedMetadata(packed, header + overlap)) == false then return 6 end if
  original = bytes(5000, 1)
  info = p.parseOverlay(packed + p.makeOverlay(original, packed, original))
  wrong = bytes(5000, 2)
  if typeof(try(p.restoreImage(wrong, info))) != "error" then return 7 end if
  if typeof(try(p.restoreImage(bytes(4999), info))) != "error" then return 8 end if
  print "PACKING FORMAT [OK]"
  return 0
end function
