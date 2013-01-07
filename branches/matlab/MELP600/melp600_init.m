global MODE1 MODE2 MODE3 MODE4 MODE5 MODE6 MODE_DATA;
MODE1 = 1; MODE2 = 2; MODE3 = 3; MODE4 = 4; MODE5 = 5; MODE6 = 6;
MODE_DATA = [
    0 0 0 0;
    0 0 0 1; 0 0 1 0; 0 1 0 0; 1 0 0 0;
    0 1 0 1; 0 1 1 0; 1 0 0 1; 1 0 1 0;
    1 1 0 0; 0 0 1 1;
    1 1 0 1; 1 1 1 0; 0 1 1 1; 1 0 1 1;
    1 1 1 1];
global BandPassCB_5b;
load('./codebook/BandPassCB_5b.mat');%BandPassCB_5b
global  pitchCB_6b pitchCB_8b;
load('./codebook/pitchCB_6b.mat');%pitchCB_6b
load('./codebook/pitchCB_8b.mat');%pitchCB_8b
global gainCB_9b gainCB_65_6 gainCB_65_5 gainCB_76_7 gainCB_76_6;
load('./codebook/gainCB_9b.mat');%gainCB_9b
load('./codebook/gainCB_65b.mat');%gainCB_65_6, gainCB_65_5
load('./codebook/gainCB_76b.mat');%gainCB_76_7, gainCB_76_6
global LSF_CB_753_7 LSF_CB_753_5 LSF_CB_753_3;
load('./codebook/LSF_CB_753b.mat');%LSF_CB_753_7, LSF_CB_753_5, LSF_CB_753_3
global LSF_CB_754_7 LSF_CB_754_5 LSF_CB_754_4;
load('./codebook/LSF_CB_754b.mat');%LSF_CB_754_7, LSF_CB_754_5, LSF_CB_754_4
global LSF_CB_765_7 LSF_CB_765_6 LSF_CB_765_5;
load('./codebook/LSF_CB_765b.mat');%LSF_CB_765_7, LSF_CB_765_6, LSF_CB_765_5
