clear all;
load('../trainData/BandPassVoicing.mat'); %V_Band_Pass
%四帧联合训练
comb = 8;
[len_temp, dimen_temp] = size(V_Band_Pass);
length = fix(len_temp/comb);
codebook_dimen = dimen_temp*comb;
train_signal = zeros(length, codebook_dimen);
dataOut = zeros(len_temp, dimen_temp);

%pre-process
for i = 1:len_temp
    dataOut(i,:) = constrain(V_Band_Pass(i,:));
end
% %combine data
for i=1:length
    train_signal(i,1:5) = dataOut(comb*i-7, :);
    train_signal(i,6:10) = dataOut(comb*i-6, :);
    train_signal(i,11:15) = dataOut(comb*i-5, :);
    train_signal(i,16:20) = dataOut(comb*i-4, :);
    train_signal(i,21:25) = dataOut(comb*i-3, :);
    train_signal(i,26:30) = dataOut(comb*i-2, :);
    train_signal(i,31:35) = dataOut(comb*i-1, :);
    train_signal(i,36:40) = dataOut(comb*i, :);
end
% for i=1:length    
%     train_signal(i,1:5) = dataOut(comb*i-3, :);
%     train_signal(i,6:10) = dataOut(comb*i-2, :);
%     train_signal(i,11:15) = dataOut(comb*i-1, :);
%     train_signal(i,16:20) = dataOut(comb*i, :);
% end

bandPass_all = zeros(4^comb, codebook_dimen);
bandPass_all_cnt = zeros(4^comb, 1);
position = 1;

for i = 1:length
    flag = 0;
    data = train_signal(i,:);
    for j = 1:position
        if isequal(data, bandPass_all(j,:)) %统计集中找到了数据
            bandPass_all_cnt(j) = bandPass_all_cnt(j)+1;
            flag = 1;
            break;
        end
    end
    if flag == 0 %插入新数据
        position = position+1;
        bandPass_all(position,:) = data;
        bandPass_all_cnt(position) = 1;
    end
end
[B, IX] = sort(bandPass_all_cnt,'descend');
BandPassCB_new = zeros(32,codebook_dimen);
for i = 1:32
    BandPassCB_new(i,:) = bandPass_all(IX(i),:);
end
