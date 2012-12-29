%MELP600 4帧5bits 带通浊音强度码本训练
clear all;
load('../trainData/BandPassVoicing.mat'); %V_Band_Pass
%四帧联合训练
comb = 4;
[len_temp, dimen_temp] = size(V_Band_Pass);
length = fix(len_temp/comb);
codebook_dimen = dimen_temp*comb;
train_signal = zeros(length, codebook_dimen);

weight = [1.0 1.0 0.7 0.4 0.1];
BandPassCons = [0 0 0 0 0; 1 0 0 0 0; 1 1 1 0 0; 1 1 1 1 1];
%pre-prosess
tempData = zeros(len_temp, dimen_temp);
for i=1:len_temp
    distance = zeros(4,1);
    for j=1:4
        distance(j) = sqrt(sum(((V_Band_Pass(i,:)-BandPassCons(j,:)).*weight).^2));
    end
    [value, idx] = min(distance);
    tempData(i,:) = BandPassCons(idx,:);
end
%combine data
for i=1:length    
    train_signal(i,1:5) = tempData(comb*i-3, :);
    train_signal(i,6:10) = tempData(comb*i-2, :);
    train_signal(i,11:15) = tempData(comb*i-1, :);
    train_signal(i,16:20) = tempData(comb*i, :);
end

stage1_b = 5;
VQ1 = zeros(length, 1);
residStage1 = zeros(length, codebook_dimen);

%stage1, train with origin signal
BandPassCB_5b = codeBookTrain(train_signal, stage1_b);
save('BandPassCB_5b.mat', 'BandPassCB_5b');
%Vector Quantization
for i = 1:length
    distance = pdist2(train_signal(i,:), BandPassCB_5b);
    [value, idx] = min(distance);
    VQ1(i) = idx;
    residStage1(i,:) = train_signal(i,:) - BandPassCB_5b(idx,:);    
end
disp('bandPass_5b completed');
save('bandPass_5b.mat');

