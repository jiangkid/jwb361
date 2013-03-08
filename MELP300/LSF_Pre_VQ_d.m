function [ LSF ] = LSF_Pre_VQ_d( LSF_Q, mode )
%melp300_LSF_d Summary of this function goes here
%   Detailed explanation goes here
global MODE1 MODE2 MODE3 MODE4;
global LSF_CB_754_7 LSF_CB_754_5 LSF_CB_754_4;%16bit
global LSF_CB_764_7 LSF_CB_764_6 LSF_CB_764_4;%17bit
global LSF_CB_765_7 LSF_CB_765_6 LSF_CB_765_5;%18bit
global lsf_mean lsfPreviousRestore;
b = [0.5547 0.2699 0.2090 0.3146 0.3382 0.3895 0.4183 0.3630 0.3724 0.2809];
switch mode
    case MODE1
        LSF_Data(1,:) = MSVQ_d(LSF_CB_765_7,LSF_Q(1,1),LSF_CB_765_6,LSF_Q(1,2),LSF_CB_765_5,LSF_Q(1,3));
        LSF_Data(2,:) = MSVQ_d(LSF_CB_765_7,LSF_Q(2,1),LSF_CB_765_6,LSF_Q(2,2),LSF_CB_765_5,LSF_Q(2,3));
    case {MODE2}
        LSF_Data(1,:) = MSVQ_d(LSF_CB_764_7,LSF_Q(1,1),LSF_CB_764_6,LSF_Q(1,2),LSF_CB_764_4,LSF_Q(1,3));
        LSF_Data(2,:) = MSVQ_d(LSF_CB_764_7,LSF_Q(2,1),LSF_CB_764_6,LSF_Q(2,2),LSF_CB_764_4,LSF_Q(2,3));
    case {MODE3,MODE4}
        LSF_Data(1,:) = MSVQ_d(LSF_CB_754_7,LSF_Q(1,1),LSF_CB_754_5,LSF_Q(1,2),LSF_CB_754_4,LSF_Q(1,3));
        LSF_Data(2,:) = MSVQ_d(LSF_CB_754_7,LSF_Q(2,1),LSF_CB_754_5,LSF_Q(2,2),LSF_CB_754_4,LSF_Q(2,3));
    otherwise
        err('mode error');
end
lsf_res_decode(1,:) = LSF_Data(1, 1:10);
lsf_res_decode(2,:) = LSF_Data(1, 11:20);
lsf_res_decode(3,:) = LSF_Data(1, 21:30);
lsf_res_decode(4,:) = LSF_Data(1, 31:40);
lsf_res_decode(5,:) = LSF_Data(2, 1:10);
lsf_res_decode(6,:) = LSF_Data(2, 11:20);
lsf_res_decode(7,:) = LSF_Data(2, 21:30);
lsf_res_decode(8,:) = LSF_Data(2, 31:40);

%»Ö¸´
LSF = zeros(8, 10);
for i = 1:8
    LSF(i,:) = b(i).*lsfPreviousRestore + lsf_res_decode(i,:);
end
lsfPreviousRestore = LSF(8,:);

%¼Ó¾ùÖµ
for i = 1:8
    LSF(i,:) = LSF(i,:) + lsf_mean;
end
for i = 1:8
    for j=1:10
        if(LSF(i,j)<=0) || (LSF(i,j)>=4000)
            LSF(i,j) = lsf_mean(j);
        end
    end
end

end

