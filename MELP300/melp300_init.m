global MODE1 MODE2 MODE3 MODE4 MODE_DATA;
MODE1 = 1; MODE2 = 2; MODE3 = 3; MODE4 = 4;
MODE_DATA = [
    0 0 0 0;
    0 0 0 1; 0 0 1 0; 0 1 0 0; 1 0 0 0;
    0 1 0 1; 0 1 1 0; 1 0 0 1; 1 0 1 0;
    1 1 0 0; 0 0 1 1;
    1 1 0 1; 1 1 1 0; 0 1 1 1; 1 0 1 1;
    1 1 1 1];
global BandPassCB_5b;
load('./codebook/BandPassCB_5b.mat');%BandPassCB_5b
global  pitchCB_9b;
% load('./codebook/pitchCB_6b.mat');%pitchCB_6b
load('./codebook/pitchCB_9b.mat');%pitchCB_9b
global gainCB_8b gainCB_65_6 gainCB_65_5 gainCB_76_7 gainCB_76_6;
load('./codebook/gainCB_8b.mat');%gainCB_8b
load('./codebook/gainCB_65b.mat');%gainCB_65_6, gainCB_65_5
load('./codebook/gainCB_76b.mat');%gainCB_76_7, gainCB_76_6
global LSF_CB_754_7 LSF_CB_754_5 LSF_CB_754_4;
load('./codebook/LSF_CB_754b.mat');%LSF_CB_754_7, LSF_CB_754_5, LSF_CB_754_4
global LSF_CB_764_7 LSF_CB_764_6 LSF_CB_764_4;
load('./codebook/LSF_CB_764b.mat');%LSF_CB_764_7, LSF_CB_764_6, LSF_CB_764_4
global LSF_CB_765_7 LSF_CB_765_6 LSF_CB_765_5;
load('./codebook/LSF_CB_765b.mat');%LSF_CB_765_7, LSF_CB_765_6, LSF_CB_765_5

global prePitch pitch_m prePitchQ preUV;
pitch_m = [50,50];%��ֵƽ������
prePitch = log10(50);
prePitchQ = log10(50);
preUV = 0;

global modeCount;
modeCount = [0 0 0 0 0 0];

lsf_mean = [0.1897	0.3640	0.6313	0.9681	1.2868	1.6050	1.9230	2.2065	2.5305	2.8074];
lsf_mean = lsf_mean*4000/pi;

global gainLast lsfLast;
gainLast = [64.5440 64.5571];
lsfLast = zeros(1,10);
global gainRestorPre lsfRestorPre;
gainRestorPre = [64.5440 64.5571];
lsfRestorPre = zeros(1,10);
