clear;
addpath('f:\matlab\common\voicebox');
load('mfcc_19_cb.mat');
J = 24;
n = 200;
all_HMM = struct([]);
transNum = 6; %状态数
emisNum = 256; %输出观测数
peopleNum = 8; %8人用于训练
chineseNum = 9; %训练中文数字1~9
transInit = [0.5 0.5 0 0 0 0;...
             0 0.5 0.5 0 0 0;...
             0 0 0.5 0.5 0 0;...
             0 0 0 0.5 0.5 0;...
             0 0 0 0 0.5 0.5 ;...
             0 0 0 0 0 1];
emisInit = ones(6,emisNum)/emisNum;

for numIdx = 1:chineseNum
     idx_cell = cell(peopleNum,1);
    for peopleIdx = 1:peopleNum
        fileName = sprintf('./corpus/female%d/%d.wav',peopleIdx, numIdx);
        [inSpeech, fs] = audioread(fileName);
        
        %提取MFCC参数
        inSpeech = filter([1 -0.9378], 1 ,inSpeech);%预加重
        
        vs = vadsohn(inSpeech,fs,[]);%VAD去静音
        speech = inSpeech(vs==1);
        mfcc_data = mfcc(speech, fs, 'My', J, J, n, n/20);
        
        %矢量量化
        data_idx = vector_quant(mfcc_data,mfcc_19_8b);
        all_HMM(peopleIdx).data_idx = data_idx;
        [TRANS_EST, EMIS_EST] = hmmtrain(data_idx, transInit, emisInit);
        transInit = TRANS_EST;
        emisInit = EMIS_EST;
    end
    
%     [TRANS_EST, EMIS_EST] = hmmtrain(idx_cell, transInit, emisInit);
    %训练模型
    all_HMM(peopleIdx).obj_gmm = gmdistribution.fit(all_GMM(peopleIdx).data_mfcc, K, 'Options', options, 'CovType', 'diagonal', 'Regularize', 1e-15);
end
save('all_HMM.mat','all_HMM');
