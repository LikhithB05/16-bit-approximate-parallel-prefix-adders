clc;
clear;
close all;

%% -------------------------------------------------
% Step 1: Read Image
%% -------------------------------------------------
img = imread('pout.tif');   % make sure this image is in the same folder

if size(img,3) == 3
    img = rgb2gray(img);
end

img = uint8(img);

figure;
imshow(img);
title('Original Image');

%% -------------------------------------------------
% Step 2: Brightness Increment
%% -------------------------------------------------
brightness_value = 40;   % increase brightness by this amount

%% -------------------------------------------------
% Step 3: Exact LF Brightness Increase
%% -------------------------------------------------
exact_out = uint16(img) + uint16(brightness_value);
exact_out = uint8(min(exact_out,255));

%% -------------------------------------------------
% Step 4: Approximate LF Brightness Increase
% (Carry Speculative LF Adder)
%% -------------------------------------------------
approx_out = approx_LF_carry_spec(uint16(img), uint16(brightness_value));
approx_out = uint8(min(approx_out,255));

%% -------------------------------------------------
% Step 5: Comparison
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
title('Approx LF Brightness (Carry Spec)');

%% -------------------------------------------------
% Step 6: Error Metrics
%% -------------------------------------------------
error = double(exact_out) - double(approx_out);

MAE  = mean(abs(error(:)));
MSE  = mean(error(:).^2);
PSNR = 10*log10(255^2 / MSE);
SSIM_val = ssim(approx_out, exact_out);

disp('--- Brightness Increase (Carry Speculative LF) ---');
disp(['MAE  = ', num2str(MAE)]);
disp(['MSE  = ', num2str(MSE)]);
disp(['PSNR = ', num2str(PSNR), ' dB']);
disp(['SSIM = ', num2str(SSIM_val)]);

%% =================================================
% LOCAL FUNCTION (MUST BE AT THE END OF THE FILE)
%% =================================================
function approx_sum = approx_LF_carry_spec(A, B)
    % Ensure uint16
    A = uint16(A);
    B = uint16(B);

    % Exact sum
    exact_sum = A + B;

    % True carry into bit-8 (MATLAB is 1-indexed)
    true_c8 = bitget(exact_sum, 9);

    % Predicted carry (generate-only approximation)
    pred_c8 = bitand(bitget(A,8), bitget(B,8));

    % Start with exact sum
    approx_sum = exact_sum;

    % Detect carry misprediction
    error_idx = (true_c8 ~= pred_c8);

    % Inject ±256 error (2^8)
    approx_sum(error_idx) = approx_sum(error_idx) + ...
        uint16(256 .* (pred_c8(error_idx) - true_c8(error_idx)));
end
