"""Require byte-identical OOP images from the Python and self-hosted compilers.

Run from a paired MiniLangCompilerPy/MiniLangCompilerML checkout on Windows.
Optionally include a native Linux compiler through WSL Ubuntu.
"""

import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile


FIXTURES = (
    "language_class.ml",
    "language_interface.ml",
    "language_class_constructors.ml",
    "language_class_many_args.ml",
    "language_class_dispatch.ml",
    "language_class_features.ml",
    "language_class_named_super.ml",
    "language_class_access_alias.ml",
    "language_class_qualified_static.ml",
    "language_class_static_inheritance.ml",
    "language_interface_inheritance.ml",
)


def invoke(command):
    result = subprocess.run(command, capture_output=True, text=True,
                            encoding="utf-8", errors="replace", timeout=180,
                            creationflags=subprocess.CREATE_NO_WINDOW if os.name == "nt" else 0)
    if result.returncode:
        raise RuntimeError(f"{command}\nexit={result.returncode}\n{result.stdout}\n{result.stderr}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("python_compiler", type=Path)
    parser.add_argument("windows_compiler", type=Path)
    parser.add_argument("--linux-compiler", type=Path)
    parser.add_argument("--fixtures-dir", type=Path)
    parser.add_argument("--target", choices=("windows-x64", "linux-x64", "both"), default="both")
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    if os.name != "nt":
        parser.error("Run on Windows with WSL Ubuntu")
    root = Path(__file__).resolve().parents[1]
    fixtures = args.fixtures_dir or root.parent / "MiniLangCompilerPy" / "tests"
    fixtures = fixtures.resolve()
    for fixture in FIXTURES:
        if not (fixtures / fixture).is_file():
            parser.error(f"Missing fixture: {fixtures / fixture}")

    linux_paths = {}

    def linux_path(path):
        path = Path(path).resolve().as_posix()
        if path not in linux_paths:
            linux_paths[path] = subprocess.check_output(
                ["wsl", "-d", "Ubuntu", "--", "wslpath", "-a", "-u", path],
                text=True).strip()
        return linux_paths[path]

    hosts = (("python", [sys.executable, str(args.python_compiler.resolve())]),
             ("windows-ml", [str(args.windows_compiler.resolve())]))
    if args.linux_compiler:
        hosts += (("linux-ml", ["wsl", "-d", "Ubuntu", "--", linux_path(args.linux_compiler)]),)
    targets = ("windows-x64", "linux-x64") if args.target == "both" else (args.target,)
    rows = []
    with tempfile.TemporaryDirectory(prefix="ml_oop_parity_") as temporary:
        for target in targets:
            for fixture in FIXTURES:
                digests = []
                executed = False
                for host, command in hosts:
                    for pipeline in ("--no-object-pipeline", "--object-pipeline"):
                        output = Path(temporary) / f"{target}-{fixture}-{host}-{pipeline[2:]}"
                        path = linux_path if host == "linux-ml" else lambda p: str(Path(p).resolve())
                        invoke([*command, path(fixtures / fixture), path(output),
                                "-I", path(root), "--target", target, pipeline])
                        digest = hashlib.sha256(output.read_bytes()).hexdigest()
                        digests.append(digest)
                        rows.append({"target": target, "fixture": fixture, "host": host,
                                     "pipeline": pipeline, "sha256": digest,
                                     "bytes": output.stat().st_size})
                        if not executed:
                            run = ([str(output)] if target == "windows-x64" else
                                   ["wsl", "-d", "Ubuntu", "--", linux_path(output)])
                            invoke(run)
                            executed = True
                if len(set(digests)) != 1:
                    raise AssertionError((target, fixture, rows[-len(digests):]))
                print(f"[OK] {target} {fixture}: {len(digests)} identical images", flush=True)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps({"images": rows}, indent=2) + "\n", encoding="utf-8")
    print(f"OOP BINARY PARITY [OK]: {len(rows)} images", flush=True)


if __name__ == "__main__":
    main()
