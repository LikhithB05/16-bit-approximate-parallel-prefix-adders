clc;
clear;
close all;

%% =================================================
% Step 1: Read standard benchmark images
%% =================================================
img1 = imread('pout.tif');
img2 = imread('rice.png');

if size(img1,3)==3, img1 = rgb2gray(img1); end
if size(img2,3)==3, img2 = rgb2gray(img2); end

img2 = imresize(img2, size(img1));

img1 = uint8(img1);
img2 = uint8(img2);

%% =================================================
% Step 2: Display input images
%% =================================================
figure;
subplot(1,2,1); imshow(img1); title('Input Image 1');
subplot(1,2,2); imshow(img2); title('Input Image 2');

%% =================================================
% Step 3: Exact LF Adder (Reference)
%% =================================================
exact_sum = uint16(img1) + uint16(img2);
exact_sum = uint8(min(exact_sum,255));

figure;
imshow(exact_sum);
title('Exact LF Adder Output');

%% =================================================
% Step 4: Approximate LF Adder (Carry Speculation)
%% =================================================
approx_sum = approx_LF_carry_spec(uint16(img1), uint16(img2));
approx_sum = uint8(min(approx_sum,255));

figure;
imshow(approx_sum);
title('Approximate LF Output (Carry Spec)');

%% =================================================
% Step 5: Comparison
%% =================================================
figure;
subplot(2,2,1); imshow(img1); title('Input Image 1');
subplot(2,2,2); imshow(img2); title('Input Image 2');
subplot(2,2,3); imshow(exact_sum); title('Exact LF Output');
subplot(2,2,4); imshow(approx_sum); title('Approx LF Output');

%% =================================================
% Step 6: Error Metrics
%% =================================================
error = double(exact_sum) - double(approx_sum);

MAE  = mean(abs(error(:)));
MSE  = mean(error(:).^2);
PSNR = 10*log10(255^2/MSE);
SSIM_val = ssim(approx_sum, exact_sum);

disp('--- Image Addition (Carry Spec) ---');
disp(['MAE  = ', num2str(MAE)]);
disp(['MSE  = ', num2str(MSE)]);
disp(['PSNR = ', num2str(PSNR), ' dB']);
disp(['SSIM = ', num2str(SSIM_val)]);

%% =================================================
% Carry-Speculative Approximate Adder (LOCAL FUNCTION)
%% =================================================
function approx_sum = approx_LF_carry_spec(A,B)
    A = uint16(A);
    B = uint16(B);

    exact_sum = A + B;

    true_c8 = bitget(exact_sum,9);          % true carry
    pred_c8 = bitand(bitget(A,8),bitget(B,8)); % predicted carry

    approx_sum = exact_sum;
    err = (true_c8 ~= pred_c8);

    approx_sum(err) = approx_sum(err) + ...
        uint16(256*(pred_c8(err)-true_c8(err)));
end
