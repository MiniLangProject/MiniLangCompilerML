#!/usr/bin/env python3
"""Measure the declaration fingerprint cache with function fragments already warm."""

import argparse
import hashlib
import json
from pathlib import Path
import statistics
import subprocess
import sys
import tempfile
import time


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('compiler', type=Path)
    parser.add_argument('source', type=Path)
    parser.add_argument('--include', type=Path, required=True)
    parser.add_argument('--cache', type=Path, required=True)
    parser.add_argument('--runs', type=int, default=5)
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

    with tempfile.TemporaryDirectory(prefix='mlc_interface_measure_') as temp:
        image = Path(temp) / 'program.exe'

        def compile_once(mode: str, run: int) -> None:
            command = [*prefix, str(source), str(image), '-I', str(include),
                       '--no-object-pipeline', '--incremental-cache', str(cache)]
            start = time.perf_counter()
            result = subprocess.run(command, stdout=subprocess.PIPE,
                                    stderr=subprocess.STDOUT, timeout=600)
            elapsed = time.perf_counter() - start
            if result.returncode:
                raise RuntimeError(result.stdout.decode(errors='replace'))
            samples.append(dict(mode=mode, run=run, seconds=elapsed,
                                image_sha256=hashlib.sha256(image.read_bytes()).hexdigest()))

        compile_once('prime', -1)
        for run in range(args.runs):
            compile_once('cached', run)
            records = list(cache.rglob('*.mif'))
            if len(records) != 1:
                raise RuntimeError(f'expected one interface record, found {len(records)}')
            records[0].unlink()
            compile_once('recomputed', run)

    if len({sample['image_sha256'] for sample in samples}) != 1:
        raise RuntimeError('output bytes changed across cache modes')
    summary = {mode: statistics.median(sample['seconds'] for sample in samples
                                      if sample['mode'] == mode)
               for mode in ('cached', 'recomputed')}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(dict(compiler=str(compiler), source=str(source),
                                          summary_seconds=summary, samples=samples), indent=2)
                           + '\n', encoding='utf-8')
    print(json.dumps(summary, indent=2))


if __name__ == '__main__':
    main()
