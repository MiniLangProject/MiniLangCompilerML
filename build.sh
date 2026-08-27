#!/bin/sh
# Build the native self-hosted MiniLang compiler on a Linux x86-64 host.
# The result is staged in a private temporary directory and smoke-tested before
# it replaces the requested output, so a failed bootstrap never destroys the
# last known-good compiler.

set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
COMPILER=${MINILANG_COMPILER:-}
OUTPUT=${MINILANG_COMPILER_OUTPUT:-"$ROOT/build/mlc_linux_x64"}
SKIP_SMOKE=0
KEEP_OBJECTS=0
REPLACE=1

usage() {
  printf '%s\n' "Usage: ./build.sh [--compiler PATH] [--output PATH] [--no-replace] [--skip-smoke] [--keep-objects]"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --compiler)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      COMPILER=$2
      shift 2
      ;;
    --output)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      OUTPUT=$2
      shift 2
      ;;
    --no-replace) REPLACE=0; shift ;;
    --skip-smoke) SKIP_SMOKE=1; shift ;;
    --keep-objects) KEEP_OBJECTS=1; shift ;;
    --help|-h) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
done

case "$OUTPUT" in
  /*) ;;
  *) OUTPUT="$ROOT/$OUTPUT" ;;
esac

if [ -z "$COMPILER" ]; then
  if [ -x "$ROOT/build/mlc_linux_x64" ]; then
    COMPILER="$ROOT/build/mlc_linux_x64"
  elif [ -f "$ROOT/../MiniLangCompilerPy/mlc_win64.py" ]; then
    COMPILER="$ROOT/../MiniLangCompilerPy/mlc_win64.py"
  else
    printf '%s\n' "No bootstrap compiler found; pass --compiler PATH." >&2
    exit 2
  fi
fi
case "$COMPILER" in
  /*) ;;
  *) COMPILER="$ROOT/$COMPILER" ;;
esac
[ -f "$COMPILER" ] || { printf 'Compiler not found: %s\n' "$COMPILER" >&2; exit 2; }

STAGE_DIR=$(mktemp -d "${TMPDIR:-/tmp}/minilang-build.XXXXXXXX")
cleanup() {
  # STAGE_DIR comes directly from mktemp and is never recomputed.
  rm -rf -- "$STAGE_DIR"
}
trap cleanup EXIT HUP INT TERM

STAGE_OUTPUT="$STAGE_DIR/mlc_linux_x64.next"
ENTRY="$ROOT/mlc_win64.ml"

invoke_compiler() {
  case "$COMPILER" in
    *.py) python3 "$COMPILER" "$@" ;;
    *) "$COMPILER" "$@" ;;
  esac
}

printf 'Compiler: %s\nEntry:    %s\nStage:    %s\nOutput:   %s\n' "$COMPILER" "$ENTRY" "$STAGE_OUTPUT" "$OUTPUT"
START_SECONDS=$(date +%s)
invoke_compiler \
  "$ENTRY" "$STAGE_OUTPUT" \
  -I "$ROOT" \
  --target linux-x64 \
  --heap-reserve 8g \
  --heap-commit 2g \
  --heap-shrink \
  --heap-shrink-min 256m \
  --gc-limit 1536m \
  --object-pipeline
chmod 755 "$STAGE_OUTPUT"
"$STAGE_OUTPUT" --version

if [ "$SKIP_SMOKE" -eq 0 ]; then
  SMOKE_SOURCE="$STAGE_DIR/smoke.ml"
  SMOKE_OUTPUT="$STAGE_DIR/smoke.object"
  SMOKE_MONOLITHIC="$STAGE_DIR/smoke.monolithic"
  printf '%s\n' 'print "hello-linux"' 'x = 1' 'print "x=" + x' > "$SMOKE_SOURCE"
  "$STAGE_OUTPUT" "$SMOKE_SOURCE" "$SMOKE_MONOLITHIC" -I "$ROOT" --target linux-x64
  "$STAGE_OUTPUT" "$SMOKE_SOURCE" "$SMOKE_OUTPUT" -I "$ROOT" --target linux-x64 --object-pipeline
  chmod 755 "$SMOKE_MONOLITHIC" "$SMOKE_OUTPUT"
  cmp -s "$SMOKE_MONOLITHIC" "$SMOKE_OUTPUT" || {
    printf '%s\n' "Linux monolithic and MLO smoke images are not byte-identical." >&2
    exit 2
  }
  SMOKE_RESULT=$($SMOKE_OUTPUT)
  [ "$SMOKE_RESULT" = "hello-linux
x=1" ] || { printf 'Unexpected smoke-test output:\n%s\n' "$SMOKE_RESULT" >&2; exit 2; }

  # Exercise Linux-hosted project/path handling as well as the direct CLI. The
  # parent component is intentional: it catches array/path normalization bugs.
  SMOKE_MANIFEST="$STAGE_DIR/minilang.toml"
  SMOKE_PROJECT="$STAGE_DIR/smoke.project"
  printf '%s\n' \
    '[project]' \
    'entry = "smoke.ml"' \
    'output = "nested/../smoke.project"' \
    'target = "linux-x64"' \
    'object_pipeline = true' \
    'incremental = false' > "$SMOKE_MANIFEST"
  "$STAGE_OUTPUT" --project "$SMOKE_MANIFEST"
  chmod 755 "$SMOKE_PROJECT"
  cmp -s "$SMOKE_MONOLITHIC" "$SMOKE_PROJECT" || {
    printf '%s\n' "Linux project and direct smoke images are not byte-identical." >&2
    exit 2
  }
fi

mkdir -p -- "$(dirname -- "$OUTPUT")"
if [ "$REPLACE" -eq 0 ] && [ "$OUTPUT" = "$COMPILER" ]; then
  OUTPUT="$OUTPUT.next"
fi
mv -f -- "$STAGE_OUTPUT" "$OUTPUT"

if [ "$KEEP_OBJECTS" -eq 1 ] && [ -d "$STAGE_DIR/tmp" ]; then
  OBJECT_OUTPUT="$OUTPUT.objects"
  rm -rf -- "$OBJECT_OUTPUT"
  mv -- "$STAGE_DIR/tmp" "$OBJECT_OUTPUT"
fi

END_SECONDS=$(date +%s)
printf 'Build complete in %ss.\nWrote: %s\n' "$((END_SECONDS - START_SECONDS))" "$OUTPUT"
