"""Audit carry-select bit and word errors against the model checked in RTL replay."""
import csv
from arithmetic import ROOT, extended_vectors, table, write_csv


def read(name):
    with (ROOT/"results"/name).open(encoding="utf-8") as source:
        return {r["design"]:r for r in csv.DictReader(source)}


def count_errors(stimuli):
    bit_errors = word_errors = 0
    for a,b,cin in stimuli:
        exact = a+b+cin
        predict_miss = cin and (a & 255) + (b & 255) == 255
        actual = exact - 256*predict_miss
        hamming = (exact ^ actual).bit_count()
        bit_errors += hamming
        word_errors += bool(hamming)
    count = len(stimuli)
    return dict(inputs=count, word_errors=word_errors, word_error_pct=100*word_errors/count,
                bit_errors=bit_errors, output_bits=17*count, bit_error_pct=100*bit_errors/(17*count))


def calculate():
    archive = [row[:3] for row in table(ROOT/"datasets/arithmetic/lfa-csa.csv.gz")]
    directed, random_stimuli = extended_vectors()
    cohorts = {"historical":archive, "historical_full_width_tail":archive[65536:],
               "all_replayed":[*archive,*directed,*random_stimuli]}
    metrics = {key:count_errors(stimuli) for key,stimuli in cohorts.items()}
    rtl = read("rtl_replay.csv")
    genus = read("genus.csv")
    accuracy, tradeoffs = [], []
    for arch in ("lfa","ksa","bka"):
        key = arch+"-csa"
        replay = rtl[key]
        assert int(replay["x_or_z"])==0 and int(replay["model_mismatches"])==0
        assert int(replay["historical_inputs_full_errors"])==metrics["historical"]["word_errors"]
        assert int(replay["all_full_errors"])==metrics["all_replayed"]["word_errors"]
        for cohort,stats in metrics.items():
            accuracy.append(dict(design=key,cohort=cohort,**stats))
        for variant in ("exact","csa"):
            label = arch+"-"+variant
            report = genus[label]
            width = 100*int(rtl[label]["historical_inputs_full_errors"])/len(archive)
            tradeoffs.append(dict(design=label, report_top=report["timing_top"],
                                  power_uw=float(report["total_w"])*1e6,
                                  data_path_ps=int(report["path_ps"]), word_error_pct=width,
                                  power_saved_pct=float(report["power_reduction_pct"]),
                                  area_saved_pct=float(report["area_reduction_pct"]),
                                  delay_increase_pct=-float(report["delay_reduction_pct"])))
    objectives = ("power_uw","data_path_ps","word_error_pct")
    for row in tradeoffs:
        row["pareto_nondominated"] = not any(
            all(other[key]<=row[key] for key in objectives) and
            any(other[key]<row[key] for key in objectives) for other in tradeoffs)
    write_csv(ROOT/"results/carry_select_accuracy.csv",accuracy)
    write_csv(ROOT/"results/carry_select_tradeoffs.csv",tradeoffs)


if __name__=="__main__":
    calculate()
