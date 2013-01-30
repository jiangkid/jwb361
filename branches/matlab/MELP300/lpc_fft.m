close all;
clear all;
load('org_data.mat');%signal_org, lpc_org, G_org
load('data.mat');%signalDec, lpcDec, G
% s = wavread('part2.wav')';
% s = s*32767;
%FRN = 14;
%sigOffset = 1;
%signal_org = s((FRN-2)*180+sigOffset : (FRN-2)*180+sigOffset+179);

%%
f = 0:4000/256:4000;%0~fs/2

%ԭʼ�źŵĹ�����
fftOrg = fft(signal_org, 512);
fftOrgDB = mag2db(abs(fftOrg(1:256))/512);

%����ԭʼ�źŵ�LPC��
[outlineOrg, ff_org] = freqz(db2mag(G_org), [1, lpc_org], 256);
ff_org = 4000*ff_org/pi;
outlineOrgDB = mag2db(abs(outlineOrg));

%�ϳ��źŵĹ�����
fftDec = fft(signalDec, 512);
fftDecDB = mag2db(abs(fftDec(1:256))/512);

%����ϳ��źŵ�LPC��
lpc_temp = lpc(signalDec, 10);
[outlineDecS, fff] = freqz(db2mag(G), lpc_temp, 256);
fff = 4000*fff/pi;
outlineDecSDB = mag2db(abs(outlineDecS));

%���㴫���LPCϵ������
[outlineDec, ff] = freqz(db2mag(G), [1, lpcDec], 256);
ff = 4000*ff/pi;
outlineDecDB = mag2db(abs(outlineDec));

figure(2);
plot(fftOrgDB, 'r');
hold on;
plot(outlineOrgDB, 'r');
plot(fftDecDB);
plot(outlineDecDB);
plot(outlineDecSDB, 'g');
hold off;
grid on;

%%
%һ�׵���
figure(3);
plot(fftDecDB);
grid on;

[pks, locs]=findpeaks(outlineDecDB);%Ѱ�Ҿֲ����ֵ
peaksAreaDec = findPeaksArea(outlineDecDB);

[pksS, locsS]=findpeaks(outlineDecSDB);%Ѱ�Ҿֲ����ֵ
peaksAreaDecS = findPeaksArea(outlineDecSDB);

hold on;
plot(outlineDecDB);
plot(locs,pks,'*r');%�ֲ����ֵ
plot(peaksAreaDec(:,1),outlineDecDB(peaksAreaDec(:,1)),'*g');%��ֵ
plot(peaksAreaDec(:,2),outlineDecDB(peaksAreaDec(:,2)),'*g');%��ֵ

plot(outlineDecSDB,'c');
plot(locsS,pksS,'*r');%�ֲ����ֵ
plot(peaksAreaDecS(:,1),outlineDecSDB(peaksAreaDecS(:,1)),'*g');%��ֵ
plot(peaksAreaDecS(:,2),outlineDecSDB(peaksAreaDecS(:,2)),'*g');%��ֵ
hold off;

%����ϲ� peaksAreaDec peaksAreaDecS --> (C)
areaC = areaCombine(peaksAreaDec, peaksAreaDecS);

%%
k = ones(256,1);%Ƶ���˲�ϵ��
kk = db2mag(outlineDecDB)./db2mag(outlineDecSDB);
for i = 1:size(areaC, 1);
    k(areaC(i,1):areaC(i,2)) = kk(areaC(i,1):areaC(i,2));
end
figure(5);
plot(k);
sigOut = freq_filter(signalDec',k);%Ƶ���˲�
figure(1);%ʱ����
plot(signal_org, 'r');grid on;
hold on;plot(signalDec);hold off;
hold on;plot(sigOut, 'g');hold off;
title('ʱ��');

figure(4);%Ƶ��
fftOrgAbs = abs(fftOrg(1:256));
fftDecAbs = abs(fftDec(1:256));
fftDecOut = fftDecAbs'.*k;
plot(fftOrgAbs, 'r');grid on;
hold on;plot(fftDecAbs);hold off;
hold on;plot(fftDecOut, 'g');hold off;
title('Ƶ��');

% dataTemp = outlineDecDB/sum(outlineDecDB);
% dataTemp = dataTemp.*smoothData;
% k = max(smoothData)/max(dataTemp);
% dataTemp = k*dataTemp;
% figure(5);
% plot(dataTemp);
% hold on;
% plot(smoothData, 'r');
% hold off;
