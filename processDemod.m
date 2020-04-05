
%Non-working samnple. Captured at 30m
file = 'guardline/rtlfm_april4_1_longdistance_trimmed.out';
lpfCutoff = 0;

%Working sample. Captured at 2m
% file = 'guardline/rtlfm_mar25_2_replacebatt.out';
% lpfCutoff = (0.5*10^4)

plotAnalysis = true;
plotAnalysisBits = true;
makeBytes = false;
makeBinVec = true;

sampleRate = 250000; %Samples per second
pulseWidth = 65; %Samples


fid = fopen(file, 'r');
fseek(fid, 0,'bof');
data = fread(fid,inf,'*int16');
fclose(fid);
originalData = double(data);
lpf = originalData;

% lpf = filter(custfilt,lpf);
[lpf,filtobj] = lowpass(lpf,9000,sampleRate); %Works close range


%Nonsense I have been trying.
% [lpf,filtobj] = lowpass(lpf,sampleRate/65,sampleRate);
% [lpf,filtobj] = bandstop(lpf,[100 500],sampleRate); 
% lpf = movmean(lpf,12);
% [lpf,filtobj] = lowpass(lpf,9000,250000);
% lpf = abs(diff(lpf));

binary = lpf>lpfCutoff;

if plotAnalysis
%%
    figure;
    subplot(3,1,1);
    plot(originalData);
    title('Raw Demod');
    ax1 = gca;
    subplot(3,1,2);
    plot(lpf);
    title('Filtered');
    ax2 = gca;
    subplot(3,1,3);
    plot(binary);
    title('Threshold');
    ylim([-.2 1.2]);
    ax3 = gca;

    linkaxes([ax1 ax2 ax3],'x');
%      xlim(goodLim);
    %%
%     d = diff(binary);
%     % d = diff(binary) ~= 0;
%     idx = find(d);
%     pulseWidth = diff(idx);
%     figure;
%     plot(pulseWidth);
end

%%
clc
words = [];
word = [];
stateLast = false;
stateLength = 0;
for i = 1:length(binary)
    value = binary(i);
    if value == stateLast
        stateLength = stateLength + 1;
    end
    if value ~= stateLast
%         if stateLength > 40
            counts = round(stateLength / pulseWidth);
            if stateLength < 600
%                 display(counts);
                for j = 1:counts
                    word = logical([word stateLast]);
                end
            else
                wordlen = length(word);
                if wordlen >= 74
                    words = [words word(end-73:end)'];
                else
                    display(['Dropping word of ' num2str(wordlen)]);
                end
                word = [];
            end
%         end
        
        stateLength = 0;
        stateLast = value;
    end
end

words = (words');
% words = unique(words,'rows');
words = words(1:end-1,:); %Drop the all 1s row
%%
if makeBytes
    bytes = [];
    si = size(words);
    for i = 1:si(1)
        word = words(i,:);
        wordLen = length(word);
        wordBytes = [];
        for j = [1:8:length(word)]
            bitStart = j;
            bitEnd = j+7;
            if bitEnd > wordLen
                bitEnd = wordLen;
            end
            bits = words(i,bitStart:bitEnd);
            byte = bin2dec(num2str(bits));
            wordBytes = [wordBytes dec2hex(byte)];
        end
        bytes = [bytes; wordBytes];
    end
end
%%
if makeBinVec
    
    binVec = [];
    si = size(words);
    for i = 1:si(1)
        word = words(i,:);
        printedWord = (sprintf('%d', word));
        binVec = [ binVec; printedWord]; 
    end
%     binVec = unique(binVec,'rows');
end


%%
if plotAnalysisBits
    figure;
    si = size(words);
    for i = 1:si(1)
        stairs(words(i,:)+i+(i*.1));
        hold on;
    end
%     ylim([-1 2]);
end
%%
s = size(words);
disp(['Recovered ' num2str(s(1)) ' words.']);
