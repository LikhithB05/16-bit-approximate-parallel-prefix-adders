# Reproduce the analysis

Use Python 3.10 or newer. The archived arithmetic audit and PPA parser use the standard library. Simulation requires Icarus Verilog (`iverilog` and `vvp` on PATH). Image and plot dependencies are in [requirements.txt](../requirements.txt).

```sh
python scripts/arithmetic.py
python -m pip install -r requirements.txt
python scripts/arithmetic.py --simulate
python scripts/prefix.py
python scripts/images.py
python scripts/plots.py
python scripts/carry_select.py
python scripts/carry_select_plots.py
```

The replay processes every historical row after excluding its footer. It compiles one design per invocation of Icarus and adds the seeded and directed suites. To use a particular simulator installation pass `--iverilog` and `--vvp` with the executable paths. The archived Windows package used during review emitted valid bytecode but returned `0xC0000005` at exit. `--allow-msys2-driver-exit` permits precisely that exit with clean compiler stderr and a newly generated nonempty output. The replay still requires silent successful `vvp` execution, the complete expected output count, and checked output words. A standard Icarus setup needs no override. [Official Icarus installation guide](https://steveicarus.github.io/iverilog/usage/installation.html)

For a single original testbench, compile the corresponding one-file design:

```sh
iverilog -g2012 -s Brkung_tb -o brkung.vvp rtl/bka/exact.v testbench/Brkung_tb.v
vvp -n brkung.vvp
```

The original 80-vector Ladner–Fischer monitor references the historical top `perfectladner`. The local adapter connects its interface to the recovered exact `ladner` implementation.

```sh
iverilog -g2012 -s testbench -o ladner.vvp rtl/lfa/exact.v testbench/ladner_legacy_adapter.v testbench/ladner_legacy.v
vvp -n ladner.vvp
```

To regenerate the extracted Genus table, point the parser at your authorized historical report directory. It expects `LFA (syn)`, `KSA(syn)` and `BKA(syn)` as immediate subdirectories.

```sh
python scripts/ppa.py path/to/SYNTHESIS
```

Pass `--legacy "path/to/All codes and results"` to extract the earlier four-report Ladner–Fischer series separately.

A clean ASIC rerun requires a licensed Cadence Genus environment and access to the specific 90 nm GPDK timing library, library corner, synthesis setup, activity definitions and explicit RTL file selection. Contact the original authors for those credentials-free inputs through the institution’s authorized access process. The public table is sufficient for checking arithmetic on reported measurements and regenerating the plots.

The reproducible image workflow uses generated grayscale inputs and a checked prefix evaluator. It writes PNGs to `image_processing/demo/` and numeric results to `results/image_demo.csv`.

Ten archived [MATLAB-only examples](../image_processing/historical_matlab) are provided with local filenames in `imread` calls. To inspect a historical model with MATLAB and Image Processing Toolbox, place a permitted input image in the current directory, update the selected script’s input name, and use `run` on the script. Image addition needs a second input. The original benchmark image files and final-run settings are unavailable here. MATLAB execution was not rerun in this review. The combined MATLAB/Verilog handoff scripts remain in the independent evidence copy. [Image methodology](IMAGING.md)
