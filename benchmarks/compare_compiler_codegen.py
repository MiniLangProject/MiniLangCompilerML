#!/usr/bin/env python3
"""Measure Windows compiler wall time and OS peak working set on one source.

Uses the monolithic path so the process peak includes the complete compilation,
not just an object-pipeline coordinator. No third-party packages are required.
Results describe this fixture, not arbitrary projects or reserved heap space.
"""
import argparse
import ctypes
from ctypes import wintypes
import hashlib
import json
import os
from pathlib import Path
import platform
import statistics
import subprocess
import tempfile
import time


class MemoryCounters(ctypes.Structure):
    """PROCESS_MEMORY_COUNTERS, with pointer-sized SIZE_T fields."""
    _fields_ = [('cb', wintypes.DWORD), ('faults', wintypes.DWORD)] + [
        (name, ctypes.c_size_t) for name in (
            'peak_working_set', 'working_set', 'peak_paged', 'paged',
            'peak_nonpaged', 'nonpaged', 'pagefile', 'peak_pagefile')]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('before', type=Path)
    parser.add_argument('after', type=Path)
    parser.add_argument('source', type=Path)
    parser.add_argument('--include', type=Path, required=True)
    parser.add_argument('--runs', type=int, default=3)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    if os.name != 'nt' or args.runs < 3:
        parser.error('Windows and at least three measured runs are required')
    query = ctypes.WinDLL('psapi', use_last_error=True).GetProcessMemoryInfo
    query.argtypes = [wintypes.HANDLE, ctypes.POINTER(MemoryCounters), wintypes.DWORD]
    query.restype = wintypes.BOOL
    compilers = {key: path.resolve() for key, path in [('before', args.before), ('after', args.after)]}
    rows = []
    with tempfile.TemporaryDirectory(prefix='mlc_codegen_measure_') as tmp:
        target = Path(tmp) / 'fixture.exe'
        # One warm-up per compiler, followed by alternating measured runs.
        for run in range(-1, args.runs):
            for name in (('before', 'after') if run % 2 == 0 else ('after', 'before')):
                command = [str(compilers[name]), str(args.source.resolve()), str(target),
                           '-I', str(args.include.resolve()), '--no-object-pipeline']
                start = time.perf_counter()
                proc = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
                try:
                    stdout, _ = proc.communicate(timeout=600)
                except subprocess.TimeoutExpired:
                    proc.kill()
                    proc.communicate()
                    raise
                elapsed = time.perf_counter() - start
                if proc.returncode:
                    raise RuntimeError(stdout.decode(errors='replace'))
                counters = MemoryCounters()
                counters.cb = ctypes.sizeof(counters)
                if not query(wintypes.HANDLE(int(proc._handle)), ctypes.byref(counters), counters.cb):
                    raise ctypes.WinError(ctypes.get_last_error())
                if run >= 0:
                    rows.append(dict(version=name, run=run, seconds=elapsed,
                                     peak_working_set=counters.peak_working_set,
                                     image_bytes=target.stat().st_size,
                                     image_sha256=hashlib.sha256(target.read_bytes()).hexdigest()))
        summary = {name: {key: statistics.median(row[key] for row in rows if row['version'] == name)
                          for key in ('seconds', 'peak_working_set', 'image_bytes')}
                   for name in compilers}
        for name in compilers:
            assert len({r['image_sha256'] for r in rows if r['version'] == name}) == 1
        payload = dict(platform=platform.platform(), source=str(args.source.resolve()),
                       include=str(args.include.resolve()), pipeline='monolithic',
                       compilers={name: dict(path=str(path), sha256=hashlib.sha256(path.read_bytes()).hexdigest())
                                  for name, path in compilers.items()}, summary=summary, samples=rows)
        args.output.write_text(json.dumps(payload, indent=2) + '\n', encoding='utf-8')
        print(json.dumps(summary, indent=2))


if __name__ == '__main__':
    main()
