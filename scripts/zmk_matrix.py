#!/usr/bin/env python3
"""Minimal build.yaml matrix reader (avoids a PyYAML dependency).

build.yaml here is always a flat list of mappings under `include:`, each with
`board`, optional `shield`, and `artifact-name` keys -- this parses exactly
that shape, nothing more general.
"""
import json
import re
import sys


def parse(path):
    entries = []
    current = {}
    with open(path) as f:
        for line in f:
            m = re.match(r"\s*-\s*board:\s*(\S+)", line)
            if m:
                if current:
                    entries.append(current)
                current = {"board": m.group(1)}
                continue
            m = re.match(r"\s*shield:\s*(\S+)", line)
            if m:
                current["shield"] = m.group(1)
                continue
            m = re.match(r"\s*artifact-name:\s*(\S+)", line)
            if m:
                current["artifact-name"] = m.group(1)
                continue
    if current:
        entries.append(current)
    return entries


def main():
    path = sys.argv[1]
    cmd = sys.argv[2] if len(sys.argv) > 2 else "list"
    entries = parse(path)

    if cmd == "list":
        for e in entries:
            print(json.dumps(e))
    elif cmd == "describe":
        for e in entries:
            print(f"  - board={e['board']} shield={e.get('shield', '-')} artifact={e['artifact-name']}")
    else:
        print(f"Unknown command: {cmd}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
