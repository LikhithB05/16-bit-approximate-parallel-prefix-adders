clc;
clear;
close all;

%% Step 1: Read standard benchmark images
img1 = imread('pout.tif');   % Benchmark image 1
img2 = imread('rice.png');        % Benchmark image 2

%% Step 2: Convert to grayscale if needed
if size(img1,3) == 3
    img1 = rgb2gray(img1);
end
if size(img2,3) == 3
    img2 = rgb2gray(img2);
end

%% Step 3: Resize to same size
img2 = imresize(img2, size(img1));

img1 = uint8(img1);
img2 = uint8(img2);

%% Step 4: Display input images
figure;
subplot(1,2,1);
imshow(img1);
title('Input Image 1 (Cameraman)');

subplot(1,2,2);
imshow(img2);
title('Input Image 2 (Rice Texture)');

%% Step 5: Exact LF Adder (Reference)
exact_sum = uint16(img1) + uint16(img2);
exact_sum = uint8(min(exact_sum,255));

figure;
imshow(exact_sum);
title('Exact LF Adder Output');

%% Step 6: Approximate LF Adder (2-bit)
k = 8;
temp_sum = uint16(img1) + uint16(img2);
approx_sum = floor(double(temp_sum)/(2^k))*(2^k);
approx_sum = uint8(min(approx_sum,255));

figure;
imshow(approx_sum);
title('Approximate LF Output (2 LSBs)');

%% Step 7: Comparison
figure;

subplot(2,2,1);
imshow(img1);
title('Input Image 1');

subplot(2,2,2);
imshow(img2);
title('Input Image 2');

subplot(2,2,3);
imshow(exact_sum);
title('Exact LF Output');

subplot(2,2,4);
imshow(approx_sum);
title('Approximate LF Output (2 LSBs)');


%% Step 8: Error metric
%% Step 8: Error Metrics (Addition)

error = double(exact_sum) - double(approx_sum);

MAE  = mean(abs(error(:)));
MSE  = mean(error(:).^2);
PSNR = 10*log10(255^2 / MSE);
SSIM_val = ssim(approx_sum, exact_sum);


disp('--- Image Addition Error Metrics ---');
disp(['MAE  = ', num2str(MAE)]);
disp(['MSE  = ', num2str(MSE)]);
disp(['PSNR = ', num2str(PSNR), ' dB']);
disp(['SSIM = ', num2str(SSIM_val)]);


