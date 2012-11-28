clear all;
clc;
load('lsf_all.mat');
[row, column] = size(lsf_all);%75398֡

trueIdx = [1,2,3,4,5,6,7,10];
interpIdx = [8,9];

absErr1 = 0; 
absErr2 = 0;
absErr3 = 0;
relateErr1 = 0;
relateErr2 = 0;
relateErr3 = 0;
SD(1, column) = 0;
for frameIdx = 1:column
    lsf_data = lsf_all(:,frameIdx)';
    
    if 0 %���´��벻ִ��
    y1 = interp1(trueIdx, lsf_data(trueIdx), interpIdx); %���Բ�ֵ
    absErr1 = absErr1 + abs(y1 - lsf_data(interpIdx));
    relateErr1 = relateErr1 + abs((y1 - lsf_data(interpIdx))./lsf_data(interpIdx));
    y2 = interp1(trueIdx, lsf_data(trueIdx), interpIdx, 'cubic'); %���η���ʽ��ֵ        
    absErr2 = absErr2 + abs(y2 - lsf_data(interpIdx));
    relateErr2 = relateErr2 + abs((y2 - lsf_data(interpIdx))./lsf_data(interpIdx));

    y3 = interp1(trueIdx, lsf_data(trueIdx), interpIdx, 'spline'); %������ֵ
    absErr3 = absErr3 + abs(y3 - lsf_data(interpIdx));
    relateErr3 = relateErr3 + abs((y3 - lsf_data(interpIdx))./lsf_data(interpIdx));
    end
    
    y = interp1(trueIdx, lsf_data(trueIdx), interpIdx); %���Բ�ֵ
    interpLSF = lsf_data;
    interpLSF(interpIdx) = y;
    SD(frameIdx) = spectral_distortion(lsf_data, interpLSF);
end
%absErrAll = [sum(absErr1), sum(absErr2), sum(absErr3)];
%relateErrAll  = [sum(relateErr1), sum(relateErr2), sum(relateErr3)];
%���ۣ����LSFϵ��֡�ڲ�ֵ,���Բ�ֵ��������С
%���: mean(SD): 1.3644 DB