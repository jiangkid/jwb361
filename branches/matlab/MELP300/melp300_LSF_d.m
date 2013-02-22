function [ LSF ] = melp300_LSF_d( LSF_Q, mode )
%melp300_LSF_d Summary of this function goes here
%   Detailed explanation goes here
global MODE1 MODE2 MODE3 MODE4;
global LSF_CB_754_7 LSF_CB_754_5 LSF_CB_754_4;%16bit
global LSF_CB_764_7 LSF_CB_764_6 LSF_CB_764_4;%17bit
global LSF_CB_765_7 LSF_CB_765_6 LSF_CB_765_5;%18bit
switch mode
    case MODE1
        LSF_Data(1,:) = MSVQ_d(LSF_CB_765_7,LSF_Q(1,1),LSF_CB_765_6,LSF_Q(1,2),LSF_CB_765_5,LSF_Q(1,3));
        LSF_Data(2,:) = MSVQ_d(LSF_CB_765_7,LSF_Q(2,1),LSF_CB_765_6,LSF_Q(2,2),LSF_CB_765_5,LSF_Q(2,3));
    case {MODE2, MODE3}        
        LSF_Data(1,:) = MSVQ_d(LSF_CB_764_7,LSF_Q(1,1),LSF_CB_764_6,LSF_Q(1,2),LSF_CB_764_4,LSF_Q(1,3));
        LSF_Data(2,:) = MSVQ_d(LSF_CB_764_7,LSF_Q(2,1),LSF_CB_764_6,LSF_Q(2,2),LSF_CB_764_4,LSF_Q(2,3));
    case MODE4
        LSF_Data(1,:) = MSVQ_d(LSF_CB_754_7,LSF_Q(1,1),LSF_CB_754_5,LSF_Q(1,2),LSF_CB_754_4,LSF_Q(1,3));
        LSF_Data(2,:) = MSVQ_d(LSF_CB_754_7,LSF_Q(2,1),LSF_CB_754_5,LSF_Q(2,2),LSF_CB_754_4,LSF_Q(2,3));
    otherwise
        err('mode error');
end
LSF(1,:) = LSF_Data(1, 1:10);
LSF(2,:) = LSF_Data(1, 11:20);
LSF(3,:) = LSF_Data(1, 21:30);
LSF(4,:) = LSF_Data(1, 31:40);
LSF(5,:) = LSF_Data(2, 1:10);
LSF(6,:) = LSF_Data(2, 11:20);
LSF(7,:) = LSF_Data(2, 21:30);
LSF(8,:) = LSF_Data(2, 31:40);
end

