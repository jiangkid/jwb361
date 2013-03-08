function [ LSF ] = LSF_VQ_new_d( LSF_Q, mode )
%melp300_LSF_d Summary of this function goes here
%   Detailed explanation goes here
global MODE1 MODE2 MODE3 MODE4;
global LSF_CB_36_s1 LSF_CB_36_s2 LSF_CB_36_s3 LSF_CB_36_s4;%36b=10+9+9+8
global LSF_CB_33_s1 LSF_CB_33_s2 LSF_CB_33_s3 LSF_CB_33_s4;%33b=10+8+8+7
global LSF_CB_31_s1 LSF_CB_31_s2 LSF_CB_31_s3 LSF_CB_31_s4;%31b=10+8+7+6

switch mode
    case MODE1
        LSF_Data = MSVQ_d(LSF_CB_36_s1,LSF_Q(1),LSF_CB_36_s2,LSF_Q(2),LSF_CB_36_s3,LSF_Q(3),LSF_CB_36_s4,LSF_Q(4));
    case {MODE2}
        LSF_Data = MSVQ_d(LSF_CB_33_s1,LSF_Q(1),LSF_CB_33_s2,LSF_Q(2),LSF_CB_33_s3,LSF_Q(3),LSF_CB_33_s4,LSF_Q(4));
    case {MODE3,MODE4}
        LSF_Data = MSVQ_d(LSF_CB_31_s1,LSF_Q(1),LSF_CB_31_s2,LSF_Q(2),LSF_CB_31_s3,LSF_Q(3),LSF_CB_31_s4,LSF_Q(4));
    otherwise
        err('mode error');
end

LSF = zeros(8,10);
for i=1:8
    LSF(i,:) = LSF_Data((i-1)*10+1:i*10);
end

end
