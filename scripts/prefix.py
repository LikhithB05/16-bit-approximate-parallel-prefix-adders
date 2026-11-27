"""Read the project's explicit prefix-cell netlists for diagrams and software replay."""
from collections import Counter
from dataclasses import dataclass
import re
from html import escape

from arithmetic import ROOT, write_csv

SIGNAL = r"[GP]\w*(?:\[\d+_?\])?"
INSTANCE = re.compile(r"^\s*(gp_operator|approx_gp_operator)\s+(\w+)\s*\(([^)]+)\);",re.M)
ALIAS = re.compile(rf"\bassign\s+({SIGNAL})\s*=\s*({SIGNAL})\s*;")


@dataclass
class Node:
    name: str
    bit: int
    depth: int
    low: str | None = None
    high: str | None = None
    bypass: bool = False


def load(path):
    source = re.sub(r"/\*.*?\*/|//[^\r\n]*", "", path.read_text(encoding="utf-8-sig"), flags=re.S)
    source_pairs = [(kind,name,args.replace("_]","]").replace(" ","").split(","))
                    for kind,name,args in INSTANCE.findall(source)]
    aliases = {left.replace("_]","]"):right.replace("_]","]")
               for left,right in ALIAS.findall(source)}
    drivers = {args[4]:(kind,name,args[0],args[2]) for kind,name,args in source_pairs}
    assert len(drivers) == len(source_pairs)
    nodes = {f"G[{i}]":Node(f"G[{i}]",i,0) for i in range(16)}
    visited = {}

    def resolve(signal):
        if signal in visited:
            return visited[signal]
        if signal in aliases:
            result = resolve(aliases[signal])
        else:
            result = signal
            if signal in drivers:
                kind,name,low,high = drivers[signal]
                lo,hi = resolve(low),resolve(high)
                nodes[signal] = Node(name, nodes[hi].bit, 1+max(nodes[lo].depth,nodes[hi].depth),
                                     lo,hi,kind.startswith("approx"))
            elif signal not in nodes:
                raise ValueError(f"Undriven signal {signal} in {path.name}")
        visited[signal] = result
        return result

    outputs = [resolve(f"G_final[{i}]") for i in range(16)]
    for signal in drivers:
        resolve(signal)
    return nodes, outputs


def adder(path):
    nodes, outputs = load(path)

    def add(a,b,cin=0):
        prop = a ^ b
        gen = a & b
        values = {f"G[{i}]":((gen>>i)&1,(prop>>i)&1) for i in range(16)}
        for signal,node in nodes.items():
            if node.low is not None:
                g_hi,p_hi = values[node.high]
                g_lo,p_lo = values[node.low]
                values[signal] = ((g_hi,p_hi) if node.bypass else
                                  (g_hi | (p_hi & g_lo), p_hi & p_lo))
        carry = cin
        for index,signal in enumerate(outputs,1):
            g,p = values[signal]
            carry = carry | ((g | (p & cin)) << index)
        return prop ^ carry

    return add


def diagram(arch,nodes,outputs):
    depth = max(nodes[s].depth for s in outputs)
    width = 1020
    height = 190 + depth*52

    def x(bit):
        return 76 + 57*(15-bit)

    def y(node):
        return 95 + 52*node.depth

    svg = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
           '<rect width="100%" height="100%" rx="18" fill="#0f2032"/>',
           '<g font-family="monospace" fill="#eff6ff">',
           f'<text x="35" y="40" font-size="24">{arch} exact adder · RTL prefix dependencies</text>',
           '<text x="35" y="64" font-size="13" fill="#a6bbd0">Vertical placement shows operator depth. Gold edges select the prefix used for the next carry.</text>']
    for bit,signal in enumerate(outputs):
        node=nodes[signal]
        svg.append(f'<path d="M{x(bit)} {y(node)}v{height-55-y(node)}" stroke="#f6c477" '
                   'stroke-opacity=".75" stroke-dasharray="4 4"/>')
        svg.append(f'<text x="{x(bit)}" y="{height-33}" text-anchor="middle" font-size="13">C{bit+1}</text>')
    for node in nodes.values():
        for edge,color in ((node.low,"#50a5ca"),(node.high,"#b8d4f0")):
            if edge is None:
                continue
            child=nodes[edge]
            svg.append(f'<path d="M{x(child.bit)} {y(child)} L{x(node.bit)} {y(node)}" stroke="{color}" '
                       'stroke-opacity=".75" fill="none"/>')
    for node in nodes.values():
        fill = "#46d6ca" if node.depth else "#b6c8db"
        svg.append(f'<circle cx="{x(node.bit)}" cy="{y(node)}" r="{5 if node.depth else 3.5}" fill="{fill}">'
                   f'<title>{escape(node.name)}</title></circle>')
        if node.depth == 0:
            svg.append(f'<text x="{x(node.bit)}" y="84" font-size="10" text-anchor="middle">{node.bit}</text>')
    svg.append("</g></svg>")
    return "\n".join(svg)


if __name__ == "__main__":
    import csv
    with (ROOT/"rtl/designs.csv").open() as source:
        designs = list(csv.DictReader(source))
    rows = []
    for design in designs:
        arch,variant = design["architecture"],design["variant"]
        if variant == "csa":
            continue
        nodes,outputs = load(ROOT/design["rtl"])
        cells = [n for n in nodes.values() if n.low is not None]
        loads = Counter([s for n in cells for s in (n.low,n.high)] + outputs)
        rows.append(dict(architecture=arch, variant=variant, top=design["top"], 
                         prefix_cells=len(cells), replaced_cells=sum(n.bypass for n in cells),
                         deepest_prefix=max(nodes[s].depth for s in outputs),
                         max_pair_loads=max(loads.values()),
                         replaced_labels=" ".join(n.name for n in cells if n.bypass)))
        if variant == "exact":
            (ROOT/"assets"/f"{arch.lower()}-exact.svg").write_text(diagram(arch,nodes,outputs),encoding="utf-8")
    write_csv(ROOT/"results/prefix_structure.csv",rows)
