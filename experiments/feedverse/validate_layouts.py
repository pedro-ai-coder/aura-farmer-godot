#!/usr/bin/env python3
"""Offline, approximate layout checks. This is not a Godot runtime test."""
import json, math
from collections import deque
from pathlib import Path

ROOT = Path(__file__).resolve().parent
maps = json.loads((ROOT / 'maps.json').read_text())
assert len(maps) == 6
assert len({m['name'] for m in maps}) == 6

def distance_segment(p, a, b):
    dx, dy = b[0]-a[0], b[1]-a[1]
    t = max(0, min(1, ((p[0]-a[0])*dx+(p[1]-a[1])*dy)/(dx*dx+dy*dy)))
    return math.hypot(p[0]-(a[0]+t*dx), p[1]-(a[1]+t*dy))

def walkable(p, m, radius=24):
    poly = m['floor']
    inside = False
    for a, b in zip(poly, poly[1:]+poly[:1]):
        if distance_segment(p, a, b) < radius: return False
        if (a[1] > p[1]) != (b[1] > p[1]) and p[0] < (b[0]-a[0])*(p[1]-a[1])/(b[1]-a[1])+a[0]: inside = not inside
    return inside and all(math.hypot(p[0]-x,p[1]-y) > r+radius for x,y,r in m['covers'])

for m in maps:
    assert walkable(m['spawn'], m), m['name'] + ' invalid spawn'
    assert all(0 <= x <= 1448 and 0 <= y <= 1086 for x,y in m['floor'])
    assert all(0 < r < 120 for _,_,r in m['covers'])
    # 20-unit sample grid with an enlarged radius; conservative only at the sample points.
    cells = {(x,y) for x in range(40,1448,20) for y in range(40,1086,20) if walkable((x,y),m,40)}
    start = min(cells, key=lambda p: math.dist(p, m['spawn']))
    seen = {start}; queue = deque([start])
    while queue:
        x,y = queue.popleft()
        for n in ((x-20,y),(x+20,y),(x,y-20),(x,y+20)):
            if n in cells and n not in seen:
                seen.add(n); queue.append(n)
    assert len(seen)/len(cells) > .99, (m['name'], len(seen), len(cells))
    print(f"{m['name']}: spawn clear; connected sampled space {len(seen)}/{len(cells)}")
print('PASS: offline geometry sampling only; no engine, gameplay, collision sweep, or visual validation')
