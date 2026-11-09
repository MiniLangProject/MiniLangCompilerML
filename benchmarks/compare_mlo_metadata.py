#!/usr/bin/env python3
"""Compare mlo_metadata.ml images built against two versions of mlc/tools.ml.

Usage matches compare_runtime_codegen.py: BEFORE AFTER --runs 15 --cpu 4
--output report.json. Compile the same benchmark with each source tree on
its include path, using the same compiler and output flags for both images.
"""
import compare_runtime_codegen as comparison

if __name__ == "__main__":
    comparison.CASES = ("mlo-u32",)
    comparison.main()
