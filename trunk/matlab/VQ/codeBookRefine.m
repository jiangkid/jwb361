function codebook = codeBookRefine(codebook, train_signal)
%ȥ���ǵ��Ͱ�ǻ
e = 0.01;%����ϵ��
k1 = 1+e;
k2 = 1-e;
K = 10;%���10��
L = 20;
disp('codeBookRefine');

[codebook_size, codebook_dimen] = size(codebook);
[signal_num, signal_dimen] = size(train_signal);
if codebook_dimen ~= signal_dimen
    err('codebook_dimen not equal to signal_dimen');
end

sigMinDistIdx = zeros(1, signal_num);
for counter = 1:K
    %step 1 ѵ�����ݽ��о���
    for i = 1:signal_num
        distance = pdist2(train_signal(i,:), codebook);
        [minDist,idx]=min(distance);
        sigMinDistIdx(i) = idx; %ÿ��ѵ���������뱾���ҵ��������������
    end
    %ͳ��ÿ�����ֵ�ѵ�����ݸ���
    NN=zeros(codebook_size,1);
    for i = 1:signal_num
        NN(sigMinDistIdx(i)) = NN(sigMinDistIdx(i)) + 1;
    end
    [maxValue, maxIdx] = max(NN);
    [minValue, minIdx] = min(NN);
    if maxValue/minValue < L %����
        break;
    end
    %�����޳���С��ǻ����������ǻ
    %����һ�����ַ��� ��ʧ�� 1.9570dB>1.9528dB !
    %codebook(minIdx,:) = k2 * codebook(maxIdx,:);
    %codebook(maxIdx,:) = k1 * codebook(maxIdx,:);
    %�����������ķ��� ��ʧ�� 1.9566>1.9528dB !
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
%�ٴ�LBG��������ʧ�� 1.9511 < 1.9528dB ,�ﵽԤ��Ŀ��
codebook = LBGFun(codebook, train_signal);
end
