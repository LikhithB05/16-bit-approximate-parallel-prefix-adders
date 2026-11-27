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
% Step 2: Define Sobel kernel (Horizontal)
%% -------------------------------------------------
kernel = [-1  0  1;
          -2  0  2;
          -1  0  1];

%% -------------------------------------------------
% Step 3: EXACT LF SOBEL FILTER
%% -------------------------------------------------
exact_out = zeros(rows, cols);

for i = 2:rows-1
    for j = 2:cols-1
        block = double(img(i-1:i+1, j-1:j+1));
        exact_val = sum(sum(block .* kernel));
        exact_out(i,j) = abs(exact_val);
    end
end

exact_out = uint8(min(exact_out,255));

%% -------------------------------------------------
% Step 4: APPROXIMATE LF SOBEL FILTER (2-bit LSB)
%% -------------------------------------------------
k = 8;
approx_out = zeros(rows, cols);

for i = 2:rows-1
    for j = 2:cols-1
        block = double(img(i-1:i+1, j-1:j+1));
        exact_val = sum(sum(block .* kernel));

        approx_val = floor(abs(exact_val)/(2^k)) * (2^k);
        approx_out(i,j) = approx_val;
    end
end

approx_out = uint8(min(approx_out,255));

%% -------------------------------------------------
% Step 5: Comparison Figure
%% -------------------------------------------------
figure;
subplot(1,3,1); imshow(img);       title('Original Image');
subplot(1,3,2); imshow(exact_out); title('Exact LF Sobel');
subplot(1,3,3); imshow(approx_out);title('Approx LF Sobel');

%% -------------------------------------------------
% Step 6: Error Metrics
%% -------------------------------------------------
error = double(exact_out) - double(approx_out);

MAE  = mean(abs(error(:)));
MSE  = mean(error(:).^2);
PSNR = 10*log10(255^2/MSE);
SSIM_val = ssim(approx_out, exact_out);

disp('--- Sobel Filter Error Metrics ---');
disp(['MAE  = ', num2str(MAE)]);
disp(['MSE  = ', num2str(MSE)]);
disp(['PSNR = ', num2str(PSNR), ' dB']);
disp(['SSIM = ', num2str(SSIM_val)]);
