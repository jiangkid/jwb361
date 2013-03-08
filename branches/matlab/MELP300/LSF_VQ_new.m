function [ LSF_Q ] = LSF_VQ_new( lpcSuper, LSF, mode )
%LSF_VQ Summary of this function goes here
% f: lpc
global MODE1 MODE2 MODE3 MODE4;
global LSF_CB_36_s1 LSF_CB_36_s2 LSF_CB_36_s3 LSF_CB_36_s4;%36b=10+9+9+8
global LSF_CB_33_s1 LSF_CB_33_s2 LSF_CB_33_s3 LSF_CB_33_s4;%33b=10+8+8+7
global LSF_CB_31_s1 LSF_CB_31_s2 LSF_CB_31_s3 LSF_CB_31_s4;%31b=10+8+7+6

[row, col] = size(LSF);
if row ~= 8
    error('row ~= 8');
end

%calculate weight
weight = zeros(1,80);
for i=1:8
    w = zeros(1, 10);
    f = LSF(i,:);
    lpcs = lpcSuper(i,:);
    for j=1:10
        w(j)=1+exp(-1i*f(j)*(1:10))*lpcs';
    end
    w=abs(w).^2;
    w=w.^(-0.3);
    w(9)=w(9)*0.64;
    w(10)=w(10)*0.16;
    weight((i-1)*10+1:i*10) = w;
end

%concatenation
LSF_VQ_Data = zeros(1,80);
for i=1:8
    LSF_VQ_Data((i-1)*10+1:i*10) = LSF(i,:);
end

%Vector Quantization
switch mode
    case MODE1
        LSF_Q = LSF_4SVQ(LSF_VQ_Data, weight, LSF_CB_36_s1,LSF_CB_36_s2,LSF_CB_36_s3,LSF_CB_36_s4);
    case {MODE2}
        LSF_Q = LSF_4SVQ(LSF_VQ_Data, weight, LSF_CB_33_s1,LSF_CB_33_s2,LSF_CB_33_s3,LSF_CB_33_s4);
    case {MODE3,MODE4}
        LSF_Q = LSF_4SVQ(LSF_VQ_Data, weight, LSF_CB_31_s1,LSF_CB_31_s2,LSF_CB_31_s3,LSF_CB_31_s4);
end
end

