
clear all;
fid = fopen('guardline/rtlfm_mar25_1.out', 'r');
data = fread(fid,inf,'*int16');
fclose(fid);
fid = fopen('decode_filt.out', 'r');
dataC = fread(fid,inf,'*double');
fclose(fid);
fid = fopen('decode_bits.out', 'r');
bitsC = fread(fid,inf,'*uint8');
fclose(fid);

% dataOriginal = double(data);
[dataOriginal,filtobj] = lowpass(double(data),9000,250000);
binary = dataOriginal>(0.5*10^4);

%%
%Trim samples by group delay
groupdelay = 26;
dataC = dataC(groupdelay:end-1);
dataOriginal = dataOriginal(1:end-groupdelay);

bitsC = bitsC(groupdelay:end-1);
binary = binary(1:end-groupdelay);

%%
demodDiff = dataOriginal - dataC;

figure;
subplot(3,1,1);
plot(dataOriginal);
ax1 = gca;
title('Filter Reference');

subplot(3,1,2);
plot(dataC);
ax2 = gca;
title('Filter C Implementation');
subplot(3,1,3);
plot(demodDiff);
ax3 = gca;
title('Filter Difference');
linkaxes([ax1 ax2 ax3]);

%%


figure;
subplot(3,1,1);
plot(binary);
ax1 = gca;
title('Binary Reference');

subplot(3,1,2);
plot(bitsC);
ax2 = gca;
title('Binary C Implementation');
subplot(3,1,3);
plot(binary ~= bitsC);
ax3 = gca;
title('Binary Difference');
linkaxes([ax1 ax2 ax3]);
ylim([-.5,1.5]);