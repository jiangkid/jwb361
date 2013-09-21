function codebook = LBGFun(codebook, train_signal, ABS)
%LBG algorithm
if nargin<3 
    ABS=1e-5;
end
[codebook_size, codebook_dimen] = size(codebook);
[signal_num, signal_dimen] = size(train_signal);
if codebook_dimen ~= signal_dimen
    err('codebook_dimen not equal to signal_dimen');
end
sigMinDistIdx = zeros(1, signal_num);

ave_distort = 10000;
for counter=1:100;  %���100��
    
    %step 1 ��������
    for i = 1:signal_num
        distance = pdist2(train_signal(i,:), codebook);
        [minDist,idx]=min(distance);
        sigMinDistIdx(i) = idx; %ÿ��ѵ���������뱾���ҵ��������������
    end
    
    %step2 �����뱾����(����ĳ��������������������)
    N1=zeros(codebook_size,1);
    for codebook_idx = 1: codebook_size
        y = zeros(codebook_dimen,1); %
        N=0;
        for signal_idx=1:signal_num;
            if sigMinDistIdx(signal_idx) == codebook_idx
                for m=1:codebook_dimen
                    y(m)=y(m)+train_signal(signal_idx,m);
                end
                N=N+1; %
            end
        end
        if N>0
            for m=1:codebook_dimen
                codebook(codebook_idx,m) = y(m)/N;
            end
        end
        N1(codebook_idx,1)=N; %
    end
    
    %step3 ��ʧ��
    distortion = 0;
    for signal_idx=1:signal_num
        distance = pdist2(train_signal(signal_idx,:), codebook(sigMinDistIdx(signal_idx),:));
        distortion = distortion + distance;
    end
    distortion = distortion/signal_num;
    abs_distor=abs((ave_distort-distortion)/ave_distort);%
    %disp(abs_distor);
    if(abs_distor < ABS)
        break;
    end
    ave_distort = distortion;
end
end