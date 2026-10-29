// Primitive cache records must round-trip without exposing executable objects.
import mlc.cache_codec as codec

function require(value, label)
  if value == false then return error(1, "cache codec: " + label) end if
end function

large = bytes(262147, 91)
large[0] = 0
large[262146] = 255
original = [void, false, true, -1, 0, 1152921504606846975, -1152921504606846976, "Grüße 🌍", bytes(0), [], [1, ["nested"]], large]
encoded = codec.encode(original)
decoded = codec.decodeRecord(encoded)
require(len(decoded) == len(original), "length")
require(typeof(decoded[0]) == "void", "void")
require(decoded[1] == false and decoded[2] == true, "bool")
require(decoded[3] == -1 and decoded[4] == 0, "signed integer")
require(decoded[5] == 1152921504606846975 and decoded[6] == -1152921504606846976, "61-bit limits")
require(decoded[7] == "Grüße 🌍", "UTF-8")
require(len(decoded[8]) == 0 and len(decoded[9]) == 0, "empty containers")
require(decoded[10][1][0] == "nested", "nested arrays")
require(decoded[11] == large, "large bytes across capacity growth")
require(typeof(codec.decodeRecord(codec.slice(encoded, 0, len(encoded) - 1))) == "void", "truncation")
require(typeof(codec.decodeRecord(encoded + bytes(1, 0))) == "void", "trailing bytes")
invalid_tag = bytes(2, 255)
require(typeof(codec.decodeRecord(invalid_tag)) == "void", "unknown tag")
oversized_array = bytes(6, 255)
oversized_array[0] = 6
oversized_array[1] = 0
require(typeof(codec.decodeRecord(oversized_array)) == "void", "array budget")
deep = 0
for i = 0 to 130
  deep = [deep]
end for
require(typeof(codec.decodeRecord(codec.encode(deep))) == "void", "nesting budget")
print "[OK] incremental cache codec"
