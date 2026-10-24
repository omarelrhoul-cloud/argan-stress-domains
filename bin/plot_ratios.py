#!/usr/bin/env python3
"""Normalised family-size ratio (target vs reference) as a table and an SVG bar chart."""
import csv
import math
import sys

counts_tsv, target, reference = sys.argv[1:4]

# family -> species -> (genes in family, total genes)
data = {}
with open(counts_tsv) as f:
    for row in csv.DictReader(f, delimiter="\t"):
        data.setdefault(row["family"], {})[row["species"]] = (
            int(row["n_genes"]), int(row["total_genes"]))

rows = []
for fam, d in data.items():
    (a, ta), (b, tb) = d[target], d[reference]
    ratio = (a / ta) / (b / tb) if a and b else float("nan")
    rows.append((fam, a, b, ta, tb, ratio))
rows.sort(key=lambda r: r[5] if not math.isnan(r[5]) else -1, reverse=True)

# ---- Table ----
with open("ratios.tsv", "w") as out:
    out.write(f"family\t{target}_genes\t{reference}_genes\t"
              f"{target}_per_10k\t{reference}_per_10k\tratio\n")
    for fam, a, b, ta, tb, r in rows:
        out.write(f"{fam}\t{a}\t{b}\t{a / ta * 1e4:.1f}\t{b / tb * 1e4:.1f}\t{r:.2f}\n")

# ---- SVG chart (log2 scale, 0.25x to 4x) ----
W, LEFT, PLOT_W, TOP, ROW = 820, 190, 360, 80, 28
H = TOP + len(rows) * ROW + 50
CX = LEFT + PLOT_W / 2
SCALE = PLOT_W / 4


def x(log2_ratio):
    return CX + max(-2, min(2, log2_ratio)) * SCALE


svg = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" '
       f'font-family="Arial, sans-serif" font-size="13">',
       f'<rect width="{W}" height="{H}" fill="white"/>',
       f'<text x="20" y="30" font-size="16" font-weight="bold">'
       f'Stress-related gene families: {target} vs {reference}</text>',
       f'<text x="20" y="50" font-size="12" fill="#555">'
       f'Family size ratio, normalised by total gene number (1x = same proportion)</text>',
       f'<text x="{LEFT + PLOT_W + 20}" y="{TOP - 10}" font-size="12" fill="#555">'
       f'genes ({target} vs {reference})</text>']

bottom = TOP + len(rows) * ROW
for tick in (-2, -1, 0, 1, 2):
    colour = "#888" if tick == 0 else "#ddd"
    svg.append(f'<line x1="{x(tick)}" y1="{TOP - 5}" x2="{x(tick)}" y2="{bottom}" stroke="{colour}"/>')
    svg.append(f'<text x="{x(tick)}" y="{bottom + 18}" text-anchor="middle" fill="#555">{2 ** tick:g}x</text>')

for i, (fam, a, b, ta, tb, r) in enumerate(rows):
    y = TOP + i * ROW
    svg.append(f'<text x="{LEFT - 10}" y="{y + ROW * 0.65}" text-anchor="end">{fam}</text>')
    svg.append(f'<text x="{LEFT + PLOT_W + 20}" y="{y + ROW * 0.65}" fill="#555">{a} vs {b}</text>')
    if math.isnan(r):
        continue
    l = math.log2(r)
    x0, width = min(CX, x(l)), abs(x(l) - CX)
    colour = "#c2410c" if l > 0 else "#1d4ed8"
    svg.append(f'<rect x="{x0}" y="{y + 5}" width="{width}" height="{ROW - 10}" fill="{colour}"/>')
    tx, anchor = (x(l) + 5, "start") if l >= 0 else (x(l) - 5, "end")
    svg.append(f'<text x="{tx}" y="{y + ROW * 0.65}" text-anchor="{anchor}" font-size="12">{r:.1f}x</text>')

svg.append("</svg>")
with open("stress_families.svg", "w") as out:
    out.write("\n".join(svg))
