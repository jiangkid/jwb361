[row, column] = size(lsf_all);
superFrameLen = 6;
superFrameNum = column/superFrameLen; %超级帧数
trueIdx = [1,3,4,6];
interpIdx = [2, 5];
absErrAll(row,3) = 0;
relateErrAll(row,3) = 0;

for rowIdx = 1:row
    lsf_row = lsf_all(rowIdx,:);
    absErr1 = 0; 
    absErr2 = 0;
    absErr3 = 0;
    relateErr1 = 0;
    relateErr2 = 0;
    relateErr3 = 0;
    for frameIdx = 1:superFrameNum
        lsf_data = lsf_row(superFrameLen*(frameIdx-1)+1 : superFrameLen*frameIdx);
        
        y1 = interp1(trueIdx, lsf_data(trueIdx), interpIdx); %线性插值
        absErr1 = absErr1 + abs(y1 - lsf_data(interpIdx));
        relateErr1 = relateErr1 + abs((y1 - lsf_data(interpIdx))./lsf_data(interpIdx));
        
        y2 = interp1(trueIdx, lsf_data(trueIdx), interpIdx, 'cubic'); %三次方程式插值        
        absErr2 = absErr2 + abs(y2 - lsf_data(interpIdx));
        relateErr2 = relateErr2 + abs((y2 - lsf_data(interpIdx))./lsf_data(interpIdx));
        
        y3 = interp1(trueIdx, lsf_data(trueIdx), interpIdx, 'spline'); %样条插值
        absErr3 = absErr3 + abs(y3 - lsf_data(interpIdx));
        relateErr3 = relateErr3 + abs((y3 - lsf_data(interpIdx))./lsf_data(interpIdx));
    end    
    absErrAll(rowIdx,:) = [sum(absErr1), sum(absErr2), sum(absErr3)];
    relateErrAll(rowIdx,:) = [sum(relateErr1), sum(relateErr2), sum(relateErr3)];
     %plot([sum(err1), sum(err2), sum(err3)]*100./(2*superFrameNum), '-*');
     %结论：针对LSF系数帧间插值,线性插值相对误差最小
end
