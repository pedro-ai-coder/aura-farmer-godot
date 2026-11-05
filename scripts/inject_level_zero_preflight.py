#!/usr/bin/env python3
"""Attach a Level Zero-only browser check to the exported Godot HTML shell."""
from pathlib import Path
import sys

SCRIPT = '<script defer src="level_zero_preflight.js"></script>'


def inject(html: str) -> str:
    if html.count('</head>') != 1:
        raise ValueError('Expected exactly one </head> in Godot export')
    if SCRIPT in html:
        raise ValueError('Level Zero preflight was already injected')
    return html.replace('</head>', f'{SCRIPT}\n</head>', 1)


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit('usage: inject_level_zero_preflight.py PATH_TO_EXPORTED_INDEX_HTML')
    path = Path(sys.argv[1])
    original = path.read_text(encoding='utf-8')
    path.write_text(inject(original), encoding='utf-8')


if __name__ == '__main__':
    main()
