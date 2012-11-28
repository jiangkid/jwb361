clear all;
clc;
load('lsf_all.mat');
[row, column] = size(lsf_all);%75398֡
superFrameLen = 6;
superFrameNum = fix(column/superFrameLen); %����֡��
trueIdx = [1,2,4,6];
interpIdx = [3, 5];%��ֵ֡
superFrameLSF(row, superFrameLen) = 0;
SD1(superFrameNum, 1) = 0;
SD2(superFrameNum, 1) = 0;
for frameIdx = 1:superFrameNum
    superFrameLSF = lsf_all( : , superFrameLen*(frameIdx-1)+1 : superFrameLen*frameIdx );
    interpLSF(10, 2) = 0;
    for rowIdx = 1 : row
        rowData = superFrameLSF(rowIdx, : );
        y = interp1(trueIdx, rowData(trueIdx), interpIdx); %���Բ�ֵ
        if(isnan(y))
            y = interp1(trueIdx, rowData(trueIdx), interpIdx, 'cubic'); %���Բ�ֵ
        end
        interpLSF(rowIdx, : ) = y;
    end
    %������ʧ��
    SD1(frameIdx) = spectral_distortion(superFrameLSF(:,3), interpLSF(:,1));
    SD2(frameIdx) = spectral_distortion(superFrameLSF(:,5), interpLSF(:,2));  
end

%2��3֡��ֵ����ʧ�棺��2֡ 3.0710����5֡ 3.0482
%3��4֡��ֵ����ʧ�棺��3֡ 3.0551����4֡ 3.0433
%2��5֡��ֵ����ʧ�棺��2֡ 2.5281����5֡ 2.4942
%3��5֡��ֵ����ʧ�棺��3֡ 2.5191����5֡ 2.4942/////
%4��5֡��ֵ����ʧ�棺��4֡ 3.0583����5֡ 3.0300
