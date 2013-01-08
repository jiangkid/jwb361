function [ LSF ] = melp600_LSF_d( LSF_Q, mode )
%melp600_LSF_d Summary of this function goes here
%   Detailed explanation goes here
global MODE1 MODE2 MODE3 MODE4 MODE5 MODE6;
global LSF_CB_753_7 LSF_CB_753_5 LSF_CB_753_3;%15bit
global LSF_CB_754_7 LSF_CB_754_5 LSF_CB_754_4;%16bit
global LSF_CB_765_7 LSF_CB_765_6 LSF_CB_765_5;%18bit
switch mode
    case MODE1
        LSF(1,:) = MSVQ_d(LSF_CB_765_7,LSF_Q(1,1),LSF_CB_765_6,LSF_Q(1,2),LSF_CB_765_5,LSF_Q(1,3));
        LSF(2,:) = MSVQ_d(LSF_CB_765_7,LSF_Q(2,1),LSF_CB_765_6,LSF_Q(2,2),LSF_CB_765_5,LSF_Q(2,3));
    case {MODE2, MODE3, MODE4, MODE5}        
        LSF(1,:) = MSVQ_d(LSF_CB_753_7,LSF_Q(1,1),LSF_CB_753_5,LSF_Q(1,2),LSF_CB_753_3,LSF_Q(1,3));
        LSF(2,:) = MSVQ_d(LSF_CB_753_7,LSF_Q(2,1),LSF_CB_753_5,LSF_Q(2,2),LSF_CB_753_3,LSF_Q(2,3));
    case MODE6
        LSF(1,:) = MSVQ_d(LSF_CB_754_7,LSF_Q(1,1),LSF_CB_754_5,LSF_Q(1,2),LSF_CB_754_4,LSF_Q(1,3));
        LSF(2,:) = MSVQ_d(LSF_CB_754_7,LSF_Q(2,1),LSF_CB_754_5,LSF_Q(2,2),LSF_CB_754_4,LSF_Q(2,3));
    otherwise
        err('mode error');
end
end

