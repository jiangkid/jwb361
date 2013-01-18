clear all;
load('../trainData/BandPassVoicing.mat'); %V_Band_Pass
[length, dim] = size(V_Band_Pass);
BandPassCons = [0 0 0 0 0; 1 0 0 0 0; 1 1 1 0 0; 1 1 1 1 1];
dataOut = zeros(length, dim);
bandPass_all = zeros(20, dim);%
bandPass_all_cnt = zeros(20, 1);
position = 1;

% for i = 1:length
%     dataOut(i,:) = constrain(V_Band_Pass(i,:));
% end
%����
for i = 1:length
    if V_Band_Pass(i,1) < 0.6
        dataOut(i,:) = 0;
    else
        dataOut(i,1) = 1;
        for j = 2:5
            if V_Band_Pass(i, j) > 0.6
                dataOut(i, j) = 1;
            else
                dataOut(i, j) = 0;
            end
        end
        if isequal(dataOut(i, 2:5),[0 0 0 1])
            dataOut(i, 2:5) = 0;
        end
    end
end

%ͳ�Ƹ���ģʽ���ֵĸ���
for i = 1:length
    flag = 0;
    data = dataOut(i,:);
    for j = 1:position
        if isequal(data, bandPass_all(j,:)) %ͳ�Ƽ����ҵ�������
            bandPass_all_cnt(j) = bandPass_all_cnt(j)+1;
            flag = 1;
            break;
        end
    end
    if flag == 0 %����������
        position = position+1;
        bandPass_all(position,:) = data;
        bandPass_all_cnt(position) = 1;
    end
end
[B, IX] = sort(bandPass_all_cnt,'descend');
