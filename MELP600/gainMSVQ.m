function [VQ] = gainMSVQ(gain,CB1,CB2)
%
dim = size(CB1, 2);
JUDGE = 1000000000;
%stage1
M = 4;
d(1:M,1:dim+2)=JUDGE;
CBSize = size(CB1, 1);
for s=1:CBSize
    delta=gain-CB1(s,:);
    temp=sum(delta.^2);
    for n=1:M
        if temp<d(n,1)
            d(n+1:M+1,:)=d(n:M,:);%Êý¾ÝÏÂÒÆ
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
        temp=sum(delta.^2);
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

VQ = d(1,dim+2:dim+3);
end