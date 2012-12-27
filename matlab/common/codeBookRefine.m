function codebook = codeBookRefine(codebook, train_signal)
%去除非典型胞腔
e = 0.01;%分裂系数
k1 = 1+e;
k2 = 1-e;
K = 10;%最大10次
L = 20;
disp('codeBookRefine');

[codebook_size, codebook_dimen] = size(codebook);
[signal_num, signal_dimen] = size(train_signal);
if codebook_dimen ~= signal_dimen
    err('codebook_dimen not equal to signal_dimen');
end

sigMinDistIdx = zeros(1, signal_num);
for counter = 1:K
    %step 1 训练数据进行聚类
    for i = 1:signal_num
        distance = pdist2(train_signal(i,:), codebook);
        [minDist,idx]=min(distance);
        sigMinDistIdx(i) = idx; %每个训练样本在码本中找到距离最近的码字
    end
    %统计每个码字的训练数据个数
    NN=zeros(codebook_size,1);
    for i = 1:signal_num
        NN(sigMinDistIdx(i)) = NN(sigMinDistIdx(i)) + 1;
    end
    [maxValue, maxIdx] = max(NN);
    [minValue, minIdx] = min(NN);
    if maxValue/minValue < L %结束
        break;
    end
    %否则，剔除最小胞腔，分裂最大胞腔
    %方法一，码字分裂 谱失真 1.9570dB>1.9528dB !
    %codebook(minIdx,:) = k2 * codebook(maxIdx,:);
    %codebook(maxIdx,:) = k1 * codebook(maxIdx,:);
    %方法二，形心分裂 谱失真 1.9566>1.9528dB !
    y = zeros(1, codebook_dimen); %
    for i = 1:signal_num
        if sigMinDistIdx(i) == maxIdx
            for m=1:codebook_dimen
                y(m)=y(m)+train_signal(i,m);
            end
        end
    end
    centroidMax = y/maxValue;
    codebook(minIdx,:) = k2 * centroidMax;
    codebook(maxIdx,:) = k1 * centroidMax;
end
%再次LBG迭代，谱失真 1.9511 < 1.9528dB ,达到预期目标
codebook = LBGFun(codebook, train_signal);
end
