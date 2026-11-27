"""Regenerate the plots and publication-safe image comparison."""
import csv
import math

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from PIL import Image

from arithmetic import ROOT

COLORS = {"lfa":"#167d77", "ksa":"#385fa5", "bka":"#ba602a"}
plt.rcParams.update({"font.family":"DejaVu Sans","font.size":11,"axes.spines.top":False,
                     "axes.spines.right":False,"axes.labelcolor":"#233b50","text.color":"#122b45",
                     "axes.titleweight":"bold","figure.facecolor":"#ffffff",
                     "savefig.bbox":"tight","svg.fonttype":"none","svg.hashsalt":"prefix-study"})


def csv_rows(name):
    with (ROOT/"results"/name).open() as source:
        return list(csv.DictReader(source))


def save(fig,name):
    fig.savefig(ROOT/"assets"/f"{name}.svg",metadata={"Date":None})
    plt.close(fig)


def bars(ax, rows, widths, field, scale=1):
    for index,(arch,color) in enumerate(COLORS.items()):
        values = [(i+(index-1)*.23, float(rows[f"{arch}-{w}"][field])*scale)
                  for i,w in enumerate(widths) if rows[f"{arch}-{w}"][field]]
        ax.bar(*zip(*values),width=.22,color=color,label=arch.upper(),zorder=3)
    ax.set_xticks(range(len(widths)),["Exact" if w=="exact" else w.upper() for w in widths])
    ax.grid(axis="y",color="#dde7ed",zorder=0)


def make():
    arithmetic = {r["design"]:r for r in csv_rows("arithmetic.csv")}
    ppa = {r["design"]:r for r in csv_rows("genus.csv")}
    fig,axes = plt.subplots(1,3,figsize=(12,3.5),layout="constrained")
    fig.suptitle("Archived arithmetic · 75,536 shared stimuli per design",fontweight="bold",x=.03,ha="left")
    for ax,field,scale,title in zip(axes,("error_rate","mae","worst"),(100,1,1),
                                  ("Incorrect low words (%)","Mean absolute error (LSB)","Observed worst error (LSB)")):
        bars(ax,arithmetic,("2","4","8"),field,scale)
        ax.set_title(title)
        ax.set_xlabel("Approximation width (bits)")
    axes[2].set_yscale("log")
    axes[2].set_ylim(1,120000)
    axes[0].legend(frameon=False,loc="upper left")
    save(fig,"arithmetic")

    fig,axes = plt.subplots(1,3,figsize=(12,3.6),layout="constrained")
    fig.suptitle("Archived Genus reports · nominal configuration labels",fontweight="bold",x=.03,ha="left")
    for ax,field,scale,title in zip(axes,("total_w","cell_area","path_ps"),(1e6,1,1),
                                  ("Total power (µW)","Library cell area","Unconstrained path (ps)")):
        bars(ax,ppa,("exact","2","4","8","csa"),field,scale)
        ax.set_title(title)
    axes[0].legend(frameon=False,loc="upper right")
    axes[2].annotate("BKA 4-bit path\nreport unavailable",(2.23,20),xytext=(1.3,460),
                     arrowprops={"arrowstyle":"-","color":"#b85b31"},fontsize=8)
    save(fig,"genus")

    img = {(r["design"],r["operation"]):r for r in csv_rows("image_demo.csv")}
    operations = ("gaussian","mean","sobel_x","image_add","brightness")
    titles = ("Gaussian","Mean","Sobel X","Image addition","Brightness")
    fig,axes = plt.subplots(len(operations),5,figsize=(10,10.3),layout="constrained")
    fig.suptitle("Ladner–Fischer · deterministic grayscale test target",fontweight="bold",x=.02,ha="left")
    folder = ROOT/"image_processing/demo"
    for i,(operation,title) in enumerate(zip(operations,titles)):
        for j,label in enumerate(("Input","Exact","2-bit","4-bit","8-bit")):
            ax=axes[i,j]
            variant = ("","exact","2","4","8")[j]
            path=folder/(f"lfa-{variant}-{operation}.png" if variant else "input.png")
            with Image.open(path) as display:
                ax.imshow(np.array(display),vmin=0,vmax=255,cmap="gray")
            ax.set_xticks([])
            ax.set_yticks([])
            for spine in ax.spines.values():
                spine.set_visible(False)
            if i==0:
                ax.set_title(label)
            if j==0:
                ax.set_ylabel(title)
            if j>1:
                psnr=float(img[f"lfa-{variant}",operation]["psnr_db"])
                ax.set_xlabel(f"{psnr:.1f} dB" if math.isfinite(psnr) else "∞ dB")
    fig.savefig(ROOT/"assets/image-demo.png",dpi=125)
    plt.close(fig)
    fig,ax = plt.subplots(figsize=(10,3.7),layout="constrained")
    for index,(operation,title) in enumerate(zip(operations,titles)):
        xs = range(3)
        y = [float(img[f"ksa-{variant}",operation]["psnr_db"]) for variant in ("2","4","8")]
        ax.scatter([i+(index-2)*.11 for i in xs if math.isfinite(y[i])],
                   [p for p in y if math.isfinite(p)],label=title,s=45,zorder=3)
    ax.set_title("Kogge–Stone · image sensitivity on the deterministic target",loc="left")
    ax.set(xlabel="Approximation width (bits)",ylabel="Finite PSNR (dB)",
           xticks=range(3),xticklabels=["2","4","8"],ylim=(0,58))
    ax.grid(axis="y",color="#dde7ed")
    ax.legend(frameon=False,ncol=3)
    save(fig,"image-psnr")


if __name__=="__main__":
    make()
