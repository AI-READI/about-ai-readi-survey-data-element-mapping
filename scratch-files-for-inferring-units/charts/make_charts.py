"""Charts for unit_harmonization_summary.md.

Counts are copied from the E_review_outputs notebook run (cells E1 and 19a).
Run: uv run --no-project --with matplotlib python make_charts.py
"""
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter

OUT = Path(__file__).parent
SURFACE, INK, INK2, MUTED, GRID = '#fcfcfb', '#0b0b0b', '#52514e', '#898781', '#e1e0d9'
SERIES = ['#2a78d6', '#eb6834']  # validated categorical slots 1-2

plt.rcParams.update({
    'font.family': 'sans-serif',
    'font.sans-serif': ['Helvetica Neue', 'Helvetica', 'Arial', 'DejaVu Sans'],
    'font.size': 10, 'text.color': INK, 'axes.labelcolor': INK2,
    'xtick.color': MUTED, 'ytick.color': INK2,
    'figure.facecolor': SURFACE, 'axes.facecolor': SURFACE,
})
millions = FuncFormatter(lambda x, _: f'{x / 1e6:g}M' if x else '0')


def style(ax):
    for side in ('top', 'right', 'left'):
        ax.spines[side].set_visible(False)
    ax.spines['bottom'].set_color(GRID)
    ax.tick_params(axis='y', length=0)
    ax.grid(axis='x', color=GRID, linewidth=0.8)
    ax.set_axisbelow(True)
    ax.xaxis.set_major_formatter(millions)


def unit_assignment():
    # (label, unit assigned, unitless, no unit); E1 by part
    parts = [
        ('A  No unit, has a\nreference range', 172_788, 32_956, 94),
        ('B  Unit text with\nno unit concept', 49_089, 77, 6_263),
        ('C  No unit, no\nreference range', 585_519, 476_218, 4_680),
    ]
    fig, ax = plt.subplots(figsize=(8, 3.2))
    left = [0] * len(parts)
    labels = [p[0] for p in parts]
    # no-unit counts are too small to draw at this scale; they're in the labels
    for i, name in enumerate(['Unit assigned', 'Unitless']):
        vals = [p[i + 1] for p in parts]
        ax.barh(labels, vals, left=left, height=0.5, color=SERIES[i],
                edgecolor=SURFACE, linewidth=2, label=name)
        left = [l + v for l, v in zip(left, vals)]
    for y, (p, end) in enumerate(zip(parts, left)):
        ax.text(end + 12_000, y, f'{sum(p[1:]):,} records, {p[3]:,} with no unit',
                va='center', color=INK2, fontsize=9)
    ax.invert_yaxis()
    ax.set_xlim(0, 1_550_000)
    style(ax)
    ax.legend(loc='lower right', frameon=False, ncol=2, fontsize=9,
              bbox_to_anchor=(1, -0.38))
    ax.set_title('Records without a unit concept, by what they got',
                 loc='left', fontsize=11, fontweight='bold')
    fig.tight_layout()
    fig.savefig(OUT / 'unit_assignment.png', dpi=200)


def conversion():
    # 19a, records by conversion method
    rows = [
        ('Already in canonical unit', 5_519_682),
        ('Converted by unit factor', 943_792),
        ('Converted via molar mass or charge', 65_605),
        ('No fixed conversion', 3_185),
        ('Blocked: label contradicts values', 4),
    ]
    fig, ax = plt.subplots(figsize=(8, 2.8))
    ax.barh([r[0] for r in rows], [r[1] for r in rows], height=0.5,
            color=SERIES[0], edgecolor=SURFACE, linewidth=2)
    for y, (_, n) in enumerate(rows):
        ax.text(n + 40_000, y, f'{n:,}', va='center', color=INK2, fontsize=9)
    ax.invert_yaxis()
    ax.set_xlim(0, 6_400_000)
    style(ax)
    ax.set_title('Records with a unit, by conversion to the canonical unit',
                 loc='left', fontsize=11, fontweight='bold')
    fig.tight_layout()
    fig.savefig(OUT / 'conversion.png', dpi=200)


unit_assignment()
conversion()
