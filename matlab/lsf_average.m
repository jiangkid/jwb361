clear all;
clc;
[inSpeech, fs, bits] = wavread('chineseNews_2012-11-19.wav');
inSpeech = inSpeech*32767;
%inSpeech = filter([1 -0.9375], 1, inSpeech);
frameLen = 180;
frameNum = length(inSpeech)/frameLen;
lsf_sum(1:10) = 0;
lsf_all = [];
frameCount = 0;
for frameIdx = 1:frameNum
    frameData = inSpeech(frameLen*(frameIdx-1)+1 : frameLen*frameIdx);
    if sum(frameData) == 0
        continue;
    end
    [a, g] = lpc(frameData, 10);
    lsf = poly2lsf(a);
    lsf_all = [lsf_all, lsf];
end;
lsf_mean = mean(lsf_all');
%统计分布图
bin = 500;
n = zeros(10,bin);
xout = zeros(10,bin);
for i=1:10
	[n(i,:),xout(i,:)] = hist(lsf_all(i,:),bin);
	plot(xout(i,:),n(i,:));
	hold on;
end

%lsf_average = lsf_sum./frameCount;
%plot(lsf_average,'-*');
%对75398帧的统计平均结果
%lsf_average: [0.1897    0.3640    0.6313    0.9681    1.2868    1.6050
%1.9230    2.2065    2.5305    2.8074]
