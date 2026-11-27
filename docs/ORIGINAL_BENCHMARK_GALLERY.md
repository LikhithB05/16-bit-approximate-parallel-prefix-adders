# Supporting Original Benchmark Gallery

This gallery presents the **61 unmodified rendered project figures** from the historical MATLAB/Verilog archive, grouped by **operation** and **architecture**, together with matching **display-crop comparisons**.

> **Provenance, Attribution & Metric Notes:**
> - **Display-crop metrics vs. raw demo metrics:** PSNR and SSIM values in [`archived-image-quality.csv`](../results/archived-image-quality.csv) are **display-crop comparisons** measured on fixed interior RGB crops (`(4,30,550,574)` for 554×578 LF/KS displays; `(326,55,909,638)` for 1193×719 BK displays) excluding figure margins and titles—not raw processing-domain rasters. For raw raster PSNR/SSIM with reproducible source code, see [`IMAGE_GALLERY.md`](IMAGE_GALLERY.md) and [`image_demo.csv`](../results/image_demo.csv).
> - **Benchmark input attribution:** Filter and addition figures process standard third-party grayscale test images (including *Lena*, *Rice*, and a historical cat image in the standalone brightness captures) strictly as historical experimental evidence authorized by the repository owner.
> - **Partial series & missing references:** Recovered Kogge–Stone addition captures (`ksaapprox2add.png`, `ksa4approxadd.png`, `ksaapprox8add.png`) lack a confirmed exact companion. Recovered KS and BK brightness captures lack confirmed exact baselines; the historical LFA brightness directory repeats Gaussian figures.
> - **Input script notes:** Historical addition scripts reference Lena and `rice1.png` (mixed script) or `pout.tif` and `rice.png` (standalone script, despite a `"Cameraman"` plot title). `"Cameraman"` is not used as a benchmark label because no Cameraman input or output was recovered.
> - **Image multiplication:** No separate image-multiplication implementation or experimental output was recovered (Gaussian weights and Sobel coefficients use shifts and integer constants).

---

## 1. Gaussian Filtering (Lena)

### Ladner–Fischer Gaussian (`LFA_Gaussian_*`)
| Exact | 2-bit | 4-bit | 8-bit | Carry-select |
|---|---|---|---|---|
| ![LFA Gaussian Exact](../assets/benchmarks/figures/LFA_Gaussian_Exact.png) | ![LFA Gaussian 2-bit](../assets/benchmarks/figures/LFA_Gaussian_approx2.png) | ![LFA Gaussian 4-bit](../assets/benchmarks/figures/LFA_Gaussian_approx4.png) | ![LFA Gaussian 8-bit](../assets/benchmarks/figures/LFA_Gaussian_approx8.png) | ![LFA Gaussian CSA](../assets/benchmarks/figures/LFA_Gaussian_CSA.png) |

*Display-crop PSNR vs. Exact: `55.73 dB` (2-bit), `55.73 dB` (4-bit), `20.20 dB` (8-bit), `inf` dB (CSA, SSIM `1.0`).*

### Kogge–Stone Gaussian (`KSA_Gaussian_*`)
| Exact | 2-bit | 4-bit | 8-bit | Carry-select |
|---|---|---|---|---|
| ![KSA Gaussian Exact](../assets/benchmarks/figures/KSA_Gaussian_Exact.png) | ![KSA Gaussian 2-bit](../assets/benchmarks/figures/KSA_Gaussian_Approx2.png) | ![KSA Gaussian 4-bit](../assets/benchmarks/figures/KSA_Gaussian_Approx4.png) | ![KSA Gaussian 8-bit](../assets/benchmarks/figures/KSA_Gaussian_Approx8.png) | ![KSA Gaussian CSA](../assets/benchmarks/figures/KSA_Gaussian_CSA.png) |

*Display-crop PSNR vs. Exact: `30.21 dB` (2-bit), `23.24 dB` (4-bit), `14.06 dB` (8-bit), `inf` dB (CSA, SSIM `1.0`).*

### Brent–Kung Gaussian (`gaussian_BKA*`)
| Exact | 2-bit | 4-bit | 8-bit | Carry-select |
|---|---|---|---|---|
| ![BKA Gaussian Exact](../assets/benchmarks/figures/gaussian_BKA.jpg.jpeg) | ![BKA Gaussian 2-bit](../assets/benchmarks/figures/BKA_Approx2_Gaussian.png) | ![BKA Gaussian 4-bit](../assets/benchmarks/figures/gaussian_BKA_4.jpg.jpeg) | ![BKA Gaussian 8-bit](../assets/benchmarks/figures/gaussian_BKA_8.jpg.jpeg) | ![BKA Gaussian CSA](../assets/benchmarks/figures/gaussian_BKA_CSA.jpg.jpeg) |

