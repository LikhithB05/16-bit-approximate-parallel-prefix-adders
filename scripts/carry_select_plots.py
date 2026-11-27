"""Plot replayed word errors and the report-level exact/CSA Pareto comparison."""
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D

from carry_select import read
from plots import COLORS, csv_rows, save

ARCH = {"lfa":"Ladner–Fischer","ksa":"Kogge–Stone","bka":"Brent–Kung"}


def make():
    rows = read("rtl_replay.csv")
    variants = ("2","4","8","csa")
    fig,axes = plt.subplots(1,3,figsize=(11.7,3.55),layout="constrained",sharey=True)
    fig.suptitle("Historical stimulus replay · full 17-bit word error rate",x=.012,ha="left",fontweight="bold")
    for ax,(arch,name) in zip(axes,ARCH.items()):
        percentages = [100*int(rows[f"{arch}-{v}"]["historical_inputs_full_errors"])/
                       int(rows[f"{arch}-{v}"]["archive_vectors"]) for v in variants]
        ax.scatter(range(4),percentages,s=64,c=[COLORS[arch]]*3+["#1f2b3e"],zorder=5)
        for i,p in enumerate(percentages):
            ax.annotate(f"{p:.3f}%" if i==3 else f"{p:.2f}%",(i,p),xytext=(0,9),
                        textcoords="offset points",ha="center",fontsize=9)
        ax.set_title(name)
        ax.set(ylim=(.019,180),xlim=(-.48,3.5),yscale="log",xticks=range(4),
               xticklabels=["2-bit","4-bit","8-bit","Carry-select"])
        ax.grid(axis="y",color="#dbe5ed",zorder=0,which="major")
        ax.minorticks_off()
    axes[0].set_ylabel("Incorrect output words (%)")
    save(fig,"error-by-architecture")

    tradeoffs = csv_rows("carry_select_tradeoffs.csv")
    fig,ax = plt.subplots(figsize=(9.3,4.5),layout="constrained")
    fig.suptitle("Exact and carry-select · power, path delay and word error",x=.055,ha="left",fontweight="bold")
    for variant,marker in (("exact","o"),("csa","D")):
        points = [r for r in tradeoffs if r["design"].endswith(variant)]
        for r in points:
            arch = r["design"].split("-")[0]
            p,t = float(r["power_uw"]),int(r["data_path_ps"])
            kept = r["pareto_nondominated"]=="True"
            ax.scatter(t,p,s=94,marker=marker,facecolors=COLORS[arch] if kept else "white",
                       edgecolors=COLORS[arch],linewidths=1.5,zorder=4)
            dy = -12 if arch=="bka" and variant=="csa" else 3
            if arch=="lfa" and variant=="csa":
                dy = 9
            ax.annotate(arch.upper(),(t,p),xytext=(9,dy),textcoords="offset points",fontsize=10)
    ax.set(xlabel="Archived unconstrained data-path delay (ps)",ylabel="Archived total power (µW)",
           xlim=(1030,2850),ylim=(14,32))
    ax.grid(color="#dbe5ed",zorder=0)
    handles = [Line2D([],[],linestyle="none",marker=marker,color="#233b50",label=label)
               for marker,label in (("o","Exact · 0% word errors"),("D","Carry-select · 0.0371%"))]
    ax.legend(handles=handles,loc="upper right",frameon=False)
    ax.text(.02,.035,"Hollow marker = dominated in this six-row, three-metric comparison.",
            transform=ax.transAxes,fontsize=9)
    save(fig,"carry-select-pareto")


if __name__=="__main__":
    make()
