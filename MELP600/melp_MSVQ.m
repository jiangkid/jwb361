%Quantization of Prediction Coefficients
%Input:
%        lpcs(LPC parameters)
%        f(corresponding LSF parameters)
%Output:
%        g(Index)
function g=melp_MSVQ(lpcs,f)
global stage1;
global stage2;
w = zeros(1,10);
for j=1:10 %Get the Weighs
    w(j)=1+exp(-1i*f(j)*(1:10))*lpcs'; 
end
%w=abs(w);
%w=w.^0.3;
w=abs(w).^2;
w=w.^(-0.3);
w(9)=w(9)*0.64;
w(10)=w(10)*0.16;

JUDGE = 100000000;
%d(m,1) is the judgement.
%d(m,2:11) is the minus of the vector and the codeword
%d(m,12:15) is the codeword.
d(1:8,1:12)=JUDGE;
for s=1:128
    delta=f-stage1((s-1)*10+1:s*10);
    temp=w*(delta.^2)';
    if temp > JUDGE
         error('temp error: %d', temp);
    end
    m=1;
    while m<9
        if temp<d(m,1)
            d(m+1:9,:)=d(m:8,:);%数据下移
            d(m,1)=temp;
            d(m,2:11)=delta;
            d(m,12)=s;
            break;
        end
        m=m+1;
    end
end
%第一级量化完成后，矩阵根据第一列数据从小到大排列

for s=1:3
    e=d;
    d(1:8,1:12)=JUDGE;    
    for j=1:8
        for k=1:64
            delta=e(j,2:11)-stage2(s,(k-1)*10+1:k*10);
            temp=w*(delta.^2)';            
            if temp > JUDGE
                error('temp error: %d', temp);
            end
            for n=1:8
                if temp<d(n,1)
                    d(n+1:9,:)=d(n:8,:);
                    d(n,1)=temp;
                    d(n,2:11)=delta;
                    d(n,12:11+s)=e(j,12:11+s);
                    d(n,12+s)=k;
                    break;
                end
            end
        end
    end
end
g=d(1,12:15);
end