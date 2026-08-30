#!/usr/bin/env bash
# Exercise Linux-host-only compiler behavior that a Windows cross-build cannot
# represent: executable mode bits and case-sensitive filesystem semantics.
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 /path/to/native-linux-mlc" >&2
  exit 2
fi

compiler=$(realpath "$1")
if [[ ! -x "$compiler" ]]; then
  echo "compiler is not executable: $compiler" >&2
  exit 2
fi

scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT

cat >"$scratch/simple.ml" <<'EOF'
function main(args)
  print "native Linux executable mode [OK]"
  return 0
end function
EOF

"$compiler" "$scratch/simple.ml" "$scratch/simple-mono" --target linux-x64 --no-object-pipeline
test -x "$scratch/simple-mono"
"$scratch/simple-mono"

"$compiler" "$scratch/simple.ml" "$scratch/simple-object" --target linux-x64 --object-pipeline
test -x "$scratch/simple-object"
"$scratch/simple-object"
cmp "$scratch/simple-mono" "$scratch/simple-object"

cat >"$scratch/Foo.ml" <<'EOF'
package ReviewUpper
function value()
  return 1
end function
EOF
cat >"$scratch/foo.ml" <<'EOF'
package ReviewLower
function value()
  return 2
end function
EOF
cat >"$scratch/import-case.ml" <<'EOF'
import "Foo.ml" as upper
import "foo.ml" as lower
function main(args)
  if upper.value() != 1 then return 11 end if
  if lower.value() != 2 then return 12 end if
  print "case-sensitive Linux imports [OK]"
  return 0
end function
EOF

"$compiler" "$scratch/import-case.ml" "$scratch/import-case" --target linux-x64 --no-object-pipeline
"$scratch/import-case"

mkdir "$scratch/Cache"
cat >"$scratch/project.toml" <<'EOF'
[project]
entry = "Cache/main.ml"
output = "project-output"
target = "linux-x64"
object_pipeline = false
incremental = true
cache_dir = "cache"
EOF
cat >"$scratch/Cache/main.ml" <<'EOF'
function main(args)
  print "CACHE_V1"
  return 0
end function
EOF

"$compiler" --project "$scratch/project.toml"
[[ $("$scratch/project-output") == "CACHE_V1" ]]
cat >"$scratch/Cache/main.ml" <<'EOF'
function main(args)
  print "CACHE_V2"
  return 0
end function
EOF
"$compiler" --project "$scratch/project.toml"
[[ $("$scratch/project-output") == "CACHE_V2" ]]

echo "native Linux compiler regressions [PASS]"
