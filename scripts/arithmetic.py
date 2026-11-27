"""Check historical spreadsheets as exported and optionally replay their operands in Icarus."""
import argparse
from collections import Counter
import csv
import gzip
import hashlib
import math
from pathlib import Path
import random
import shutil
import subprocess
from tempfile import TemporaryDirectory

ROOT = Path(__file__).resolve().parents[1]


def table(path):
    with gzip.open(path, "rt", encoding="utf-8", newline="") as source:
        for row in csv.DictReader(source):
            if row["A_hex"].startswith("# TOTAL_CASES = "):
                continue
            yield (int(row["A_hex"], 16), int(row["B_hex"], 16), int(row["Cin"]),
                   int(row["Exact_hex"], 16), int(row["Approx_hex"], 16),
                   int(row["ED"]), int(row["AED"]), float(row["MRED"]), int(row["isError"]))


def write_csv(path, rows):
    with path.open("w", newline="", encoding="utf-8") as output:
        writer = csv.DictWriter(output, rows[0].keys(), lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


def metrics(errors, reference):
    n = len(errors)
    count = sum(error != 0 for error in errors)
    mean = sum(errors) / n
    mse = sum(error**2 for error in errors) / n
    return dict(n=n, errors=count, error_rate=count/n,
                correct_rate=1-count/n, bias=mean,
                min_signed=min(errors), max_signed=max(errors),
                mae=sum(map(abs, errors))/n, mse=mse, rmse=math.sqrt(mse),
                std=math.sqrt(max(0, mse-mean**2)),
                mred_nonzero=sum(abs(e)/r for e, r in zip(errors, reference) if r) /
                sum(bool(r) for r in reference), worst=max(map(abs, errors)))


def audit():
    all_rows = []
    histogram = []
    origin = None
    for path in sorted((ROOT / "datasets/arithmetic").glob("*.csv.gz")):
        label = path.name.removesuffix(".csv.gz")
        records = list(table(path))
        triples = [r[:3] for r in records]
        assert all(0 <= a <= 65535 and 0 <= b <= 65535 and c in (0, 1) for a,b,c in triples)
        assert all(0 <= r[3] <= 65535 and 0 <= r[4] <= 65535 for r in records)
        reference = [(a+b+c) & 65535 for a,b,c in triples]
        errors = [r[4]-ref for r,ref in zip(records, reference)]
        if origin is None:
            origin = triples
        all_rows.append(dict(
            design=label, **metrics(errors,reference),
            unique_triples=len(set(triples)), unique_pairs=len(set((a,b) for a,b,_ in triples)),
            matches_first_stimuli=sum(a==b for a,b in zip(triples,origin)),
            cin1=sum(x[2] for x in triples), reference_zero=reference.count(0),
            ordered_8bit_sweep=sum(t==(i//256,i%256,0) for i,t in enumerate(triples[:65536])),
            tail_error_rate=sum(e!=0 for e in errors[65536:])/len(errors[65536:]),
            a_min=min(x[0] for x in triples), a_max=max(x[0] for x in triples),
            b_min=min(x[1] for x in triples), b_max=max(x[1] for x in triples),
            overflow=sum(sum(x)>65535 for x in triples),
            wrong_reference=sum(r[3]!=ref for r,ref in zip(records,reference)),
            ed_mismatch=sum(r[5]!=r[3]-r[4] for r in records),
            aed_mismatch=sum(r[6]!=abs(r[4]-r[3]) for r in records),
            mred_mismatch=sum(not math.isclose(r[7], abs(r[4]-r[3])/r[3] if r[3] else 0,
                                               rel_tol=1e-12, abs_tol=0.5000001e-6) for r in records),
            flag_mismatch=sum(r[8]!=int(r[4]!=r[3]) for r in records),
            recorded_mae=sum(r[6] for r in records)/len(records),
            recorded_mred=sum(r[7] for r in records)/len(records),
            output_digest=hashlib.sha256(bytes().join(r[4].to_bytes(2,"little") for r in records)).hexdigest()))
        for distance, count in sorted(Counter(errors).items()):
            histogram.append(dict(design=label, signed_error=distance, count=count))
    write_csv(ROOT / "results/arithmetic.csv", all_rows)
    write_csv(ROOT / "results/arithmetic_distribution.csv", histogram)
    return origin


def extended_vectors():
    rng = random.Random(20261127)
    critical = (0, 1, 3, 7, 15, 127, 255, 256, 0x5555, 0xAAAA, 0x7FFF, 0xFFFF)
    directed = [(a,b,c) for a in critical for b in critical for c in (0,1)]
    random_vectors = [(rng.randrange(65536), rng.randrange(65536), rng.randrange(2))
                      for _ in range(4096)]
    return directed, random_vectors


def simulate(triples, iverilog, vvp, allow_msys2_driver_exit=False):
    import numpy as np
    from prefix import adder

    with (ROOT / "rtl/designs.csv").open(encoding="utf-8") as source:
        designs = list(csv.DictReader(source))
    template = (ROOT / "testbench/replay_tb.sv").read_text(encoding="utf-8")
    directed, random_vectors = extended_vectors()
    stimuli = [*triples, *directed, *random_vectors]
    expected = [sum(t) for t in stimuli]
    a_values,b_values,cin_values = np.asarray(stimuli,dtype=np.int32).T
    all_rows = []
    with TemporaryDirectory(prefix="prefix_replay_") as temp:
        temp = Path(temp)
        vectors = temp / "vectors.txt"
        vectors.write_text("".join(f"{a:04x} {b:04x} {c}\n" for a,b,c in stimuli), encoding="ascii")
        for design in designs:
            variant = design["variant"]
            label = design["architecture"].lower() + "-" + variant
            bench = temp / "replay_tb.sv"
            compiled = temp / "replay.vvp"
            bench.write_text(template.replace("__DUT__", design["top"]), encoding="utf-8")
            if compiled.exists():
                compiled.unlink()
            compile_run = subprocess.run([iverilog, "-g2012", "-s", "replay_tb", "-o",
                                          compiled.name, ROOT / design["rtl"], bench.name],
                                         cwd=temp, capture_output=True, text=True)
            if compile_run.returncode:
                if (not allow_msys2_driver_exit or compile_run.returncode != 0xC0000005
                        or compile_run.stderr.strip() or not compiled.exists() or not compiled.stat().st_size):
                    raise RuntimeError(f"{label}: {compile_run.returncode}\n{compile_run.stderr}")
            execution = subprocess.run([vvp, compiled.name, f"+vectors={vectors.name}"],
                                       cwd=temp, check=True, capture_output=True, text=True)
            if execution.stderr.strip():
                raise RuntimeError(execution.stderr)
            tokens = execution.stdout.splitlines()
            assert len(tokens) == len(stimuli), execution.stdout[-500:]
            outputs = [int(t,16) if all(c in "0123456789abcdefABCDEF" for c in t) else None
                       for t in tokens]
            unknown = outputs.count(None)
            n = len(triples)
            paired = list(zip(outputs, expected))
            full_bad = sum(a!=b for a,b in paired)
            exact_bad = sum(a!=b for a,b in paired[:n])
            archive_mismatch = ""
            archive = ROOT / "datasets/arithmetic" / (label+".csv.gz")
            if archive.exists():
                rec = list(table(archive))
                assert len(rec) == n and all(r[:3] == t for r,t in zip(rec,triples))
                archive_mismatch = sum(out is None or (out & 65535)!=r[4]
                                       for out,r in zip(outputs,rec))
            histogram = Counter(diff for out,ref in paired if out is not None
                                for diff in [out-ref])
            fresh = dict(mae_full=sum(abs(delta)*count for delta,count in histogram.items())/
                         max(1, len(stimuli)-unknown), worst_full=max(map(abs,histogram),default=0))
            examples = "|".join(f"{a:04x}+{b:04x}+{c}={out!s}/{ref}"
                                for (a,b,c),(out,ref) in list(
                                    (p for p in zip(stimuli,paired) if p[1][0]!=p[1][1]))[:3])
            if variant == "csa":
                # The bit-8 predictor is the lower block carry computed with Cin forced to zero.
                model = a_values + b_values + cin_values - 256 * (
                    ((a_values & 255) + (b_values & 255) == 255) & (cin_values == 1))
            else:
                model = adder(ROOT / design["rtl"])(a_values,b_values,cin_values)
            all_rows.append(dict(design=label, top=design["top"],
                                 archive_vectors=n, directed=len(directed), random=len(random_vectors),
                                 x_or_z=unknown, archive_sum_mismatches=archive_mismatch,
                                 model_mismatches=sum(out!=ref for out,ref in zip(outputs,model.tolist())),
                                 historical_inputs_full_errors=exact_bad, all_full_errors=full_bad,
                                 directed_full_errors=sum(a!=b for a,b in paired[n:n+len(directed)]),
                                 random_full_errors=sum(a!=b for a,b in paired[n+len(directed):]),
                                 **fresh, examples=examples))
            print(label, "unknown", unknown, "archive sum mismatches", archive_mismatch,
                  "full errors", full_bad, flush=True)
    write_csv(ROOT / "results/rtl_replay.csv", all_rows)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--simulate", action="store_true")
    parser.add_argument("--iverilog", default=shutil.which("iverilog") or "iverilog")
    parser.add_argument("--vvp", default=shutil.which("vvp") or "vvp")
    parser.add_argument("--allow-msys2-driver-exit", action="store_true",
                        help="accept only the observed Windows compiler driver exit after clean bytecode generation")
    args = parser.parse_args()
    vectors = audit()
    if args.simulate:
        simulate(vectors, args.iverilog, args.vvp, args.allow_msys2_driver_exit)