*Display-crop PSNR vs. Exact: `45.65 dB` (2-bit), `43.81 dB` (4-bit), `20.19 dB` (8-bit), `inf` dB (CSA, SSIM `1.0`).*

---

## 2. Mean Filtering (Lena)

### Ladner–Fischer Mean (`LFA_Mean_*`)
| Exact | 2-bit | 4-bit | 8-bit | Carry-select |
|---|---|---|---|---|
| ![LFA Mean Exact](../assets/benchmarks/figures/LFA_Mean_Exact.png) | ![LFA Mean 2-bit](../assets/benchmarks/figures/LFA_Mean_approx2.png) | ![LFA Mean 4-bit](../assets/benchmarks/figures/LFA_Mean_approx4.png) | ![LFA Mean 8-bit](../assets/benchmarks/figures/LFA_Mean_approx8.png) | ![LFA Mean CSA](../assets/benchmarks/figures/LFA_Mean_CSA.png) |

*Display-crop PSNR vs. Exact: `44.12 dB` (2-bit), `inf` dB (4-bit), `14.81 dB` (8-bit), `inf` dB (CSA).*

### Kogge–Stone Mean (`KSA_Mean_*`)
| Exact | 2-bit | 4-bit | 8-bit | Carry-select |
|---|---|---|---|---|
| ![KSA Mean Exact](../assets/benchmarks/figures/KSA_Mean_Exact.png) | ![KSA Mean 2-bit](../assets/benchmarks/figures/KSA_Mean_Approx2.png) | ![KSA Mean 4-bit](../assets/benchmarks/figures/KSA_Mean_Approx4.png) | ![KSA Mean 8-bit](../assets/benchmarks/figures/KSA_Mean_Approx8.png) | ![KSA Mean CSA](../assets/benchmarks/figures/KSA_Mean_CSA.png) |

*Display-crop PSNR vs. Exact: `23.51 dB` (2-bit), `11.23 dB` (4-bit), `9.43 dB` (8-bit), `inf` dB (CSA).*

### Brent–Kung Mean (`MEAN_BKA*`)
| Exact | 2-bit | 4-bit | 8-bit | Carry-select |
|---|---|---|---|---|
| ![BKA Mean Exact](../assets/benchmarks/figures/MEAN_BKA.jpg.jpeg) | ![BKA Mean 2-bit](../assets/benchmarks/figures/MEAN_BKA_2.jpg.jpeg) | ![BKA Mean 4-bit](../assets/benchmarks/figures/MEAN_BKA_4.jpg.jpeg) | ![BKA Mean 8-bit](../assets/benchmarks/figures/MEAN_BKA_8.jpg.jpeg) | ![BKA Mean CSA](../assets/benchmarks/figures/MEAN_BKA_CSA.jpg.jpeg) |

*Display-crop PSNR vs. Exact: `42.52 dB` (2-bit), `37.57 dB` (4-bit), `14.83 dB` (8-bit), `inf` dB (CSA).*

---

## 3. Horizontal Sobel Filtering (Lena)

### Ladner–Fischer Sobel (`LFA_Sobel_*`)
| Exact | 2-bit | 4-bit | 8-bit | Carry-select |
|---|---|---|---|---|
| ![LFA Sobel Exact](../assets/benchmarks/figures/LFA_Sobel_Exact.png) | ![LFA Sobel 2-bit](../assets/benchmarks/figures/LFA_Sobel_approx2.png) | ![LFA Sobel 4-bit](../assets/benchmarks/figures/LFA_Sobel_approx4.png) | ![LFA Sobel 8-bit](../assets/benchmarks/figures/LFA_Sobel_approx8.png) | ![LFA Sobel CSA](../assets/benchmarks/figures/LFA_Sobel_CSA.png) |

*Display-crop PSNR vs. Exact: `40.99 dB` (2-bit), `27.98 dB` (4-bit), `9.01 dB` (8-bit), `inf` dB (CSA).*

### Kogge–Stone Sobel (`KSA_Sobel_*`)
| Exact | 2-bit | 4-bit | 8-bit | Carry-select |
|---|---|---|---|---|
| ![KSA Sobel Exact](../assets/benchmarks/figures/KSA_Sobel_Exact.png) | ![KSA Sobel 2-bit](../assets/benchmarks/figures/KSA_Sobel_Approx2.png) | ![KSA Sobel 4-bit](../assets/benchmarks/figures/KSA_Sobel_Approx4.png) | ![KSA Sobel 8-bit](../assets/benchmarks/figures/KSA_Sobel_Approx8.png) | ![KSA Sobel CSA](../assets/benchmarks/figures/KSA_Sobel_CSA.png) |

