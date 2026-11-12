#!/usr/bin/env python3
"""Measure the declaration fingerprint cache at self-build scale.

Variant of benchmarks/measure_interface_cache.py with the build.ps1 heap
flags, the object pipeline, and an explicit single-file edit scenario."""

import argparse
import hashlib
import json
import statistics
import subprocess
import sys
import tempfile
import time
from pathlib import Path

HEAP = ["--heap-reserve", "8g", "--heap-commit", "512m", "--heap-shrink",
        "--heap-shrink-min", "16m", "--gc-limit", "1536m"]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('compiler', type=Path)
    parser.add_argument('source', type=Path)
    parser.add_argument('--include', type=Path, required=True)
    parser.add_argument('--cache', type=Path, required=True)
    parser.add_argument('--runs', type=int, default=3)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    if args.runs < 3:
        parser.error('at least three measured runs are required')
    compiler = args.compiler.resolve()
    source = args.source.resolve()
    include = args.include.resolve()
    cache = args.cache.resolve()
    cache.mkdir(parents=True, exist_ok=True)
    prefix = [sys.executable, str(compiler)] if compiler.suffix == '.py' else [str(compiler)]
    samples = []
    original = source.read_bytes()

    with tempfile.TemporaryDirectory(prefix='mlc_interface_self_') as temp:
        image = Path(temp) / 'program.exe'

        def compile_once(mode: str, run: int) -> None:
            command = [*prefix, str(source), str(image), '-I', str(include),
                       '--incremental-cache', str(cache), *HEAP]
            start = time.perf_counter()
            result = subprocess.run(command, stdout=subprocess.PIPE,
                                    stderr=subprocess.STDOUT, timeout=900)
            elapsed = time.perf_counter() - start
            text = result.stdout.decode(errors='replace')
            counts = [line for line in text.splitlines() if line.startswith('[incremental]')]
            if result.returncode:
                raise RuntimeError(text)
            samples.append(dict(mode=mode, run=run, seconds=elapsed,
                                image_sha256=hashlib.sha256(image.read_bytes()).hexdigest(),
                                counts=counts[-1] if counts else ''))

        compile_once('prime', -1)
        for run in range(args.runs):
            compile_once('cached', run)
            records = list(cache.rglob('*.mif'))
            if len(records) != 1:
                raise RuntimeError(f'expected one interface record, found {len(records)}')
            records[0].unlink()
            compile_once('recomputed', run)
        # single-file edit scenario: append one comment line
        source.write_bytes(original + b'\n// interface cache edit probe\n')
        try:
            for run in range(args.runs):
                compile_once('edited', run)
        finally:
            source.write_bytes(original)

    groups = {}
    for sample in samples:
        if sample['mode'] == 'prime':
            continue
        groups.setdefault(sample['mode'], set()).add(sample['image_sha256'])
    for mode, hashes in groups.items():
        if len(hashes) != 1:
            raise RuntimeError(f'output bytes changed across {mode} runs')
    summary = {mode: statistics.median(sample['seconds'] for sample in samples
                                       if sample['mode'] == mode)
               for mode in ('cached', 'recomputed', 'edited')}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(dict(compiler=str(compiler), source=str(source),
                                           summary_seconds=summary, samples=samples), indent=2)
                           + '\n', encoding='utf-8')
    print(json.dumps(summary, indent=2))


if __name__ == '__main__':
    main()