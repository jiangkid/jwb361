function [ LSF ] = LSF_VQ1_d( LSF_Q, mode )
%melp600_LSF_d Summary of this function goes here
%   Detailed explanation goes here
global MODE1 MODE2 MODE3 MODE4 MODE5 MODE6;
global LSF_CB_32_s1 LSF_CB_32_s2 LSF_CB_32_s3 LSF_CB_32_s4;%32b=9+8+8+7
global LSF_CB_30_s1 LSF_CB_30_s2 LSF_CB_30_s3 LSF_CB_30_s4;%30b=9+8+7+6
global LSF_CB_36_s1 LSF_CB_36_s2 LSF_CB_36_s3 LSF_CB_36_s4;%36b=10+9+9+8
switch mode
    case MODE1
        LSF_Data = MSVQ_d(LSF_CB_36_s1,LSF_Q(1),LSF_CB_36_s2,LSF_Q(2),LSF_CB_36_s3,LSF_Q(3), LSF_CB_36_s4,LSF_Q(4));
    case {MODE2, MODE3, MODE4, MODE5}        
        LSF_Data = MSVQ_d(LSF_CB_30_s1,LSF_Q(1),LSF_CB_30_s2,LSF_Q(2),LSF_CB_30_s3,LSF_Q(3), LSF_CB_30_s4,LSF_Q(4));
    case MODE6
        LSF_Data = MSVQ_d(LSF_CB_32_s1,LSF_Q(1),LSF_CB_32_s2,LSF_Q(2),LSF_CB_32_s3,LSF_Q(3), LSF_CB_32_s4,LSF_Q(4));
    otherwise
        err('mode error');
end
% LSF_Data = melp_matlab(12, LSF_Q, mode);
% LSF_Data = LSF_Data/(2^15) * 4000;

LSF(1,:) = LSF_Data(1:10);
LSF(2,:) = LSF_Data(11:20);
LSF(3,:) = LSF_Data(21:30);
LSF(4,:) = LSF_Data(31:40);
end
