%Quantization of Prediction Coefficients
%Input:
%        lpcs(LPC parameters)
%        f(corresponding LSF parameters)
%Output:
%        g(Index)
function g=melp_MSVQ(lpcs,f)
global stage1 stage2;
global LSF_CB1 LSF_CB2 LSF_CB3 LSF_CB4;
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

% d = m_best(f, LSF_CB1, w, 8);
% d = m_best(d, LSF_CB2, w, 8);
% d = m_best(d, LSF_CB3, w, 8);
% d = m_best(d, LSF_CB4, w, 8);
% g=d(1,12:15);

JUDGE = 1000000000;
M = 8;
%d(m,1) is the judgement.
%d(m,2:11) is the minus of the vector and the codeword
%d(m,12:15) is the codeword.
d(1:M,1:12)=JUDGE;
for s=1:128
    delta=f-LSF_CB1(s,:);
    temp=w*(delta.^2)';
    for n=1:M
        if temp<d(n,1)
            d(n+1:M+1,:)=d(n:M,:);%Êý¾ÝÏÂÒÆ
            d(n,1)=temp;
            d(n,2:11)=delta;
            d(n,12)=s;
            break;
        end
    end
end

%stage2
e=d;
d(1:M,1:13)=JUDGE;
for j=1:8
    for k=1:64
        delta=e(j,2:11)-LSF_CB2(k,:);
        temp=w*(delta.^2)';
        for n=1:M
            if temp<d(n,1)
                d(n+1:M+1,:)=d(n:M,:);
                d(n,1)=temp;
                d(n,2:11)=delta;
                d(n,12)=e(j,12);
                d(n,13)=k;
                break;
            end
        end
    end
end

%stage3
e=d;
d(1:M,1:14)=JUDGE;
for j=1:8
    for k=1:64
        delta=e(j,2:11)-LSF_CB3(k,:);
        temp=w*(delta.^2)';
        for n=1:M
            if temp<d(n,1)
                d(n+1:M+1,:)=d(n:M,:);
                d(n,1)=temp;
                d(n,2:11)=delta;
                d(n,12:13)=e(j,12:13);
                d(n,14)=k;
                break;
            end
        end
    end
end

%stage4
e=d;
d(1:M,1:15)=JUDGE;
for j=1:8
    for k=1:64
        delta=e(j,2:11)-LSF_CB4(k,:);
        temp=w*(delta.^2)';
        for n=1:M
            if temp<d(n,1)
                d(n+1:M+1,:)=d(n:M,:);
                d(n,1)=temp;
                d(n,2:11)=delta;
                d(n,12:14)=e(j,12:14);
                d(n,15)=k;
                break;
            end
        end
    end
end

g=d(1,12:15);
end