*Display-crop PSNR vs. Exact: `17.53 dB` (2-bit), `9.77 dB` (4-bit), `2.43 dB` (8-bit), `inf` dB (CSA).*

### Brent–Kung Sobel (`SB_BKA*`)
| Exact | 2-bit | 4-bit | 8-bit | Carry-select |
|---|---|---|---|---|
| ![BKA Sobel Exact](../assets/benchmarks/figures/SB_BKA.jpg.jpeg) | ![BKA Sobel 2-bit](../assets/benchmarks/figures/SB_BKA_2.jpg.jpeg) | ![BKA Sobel 4-bit](../assets/benchmarks/figures/SB_BKA_4.jpg.jpeg) | ![BKA Sobel 8-bit](../assets/benchmarks/figures/SB_BKA_8.jpg.jpeg) | ![BKA Sobel CSA](../assets/benchmarks/figures/SB_BKACSA_.jpg.jpeg) |

*Display-crop PSNR vs. Exact: `38.76 dB` (2-bit), `27.70 dB` (4-bit), `9.03 dB` (8-bit), `inf` dB (CSA).*

---

## 4. Saturated Image Addition

### Ladner–Fischer Image Addition (Complete: `LFA_Imgadd_*`)
| Exact | 2-bit | 4-bit | 8-bit | Carry-select |
|---|---|---|---|---|
| ![LFA Imgadd Exact](../assets/benchmarks/figures/LFA_Imgadd_Exact.png) | ![LFA Imgadd 2-bit](../assets/benchmarks/figures/LFA_Imgadd_approx2.png) | ![LFA Imgadd 4-bit](../assets/benchmarks/figures/LFA_Imgadd_approx4.png) | ![LFA Imgadd 8-bit](../assets/benchmarks/figures/LFA_Imgadd_approx8.png) | ![LFA Imgadd CSA](../assets/benchmarks/figures/LFA_Imgadd_CSA.png) |

*Display-crop PSNR vs. Exact: `44.02 dB` (2-bit), `31.59 dB` (4-bit), `11.17 dB` (8-bit), `inf` dB (CSA).*

### Kogge–Stone Image Addition *(Partial Series — No Confirmed Exact Companion)*
| 2-bit (`ksaapprox2add.png`) | 4-bit (`ksa4approxadd.png`) | 8-bit (`ksaapprox8add.png`) |
|---|---|---|
| ![KSA 2-bit addition](../assets/benchmarks/figures/ksaapprox2add.png) | ![KSA 4-bit addition](../assets/benchmarks/figures/ksa4approxadd.png) | ![KSA 8-bit addition](../assets/benchmarks/figures/ksaapprox8add.png) |

---

## 5. Additional Brightness & Unresolved Captures *(Partial Series — No Confirmed Exact Companion)*

Exact baseline companions and run metadata are unresolved for these captures; no display-crop PSNR is reported.

### Kogge–Stone Brightness (`ksa_csa_brightness.png`, `ksaapprox*`)
| 2-bit (`ksaapprox2.png`) | 4-bit (`ksaapprox4brightness.png`) | 8-bit (`ksaapprox8.png`) | Carry-select (`ksa_csa_brightness.png`) |
|---|---|---|---|
| ![KSA 2-bit brightness](../assets/benchmarks/figures/ksaapprox2.png) | ![KSA 4-bit brightness](../assets/benchmarks/figures/ksaapprox4brightness.png) | ![KSA 8-bit brightness](../assets/benchmarks/figures/ksaapprox8.png) | ![KSA CSA brightness](../assets/benchmarks/figures/ksa_csa_brightness.png) |

### Brent–Kung Brightness (`bkaapprox*brightness.png`, `bkcsabrightness.png`)
| 2-bit (`bkaapprox2brightness.png`) | 4-bit (`bkaapprox4brightness.png`) | 8-bit (`bkaapprox8brightness.png`) | Carry-select (`bkcsabrightness.png`) |
|---|---|---|---|
| ![BKA 2-bit brightness](../assets/benchmarks/figures/bkaapprox2brightness.png) | ![BKA 4-bit brightness](../assets/benchmarks/figures/bkaapprox4brightness.png) | ![BKA 8-bit brightness](../assets/benchmarks/figures/bkaapprox8brightness.png) | ![BKA CSA brightness](../assets/benchmarks/figures/bkcsabrightness.png) |
