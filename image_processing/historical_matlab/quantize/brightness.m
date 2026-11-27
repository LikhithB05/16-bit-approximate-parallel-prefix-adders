clc;
clear;
close all;

%% -------------------------------------------------
% Step 1: Read standard benchmark image
%% -------------------------------------------------
img = imread('pout.tif');   % You can also use cameraman.tif

if size(img,3) == 3
    img = rgb2gray(img);
end

img = uint8(img);

figure;
imshow(img);
title('Original Image');

%% -------------------------------------------------
% Step 2: Define brightness increment
%% -------------------------------------------------
brightness_value = 40;   % Increase brightness by this amount

%% -------------------------------------------------
% Step 3: Exact LF Brightness Increase (Reference)
%% -------------------------------------------------
exact_out = uint16(img) + uint16(brightness_value);
exact_out = uint8(min(exact_out,255));   % Saturation

figure;
imshow(exact_out);
title('Exact LF Brightness Increased Image');

%% -------------------------------------------------
% Step 4: Approximate LF Brightness Increase (2-bit LSB)
%% -------------------------------------------------
k = 2;   % 2-bit approximation

temp_sum = uint16(img) + uint16(brightness_value);
approx_out = floor(double(temp_sum)/(2^k))*(2^k);
approx_out = uint8(min(approx_out,255));

figure;
imshow(approx_out);
title('Approximate LF Brightness Increase (2 LSBs)');

%% -------------------------------------------------
% Step 5: Comparison Figure
%% -------------------------------------------------
figure;

subplot(1,3,1);
imshow(img);
title('Original Image');

subplot(1,3,2);
imshow(exact_out);
title('Exact LF Brightness');

subplot(1,3,3);
imshow(approx_out);
title('Approximate LF Brightness');

%% -------------------------------------------------
% Step 6: Error Metrics
%% -------------------------------------------------
error = double(exact_out) - double(approx_out);

MAE  = mean(abs(error(:)));
MSE  = mean(error(:).^2);
PSNR = 10*log10(255^2 / MSE);
SSIM_val = ssim(approx_out, exact_out);

disp('--- Brightness Increase Error Metrics ---');
disp(['MAE  = ', num2str(MAE)]);
disp(['MSE  = ', num2str(MSE)]);
disp(['PSNR = ', num2str(PSNR), ' dB']);
disp(['SSIM = ', num2str(SSIM_val)]);
