clc;
clear;
close all;

%% -------------------------------------------------
% Step 1: Read image
%% -------------------------------------------------
img = imread('lenna.png');

if size(img,3)==3
    img = rgb2gray(img);
end

img = uint8(img);
[rows, cols] = size(img);

figure; imshow(img); title('Original Image');

%% -------------------------------------------------
% Step 2: Sobel kernel (Horizontal)
%% -------------------------------------------------
kernel = [-1  0  1;
          -2  0  2;
          -1  0  1];

%% -------------------------------------------------
% Step 3: EXACT LF Sobel Filter
%% -------------------------------------------------
exact_out = zeros(rows, cols);

for i=2:rows-1
    for j=2:cols-1
        block = double(img(i-1:i+1,j-1:j+1));
        exact_val = sum(sum(block .* kernel));
        exact_out(i,j) = abs(exact_val);
    end
end

exact_out = uint8(min(exact_out,255));

%% -------------------------------------------------
% Step 4: APPROX LF Sobel Filter (Carry Spec)
%% -------------------------------------------------
approx_out = zeros(rows, cols);

for i=2:rows-1
    for j=2:cols-1
        block = double(img(i-1:i+1,j-1:j+1)) .* kernel;

        acc = uint16(0);
        for k=1:numel(block)
            acc = approx_LF_carry_spec(acc, uint16(abs(block(k))));
        end

        approx_out(i,j) = acc;
    end
end

approx_out = uint8(min(approx_out,255));

%% -------------------------------------------------
% Step 5: Comparison
%% -------------------------------------------------
figure;
subplot(1,3,1); imshow(img);       title('Original');
subplot(1,3,2); imshow(exact_out); title('Exact LF Sobel');
subplot(1,3,3); imshow(approx_out);title('Approx LF Sobel (Carry Spec)');

%% -------------------------------------------------
% Step 6: Error Metrics
%% -------------------------------------------------
error = double(exact_out) - double(approx_out);

MAE  = mean(abs(error(:)));
MSE  = mean(error(:).^2);
PSNR = 10*log10(255^2/MSE);
SSIM_val = ssim(approx_out, exact_out);

disp('--- Sobel Filter (Carry Spec) ---');
disp(['MAE  = ', num2str(MAE)]);
disp(['MSE  = ', num2str(MSE)]);
disp(['PSNR = ', num2str(PSNR), ' dB']);
disp(['SSIM = ', num2str(SSIM_val)]);

%% -------------------------------------------------
% Carry Speculative Approximate Adder
%% -------------------------------------------------
function approx_sum = approx_LF_carry_spec(A,B)
    A = uint16(A);
    B = uint16(B);

    exact_sum = A + B;

    true_c8 = bitget(exact_sum,9);
    pred_c8 = bitand(bitget(A,8),bitget(B,8));

    approx_sum = exact_sum;
    err = (true_c8 ~= pred_c8);

    approx_sum(err) = approx_sum(err) + ...
        uint16(256*(pred_c8(err)-true_c8(err)));
end
