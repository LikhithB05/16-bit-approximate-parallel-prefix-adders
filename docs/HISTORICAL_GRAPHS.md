# Historical Mini project graphs

These are the original archived project PNGs (`END/GRAPHS/*.png`). Some labels differ from the workbook audit and fresh RTL replay:

- **MAE discrepancy:** The original LFA and BKA MAE plots show values (`1.4648`, `5.8421`, `82.9135`) that differ from the recalculated workbook low-word MAEs (`0.501695`, `3.506990`, `71.313281`).
- **Carry-select discrepancy:** The original CSA rate plots differ by architecture, whereas fresh RTL replay across the shared 75,536 historical vectors produces an identical **28 errors** (`0.03707%`) for each of Ladner–Fischer, Kogge–Stone, and Brent–Kung (all in the 5,071 `Cin = 1` tail cases, `0.55216%`).
- The main [README](../README.md) charts (`assets/error-by-architecture.svg`, `assets/arithmetic.svg`) use the audited workbook and verified RTL replay counts.

## Ladner–Fischer

| Error rate | MAE | MRED | Worst-case error |
|---|---|---|---|
| ![Ladner–Fischer original Error rate](../assets/benchmarks/graphs/LFA_Error_Rate.png) | ![Ladner–Fischer original Mean absolute error](../assets/benchmarks/graphs/LFA_MAE.png) | ![Ladner–Fischer original Mean relative error distance](../assets/benchmarks/graphs/LFA_MRED.png) | ![Ladner–Fischer original Worst-case error](../assets/benchmarks/graphs/LFA_WCE.png) |

## Kogge–Stone

| Error rate | MAE | MRED | Worst-case error |
|---|---|---|---|
| ![Kogge–Stone original Error rate](../assets/benchmarks/graphs/KSA_Error_Rate.png) | ![Kogge–Stone original Mean absolute error](../assets/benchmarks/graphs/KSA_MAE.png) | ![Kogge–Stone original Mean relative error distance](../assets/benchmarks/graphs/KSA_MRED.png) | ![Kogge–Stone original Worst-case error](../assets/benchmarks/graphs/KSA_WCE.png) |

## Brent–Kung

| Error rate | MAE | MRED | Worst-case error |
|---|---|---|---|
| ![Brent–Kung original Error rate](../assets/benchmarks/graphs/BKA_Error_Rate.png) | ![Brent–Kung original Mean absolute error](../assets/benchmarks/graphs/BKA_MAE.png) | ![Brent–Kung original Mean relative error distance](../assets/benchmarks/graphs/BKA_MRED.png) | ![Brent–Kung original Worst-case error](../assets/benchmarks/graphs/BKA_WCE.png) |
