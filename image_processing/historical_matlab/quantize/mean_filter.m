clc;
clear;
close all;

%% -------------------------------------------------
% Step 1: Read standard benchmark image
%% -------------------------------------------------
img = imread('lenna.png');
imshow(img);


if size(img,3) == 3
    img = rgb2gray(img);
end

img = uint8(img);

figure;
imshow(img);
title('Original Image');

%% -------------------------------------------------
% Step 2: Define 3x3 mean filter
%% -------------------------------------------------
kernel = ones(3,3);   % Mean filter (no division yet)

[rows, cols] = size(img);

%% -------------------------------------------------
% Step 3: EXACT LF MEAN FILTER (REFERENCE)
%% -------------------------------------------------
exact_out = zeros(rows, cols);

for i = 2:rows-1
    for j = 2:cols-1
        block = uint16(img(i-1:i+1, j-1:j+1));
        exact_sum = sum(block(:));          % Exact LF behavior
        exact_out(i,j) = exact_sum / 9;
    end
end

exact_out = uint8(exact_out);

figure;
imshow(exact_out);
title('Exact LF Mean Filter Output');

%% -------------------------------------------------
% Step 4: APPROXIMATE LF MEAN FILTER (2-bit LSB)
%% -------------------------------------------------
k = 8;   % 2-bit approximation

approx_out = zeros(rows, cols);

for i = 2:rows-1
    for j = 2:cols-1
        block = uint16(img(i-1:i+1, j-1:j+1));
        exact_sum = sum(block(:));
        
        % Approximate LF modeling
        approx_sum = floor(double(exact_sum)/(2^k)) *(2^k);
        
        approx_out(i,j) = approx_sum / 9;
    end
end

approx_out = uint8(approx_out);

figure;
imshow(approx_out);
title('Approximate LF Mean Filter Output (2 LSBs)');

%% -------------------------------------------------
% Step 5: Comparison Figure (FINAL FIGURE)
%% -------------------------------------------------
figure;
subplot(1,3,1);
imshow(img);
title('Original Image');

subplot(1,3,2);
imshow(exact_out);
title('Exact LF Mean Filter');

subplot(1,3,3);
imshow(approx_out);
title('Approximate LF Mean Filter');

%% -------------------------------------------------
% Step 6: Error Metrics (PHASE 2)
%% -------------------------------------------------
error = double(exact_out) - double(approx_out);

MAE  = mean(abs(error(:)));
MSE  = mean(error(:).^2);
PSNR = 10*log10(255^2/MSE);
SSIM_val = ssim(approx_out, exact_out);

disp(['MAE  = ', num2str(MAE)]);
disp(['MSE  = ', num2str(MSE)]);
disp(['PSNR = ', num2str(PSNR), ' dB']);
disp(['SSIM = ', num2str(SSIM_val)]);

