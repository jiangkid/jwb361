function [ output ] = lpcEnhance( input, lpcOrg, G)
%enhance speech by lpc argument
%1. 计算input的lpc系数lpcInput
lpcInput = lpc(input, 10);

%2. 计算lpcOrg、lpcInput的谱包络
if size(lpcOrg,2) == 10
    lpcOrg = [1 lpcOrg];
end
[outlineOrg, temp] = freqz(db2mag(G), lpcOrg, 256);
outlineOrgDB = mag2db(abs(outlineOrg));
[outlineInput, temp] = freqz(db2mag(G), lpcInput, 256);
outlineInputDB = mag2db(abs(outlineInput));

%3. 计算谱包络的波峰区域
peaksAreaOrg = findPeaksArea(outlineOrgDB);
peaksAreaInput = findPeaksArea(outlineInputDB);
areaC = areaCombine(peaksAreaOrg, peaksAreaInput);%区域合并
%4. 计算lpcOrg与lpcInput之间的差
kk = db2mag(outlineOrgDB)./db2mag(outlineInputDB);

%5. 计算滤波器系数
k = ones(256,1);
for i = 1:size(areaC, 1);
    kkData = kk(areaC(i,1):areaC(i,2));
    if max(kkData) > 2 %归一化1~2
        kkDataTemp = kkData-1;        
        k(areaC(i,1):areaC(i,2)) = kkDataTemp*(1/max(kkDataTemp)) + 1;
    elseif min(kkData) < 0.5 %归一化0.5~1
        kkDataTemp = 1-kkData; 
        k(areaC(i,1):areaC(i,2)) = 1 - kkDataTemp/(max(kkDataTemp)/0.5);
    else
        k(areaC(i,1):areaC(i,2)) = kkData;
    end
end

%6.频域滤波
output = freq_filter(input',k);

% 画图
fftInput = fft(input, 512);
fftInputDB = mag2db(abs(fftInput(1:256))/512);
fftOutput = fft(output, 512);
fftOutputDB = mag2db(abs(fftOutput(1:256))/512);

f = (1:256);
figure(1);
subplot(211);
plot(f, outlineOrgDB, 'r')
hold on;
plot(f, outlineInputDB);
plot(f, fftInputDB);
plot(f, fftOutputDB,'g');
hold off;grid on;
subplot(212);
plot(f, k);
grid on;
global count;
pngName = sprintf('lpcEnhance%d.png',count);
print(gcf,'-dpng', pngName);
end
