clear all;
load('lsf_all.mat'); %lsf_all
train_signal = (lsf_all(:,1:1024))';
[signal_num, codebook_dimen] = size(train_signal);
codebook_size = 2^5; %
codebook = CodeBookInit(train_signal, codebook_size, codebook_dimen);
codebook_new = codebook;

sigMinDistIdx = zeros(1, signal_num);
       
circle_num=50;  %
D=50000;%
counter=0;
ave_distort = zeros(1,circle_num);
abs_distor_value = D;
for control_counter=1:circle_num;  %control_counter 为最大循环次数控制变量
    while(abs_distor_value>0.0000001)%0.0000001
        counter=counter+1;%j2
        
        %step 1
        for i = 1:signal_num 
            distance = pdist2(train_signal(i,:), codebook);
            [minDist,idx]=min(distance);
            sigMinDistIdx(i) = idx; %每个训练样本在码本中找到距离最近的码字
        end
        
        %计算码本质心(属于某个码字所有样本的质心)
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
        
        %求失真
        %ave_distort(j2)=0;
        ave_distort(counter) = 0;
        for signal_idx=1:signal_num
            distance = pdist2(train_signal(signal_idx,:), codebook(sigMinDistIdx(signal_idx),:));
            ave_distort(counter) = ave_distort(counter) + distance;
        end
        ave_distort(counter) = ave_distort(counter)/signal_num;
        
        %
        abs_distor_value=abs((D-ave_distort(counter))/D);%
        D=ave_distort(counter);
    end
    control_counter=circle_num;%0.0000001j1circle_number
end

save('codebook.mat', 'codebook');
