"""Evaluate source-derived adders on a deterministic grayscale test image."""
import math
from pathlib import Path
import csv

import numpy as np
from PIL import Image
from scipy.ndimage import gaussian_filter

from arithmetic import ROOT, write_csv
from prefix import adder


def quality(reference, output, peak=255):
    x,y = reference.astype(np.float64),output.astype(np.float64)
    if x.shape != y.shape:
        raise ValueError("Pixel formats or geometry differ")
    distance = y-x
    mse = float(np.mean(distance**2))
    avg = lambda image: gaussian_filter(image,1.5,radius=5,axes=(0,1))
    ux,uy = avg(x),avg(y)
    vx,vy = avg(x*x)-ux*ux,avg(y*y)-uy*uy
    cov = avg(x*y)-ux*uy
    c1,c2 = (peak*.01)**2,(peak*.03)**2
    ssim = ((2*ux*uy+c1)*(2*cov+c2))/((ux*ux+uy*uy+c1)*(vx+vy+c2))
    return dict(mae=float(np.mean(np.abs(distance))), mse=mse, rmse=math.sqrt(mse),
                psnr_db=10*math.log10(peak**2/mse) if mse else math.inf,
                ssim=float(ssim[5:-5,5:-5].mean()), peak=peak,
                max_error=int(np.max(np.abs(distance))),
                changed_samples=int(np.count_nonzero(distance)), samples=distance.size)


def test_target():
    y,x = np.indices((192,192),dtype=np.int32)
    image = 27 + x*174//191 + 9*((x+y)%17<5)
    stipple = (x-50)**2 + (y-50)**2 < 32**2
    image[stipple] = (65 + 134*((x+y)%11<4))[stipple]
    block = (x>108)&(x<173)&(y>22)&(y<86)
    image[block] = (34+189*((x//6+y//6)%2))[block]
    line = (y>112)&(y<172)
    image[line] = (24+(x*4+y*3+(y%9)*11)%215)[line]
    second = (3*x+5*y+7*(x%11))%188
    return image,second


def csa(a,b):
    return a+b  # With Cin=0 the lower prefix correctly selects the upper carry branch.


def pipeline(image, second, add):
    windows = np.lib.stride_tricks.sliding_window_view(image,(3,3))
    p = [windows[...,i//3,i%3] for i in range(9)]

    def word(a,b):
        return add(a,b) & 65535

    def accumulate(values):
        total = values[0]
        for sample in values[1:]:
            total = word(total,sample)
        return total

    def border(interior):
        return np.pad(np.clip(interior,0,255),(1,1))

    gaussian = accumulate([p[i]*w for i,w in enumerate((1,2,1,2,4,2,1,2,1))])//16
    mean = accumulate(p)//9
    right = accumulate([p[2],2*p[5],p[8]])
    left = accumulate([p[0],2*p[3],p[6]])
    gradient = word(right,-left & 65535)
    gradient = np.where(gradient>=32768,gradient-65536,gradient)
    return dict(gaussian=border(gaussian), mean=border(mean), sobel_x=border(np.abs(gradient)),
                image_add=np.clip(word(image,second),0,255),
                brightness=np.clip(word(image,40),0,255))


def save(path, values):
    Image.fromarray(values.astype(np.uint8)).save(path)


def run():
    output_dir = ROOT / "image_processing" / "demo"
    output_dir.mkdir(exist_ok=True)
    image,second = test_target()
    save(output_dir/"input.png",image)
    save(output_dir/"second-input.png",second)
    reference = pipeline(image,second,csa)
    with (ROOT/"rtl/designs.csv").open() as source:
        designs = list(csv.DictReader(source))
    results = []
    for design in designs:
        variant = design["variant"]
        label = design["architecture"].lower()+"-"+variant
        add = csa if variant == "csa" else adder(ROOT/design["rtl"])
        for operation,values in pipeline(image,second,add).items():
            metrics = quality(reference[operation],values)
            save(output_dir/f"{label}-{operation}.png",values)
            results.append(dict(design=label,operation=operation,**metrics))
    write_csv(ROOT/"results/image_demo.csv",results)


if __name__ == "__main__":
    run()
