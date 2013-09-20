clear;
addpath('f:\matlab\common\voicebox');
J = 24;
n = 200;

peopleNum = 8; %8人用于训练
chineseNum = 9; %训练中文数字1~9
speechAll = [];
%读取所有语音
for numIdx = 1:chineseNum
    for peopleIdx = 1:peopleNum
        fileName = sprintf('./corpus/female%d/%d.wav',peopleIdx, numIdx);
        [inSpeech, fs] = audioread(fileName);
        speechAll = [speechAll;inSpeech];
    end
end

%提取MFCC参数
speechAll = filter([1 -0.9378], 1 ,speechAll);%预加重
vs = vadsohn(speechAll,fs);%VAD去静音
speech = speechAll(vs==1);
mfcc_19 = mfcc(speech, fs, 'My', J, J, n, n/20);

%矢量量化
tStart = tic;%start a timer
mfcc_19_7b = codeBookTrain(mfcc_19, 7);
mfcc_19_8b = codeBookTrain(mfcc_19, 8);
mfcc_19_9b = codeBookTrain(mfcc_19, 9);
toc(tStart);%

save('mfcc_19_cb.mat','mfcc_19_7b','mfcc_19_8b','mfcc_19_9b');
