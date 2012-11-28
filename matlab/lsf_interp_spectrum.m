clear all;
clc;
load('lsf_all.mat');
[row, column] = size(lsf_all);%75398帧
superFrameLen = 6;
superFrameNum = fix(column/superFrameLen); %超级帧数
trueIdx = [1,2,4,6];
interpIdx = [3, 5];%插值帧
superFrameLSF(row, superFrameLen) = 0;
SD1(superFrameNum, 1) = 0;
SD2(superFrameNum, 1) = 0;
for frameIdx = 1:superFrameNum
    superFrameLSF = lsf_all( : , superFrameLen*(frameIdx-1)+1 : superFrameLen*frameIdx );
    interpLSF(10, 2) = 0;
    for rowIdx = 1 : row
        rowData = superFrameLSF(rowIdx, : );
        y = interp1(trueIdx, rowData(trueIdx), interpIdx); %线性插值
        if(isnan(y))
            y = interp1(trueIdx, rowData(trueIdx), interpIdx, 'cubic'); %线性插值
        end
        interpLSF(rowIdx, : ) = y;
    end
    %计算谱失真
    SD1(frameIdx) = spectral_distortion(superFrameLSF(:,3), interpLSF(:,1));
    SD2(frameIdx) = spectral_distortion(superFrameLSF(:,5), interpLSF(:,2));  
end

%2、3帧插值，谱失真：第2帧 3.0710，第5帧 3.0482
%3、4帧插值，谱失真：第3帧 3.0551，第4帧 3.0433
%2、5帧插值，谱失真：第2帧 2.5281，第5帧 2.4942
%3、5帧插值，谱失真：第3帧 2.5191，第5帧 2.4942/////
%4、5帧插值，谱失真：第4帧 3.0583，第5帧 3.0300
