function [ locaArea ] = findPeaksArea( input )
%Ѱ�Ҳ������䣺������ֵ���һ�׵�����������
locaArea = [];
[pks, peaksIdx] = findpeaks(input);%�ֲ����ֵ����ֵ��
diff1 = diff(input);%һ�׵���
[maxValues, diff1MaxIdx]=findpeaks(diff1);%�ֲ����ֵ
tempData =  2*mean(diff1) - diff1;
[minValues, diff1MinIdx]=findpeaks(tempData);%�ֲ���Сֵ
if isempty(peaksIdx) || isempty(diff1MaxIdx) || isempty(diff1MinIdx)
    return;
end
%���
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
    %��ֵ���Ӻ���ǰ��
    for j = maxNum:-1:1
        if diff1MaxIdx(j) < peakIdx
            break;
        end
    end
    locaArea(i, 1) = diff1MaxIdx(j);
    %��ֵ����ǰ�����
    for k = 1:minNum
        if diff1MinIdx(k) > peakIdx
            break;
        end
    end
    locaArea(i, 2) = diff1MinIdx(k);
end

end
