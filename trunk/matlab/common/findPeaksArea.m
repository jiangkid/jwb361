function [ locaArea ] = findPeaksArea( input )
%寻找波峰区间：包含峰值点的一阶导数极点区间
locaArea = [];
[pks, peaksIdx] = findpeaks(input);%局部最大值（峰值）
diff1 = diff(input);%一阶导数
[maxValues, diff1MaxIdx]=findpeaks(diff1);%局部最大值
tempData =  2*mean(diff1) - diff1;
[minValues, diff1MinIdx]=findpeaks(tempData);%局部最小值
if isempty(peaksIdx) || isempty(diff1MaxIdx) || isempty(diff1MinIdx)
    return;
end
%配对
% pairsNum = size(diff1MaxIdx, 2);
% pairs = zeros(pairsNum, 2);
% for i = 1:pairsNum
%     pairs(i, 1) = diff1MaxIdx(i);
% end
maxNum = size(diff1MaxIdx, 1);
minNum = size(diff1MinIdx ,1);

peaksNum = size(peaksIdx ,1);
locaArea = zeros(peaksNum, 2);
for i = 1:peaksNum
    peakIdx = peaksIdx(i);
    %左值，从后向前找
    for j = maxNum:-1:1
        if diff1MaxIdx(j) < peakIdx
            break;
        end
    end
    locaArea(i, 1) = diff1MaxIdx(j);
    %右值，从前向后找
    for k = 1:minNum
        if diff1MinIdx(k) > peakIdx
            break;
        end
    end
    locaArea(i, 2) = diff1MinIdx(k);
end

end
