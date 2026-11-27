clc;
clear;
close all;

%% -------------------------------------------------
% Step 1: Read image
%% -------------------------------------------------
img = imread('lenna.png');

if size(img,3) == 3
    img = rgb2gray(img);
end

img = uint8(img);

figure;
imshow(img);
title('Original Image');

[rows, cols] = size(img);

%% -------------------------------------------------
% Step 2: Define 3x3 Gaussian kernel
%% -------------------------------------------------
kernel = [1 2 1;
          2 4 2;
          1 2 1];
kernel_sum = 16;

%% -------------------------------------------------
% Step 3: EXACT LF GAUSSIAN FILTER
%% -------------------------------------------------
exact_out = zeros(rows, cols);

for i = 2:rows-1
    for j = 2:cols-1
        block = img(i-1:i+1, j-1:j+1);
        exact_sum = sum(sum(double(block) .* kernel));
        exact_out(i,j) = exact_sum / kernel_sum;
    end
end

exact_out = uint8(exact_out);

%% -------------------------------------------------
% Step 4: APPROXIMATE LF GAUSSIAN FILTER (2-bit LSB)
%% -------------------------------------------------
k = 8;   % number of approximated LSBs
approx_out = zeros(rows, cols);

for i = 2:rows-1
    for j = 2:cols-1
        block = img(i-1:i+1, j-1:j+1);
        exact_sum = sum(sum(double(block) .* kernel));

        approx_sum = floor(exact_sum / (2^k)) * (2^k);
        approx_out(i,j) = approx_sum / kernel_sum;
    end
end

approx_out = uint8(approx_out);

%% -------------------------------------------------
% Step 5: Comparison Figure
%% -------------------------------------------------
figure;
subplot(1,3,1); imshow(img);       title('Original Image');
subplot(1,3,2); imshow(exact_out); title('Exact LF Gaussian');
subplot(1,3,3); imshow(approx_out);title('Approx LF Gaussian');

%% -------------------------------------------------
% Step 6: Error Metrics
%% -------------------------------------------------
error = double(exact_out) - double(approx_out);

MAE  = mean(abs(error(:)));
MSE  = mean(error(:).^2);
PSNR = 10*log10(255^2/MSE);
SSIM_val = ssim(approx_out, exact_out);

disp('--- Gaussian Filter Error Metrics ---');
disp(['MAE  = ', num2str(MAE)]);
disp(['MSE  = ', num2str(MSE)]);
disp(['PSNR = ', num2str(PSNR), ' dB']);
disp(['SSIM = ', num2str(SSIM_val)]);

