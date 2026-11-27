# Reproducible image gallery

The galleries use the same fixed-grayscale source. Rows correspond to the exact, 2-bit, 4-bit, 8-bit and carry-select versions of each architecture. The [per-output quality table](../results/image_demo.csv) contains PSNR and SSIM for all 75 combinations. [Primary target](../image_processing/demo/input.png) · [Second addition input](../image_processing/demo/second-input.png)

## Ladner–Fischer

| Design | Gaussian | Mean | Sobel X | Addition | Brightness |
|---|---|---|---|---|---|
| Exact | ![LFA exact gaussian](../image_processing/demo/lfa-exact-gaussian.png) | ![LFA exact mean](../image_processing/demo/lfa-exact-mean.png) | ![LFA exact sobel_x](../image_processing/demo/lfa-exact-sobel_x.png) | ![LFA exact image_add](../image_processing/demo/lfa-exact-image_add.png) | ![LFA exact brightness](../image_processing/demo/lfa-exact-brightness.png) |
| 2-bit | ![LFA 2 gaussian](../image_processing/demo/lfa-2-gaussian.png) | ![LFA 2 mean](../image_processing/demo/lfa-2-mean.png) | ![LFA 2 sobel_x](../image_processing/demo/lfa-2-sobel_x.png) | ![LFA 2 image_add](../image_processing/demo/lfa-2-image_add.png) | ![LFA 2 brightness](../image_processing/demo/lfa-2-brightness.png) |
| 4-bit | ![LFA 4 gaussian](../image_processing/demo/lfa-4-gaussian.png) | ![LFA 4 mean](../image_processing/demo/lfa-4-mean.png) | ![LFA 4 sobel_x](../image_processing/demo/lfa-4-sobel_x.png) | ![LFA 4 image_add](../image_processing/demo/lfa-4-image_add.png) | ![LFA 4 brightness](../image_processing/demo/lfa-4-brightness.png) |
| 8-bit | ![LFA 8 gaussian](../image_processing/demo/lfa-8-gaussian.png) | ![LFA 8 mean](../image_processing/demo/lfa-8-mean.png) | ![LFA 8 sobel_x](../image_processing/demo/lfa-8-sobel_x.png) | ![LFA 8 image_add](../image_processing/demo/lfa-8-image_add.png) | ![LFA 8 brightness](../image_processing/demo/lfa-8-brightness.png) |
| Carry-select | ![LFA csa gaussian](../image_processing/demo/lfa-csa-gaussian.png) | ![LFA csa mean](../image_processing/demo/lfa-csa-mean.png) | ![LFA csa sobel_x](../image_processing/demo/lfa-csa-sobel_x.png) | ![LFA csa image_add](../image_processing/demo/lfa-csa-image_add.png) | ![LFA csa brightness](../image_processing/demo/lfa-csa-brightness.png) |

## Kogge–Stone

| Design | Gaussian | Mean | Sobel X | Addition | Brightness |
|---|---|---|---|---|---|
| Exact | ![KSA exact gaussian](../image_processing/demo/ksa-exact-gaussian.png) | ![KSA exact mean](../image_processing/demo/ksa-exact-mean.png) | ![KSA exact sobel_x](../image_processing/demo/ksa-exact-sobel_x.png) | ![KSA exact image_add](../image_processing/demo/ksa-exact-image_add.png) | ![KSA exact brightness](../image_processing/demo/ksa-exact-brightness.png) |
| 2-bit | ![KSA 2 gaussian](../image_processing/demo/ksa-2-gaussian.png) | ![KSA 2 mean](../image_processing/demo/ksa-2-mean.png) | ![KSA 2 sobel_x](../image_processing/demo/ksa-2-sobel_x.png) | ![KSA 2 image_add](../image_processing/demo/ksa-2-image_add.png) | ![KSA 2 brightness](../image_processing/demo/ksa-2-brightness.png) |
| 4-bit | ![KSA 4 gaussian](../image_processing/demo/ksa-4-gaussian.png) | ![KSA 4 mean](../image_processing/demo/ksa-4-mean.png) | ![KSA 4 sobel_x](../image_processing/demo/ksa-4-sobel_x.png) | ![KSA 4 image_add](../image_processing/demo/ksa-4-image_add.png) | ![KSA 4 brightness](../image_processing/demo/ksa-4-brightness.png) |
| 8-bit | ![KSA 8 gaussian](../image_processing/demo/ksa-8-gaussian.png) | ![KSA 8 mean](../image_processing/demo/ksa-8-mean.png) | ![KSA 8 sobel_x](../image_processing/demo/ksa-8-sobel_x.png) | ![KSA 8 image_add](../image_processing/demo/ksa-8-image_add.png) | ![KSA 8 brightness](../image_processing/demo/ksa-8-brightness.png) |
| Carry-select | ![KSA csa gaussian](../image_processing/demo/ksa-csa-gaussian.png) | ![KSA csa mean](../image_processing/demo/ksa-csa-mean.png) | ![KSA csa sobel_x](../image_processing/demo/ksa-csa-sobel_x.png) | ![KSA csa image_add](../image_processing/demo/ksa-csa-image_add.png) | ![KSA csa brightness](../image_processing/demo/ksa-csa-brightness.png) |

## Brent–Kung

| Design | Gaussian | Mean | Sobel X | Addition | Brightness |
|---|---|---|---|---|---|
| Exact | ![BKA exact gaussian](../image_processing/demo/bka-exact-gaussian.png) | ![BKA exact mean](../image_processing/demo/bka-exact-mean.png) | ![BKA exact sobel_x](../image_processing/demo/bka-exact-sobel_x.png) | ![BKA exact image_add](../image_processing/demo/bka-exact-image_add.png) | ![BKA exact brightness](../image_processing/demo/bka-exact-brightness.png) |
| 2-bit | ![BKA 2 gaussian](../image_processing/demo/bka-2-gaussian.png) | ![BKA 2 mean](../image_processing/demo/bka-2-mean.png) | ![BKA 2 sobel_x](../image_processing/demo/bka-2-sobel_x.png) | ![BKA 2 image_add](../image_processing/demo/bka-2-image_add.png) | ![BKA 2 brightness](../image_processing/demo/bka-2-brightness.png) |
| 4-bit | ![BKA 4 gaussian](../image_processing/demo/bka-4-gaussian.png) | ![BKA 4 mean](../image_processing/demo/bka-4-mean.png) | ![BKA 4 sobel_x](../image_processing/demo/bka-4-sobel_x.png) | ![BKA 4 image_add](../image_processing/demo/bka-4-image_add.png) | ![BKA 4 brightness](../image_processing/demo/bka-4-brightness.png) |
| 8-bit | ![BKA 8 gaussian](../image_processing/demo/bka-8-gaussian.png) | ![BKA 8 mean](../image_processing/demo/bka-8-mean.png) | ![BKA 8 sobel_x](../image_processing/demo/bka-8-sobel_x.png) | ![BKA 8 image_add](../image_processing/demo/bka-8-image_add.png) | ![BKA 8 brightness](../image_processing/demo/bka-8-brightness.png) |
| Carry-select | ![BKA csa gaussian](../image_processing/demo/bka-csa-gaussian.png) | ![BKA csa mean](../image_processing/demo/bka-csa-mean.png) | ![BKA csa sobel_x](../image_processing/demo/bka-csa-sobel_x.png) | ![BKA csa image_add](../image_processing/demo/bka-csa-image_add.png) | ![BKA csa brightness](../image_processing/demo/bka-csa-brightness.png) |

