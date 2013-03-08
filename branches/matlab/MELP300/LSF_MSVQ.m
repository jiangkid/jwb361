function [ VQ ] = LSF_MSVQ( LSFData, w, CB1, CB2, CB3)
%LSF_MSVQ, LSF多级矢量量化

% %stage1
% [value, idx] = GetMatch(LSFData, CB1, w);
% VQ(1) = idx;
% residStage1 = LSFData - CB1(idx,:);
% %stage2
% [value, idx] = GetMatch(residStage1, CB2, w);
% VQ(2) = idx;
% residStage2 = residStage1 - CB2(idx,:);
% %stage3
% [value, idx] = GetMatch(residStage2, CB3, w);
% VQ(3) = idx;
dim = size(CB1, 2);
JUDGE = 1000000000;
%stage1
M = 10;
d(1:M,1:dim+2)=JUDGE;
CBSize = size(CB1, 1);
for s=1:CBSize
    delta=LSFData-CB1(s,:);
    temp=w*(delta.^2)';
    for n=1:M
        if temp<d(n,1)
            d(n+1:M+1,:)=d(n:M,:);%数据下移
            d(n,1)=temp;
            d(n,2:dim+1)=delta;
            d(n,dim+2)=s;
            break;
        end
    end
end

%stage2
e=d;
d(1:M,1:dim+3)=JUDGE;
CBSize = size(CB2, 1);
for j=1:M
    for k=1:CBSize        
        delta=e(j,2:dim+1)-CB2(k,:);        
        temp=w*(delta.^2)';
        for n=1:M
            if temp<d(n,1)
                d(n+1:M+1,:)=d(n:M,:);
                d(n,1)=temp;
                d(n,2:dim+1)=delta;
                d(n,dim+2)=e(j,dim+2);
                d(n,dim+3)=k;
                break;
            end
        end
    end
end

%stage3
e=d;
d(1:M,1:dim+4)=JUDGE;
CBSize = size(CB3, 1);
for j=1:M
    for k=1:CBSize        
        delta=e(j,2:dim+1)-CB3(k,:);        
        temp=w*(delta.^2)';
        for n=1:M
            if temp<d(n,1)
                d(n+1:M+1,:)=d(n:M,:);
                d(n,1)=temp;
                d(n,2:dim+1)=delta;
                d(n,dim+2:dim+3)=e(j,dim+2:dim+3);
                d(n,dim+4)=k;
                break;
            end
        end
    end
end
VQ = d(1,dim+2:dim+4);
end