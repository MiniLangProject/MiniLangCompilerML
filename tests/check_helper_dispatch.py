"""Ensure native helper dispatch groups cover their canonical emission ranks."""
from pathlib import Path
import re


def main():
    source = (Path(__file__).resolve().parents[1] / "mlc/codegen/codegen_core.ml").read_text()
    rank = source.split("function _helper_rank(lbl)", 1)[1].split("end function", 1)[0]
    ordered = re.findall(r'"(fn_[^"]+)"', rank)
    dispatch = source.split("function _emit_helper_by_label(state, lbl)", 1)[1].split("end function", 1)[0]
    ranges = [(int(limit), int(group)) for limit, group in re.findall(
        r"if rank < (\d+) then return _emit_helper_by_label_group(\d)", dispatch)]
    membership = {}
    for group, body in re.findall(
            r"function _emit_helper_by_label_group(\d)\(state, lbl\)(.*?)end function",
            source, re.S):
        for label in re.findall(r'if lbl == "(fn_[^"]+)"', body):
            membership[label] = int(group)
    for i, label in enumerate(ordered):
        selected = next(group for limit, group in ranges if i < limit)
        assert membership.get(label) == selected, (i, label, membership.get(label), selected)
    print(f"HELPER DISPATCH [OK]: {len(ordered)} canonical helpers")


if __name__ == "__main__":
    main()
