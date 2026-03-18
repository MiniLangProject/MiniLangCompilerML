enum E are
  A = 1
  B = "x"
  C
  D
end enum

enum EHead are
  A = "x"
  B
  C
end enum

enum EMid are
  A
  B = "x"
  C
  D
end enum

enum EIntStr are
  A = 5
  B = "x"
  C
end enum

print E.A
print E.B
print E.C
print E.D
print EHead.A
print EHead.B
print EHead.C
print EMid.A
print EMid.B
print EMid.C
print EMid.D
print EIntStr.A
print EIntStr.B
print EIntStr.C
