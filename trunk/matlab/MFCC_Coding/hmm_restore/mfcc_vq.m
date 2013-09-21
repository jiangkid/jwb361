clear;
addpath('f:\matlab\common\voicebox');
w = 'Md';
nc = 12;
n = 200;
inc = 10;

peopleNum = 8; %8人用于训练
chineseNum = 9; %训练中文数字1~9
speechAll = [];
%读取所有训练语音
for numIdx = 1:chineseNum
    for peopleIdx = 1:peopleNum
        fileName = sprintf('./corpus/female%d/%d.wav',peopleIdx, numIdx);
        [inSpeech, fs] = audioread(fileName);
        speechAll = [speechAll;inSpeech];
    end
end
%读取所有测试语音
test_chinese = char('female10','female11','male1','child1');
for i = 1:4
    for numIdx = 1:chineseNum
        fileName = sprintf('./corpus/%s/%d.wav',deblank(test_chinese(i,:)), numIdx);
        [inSpeech, fs] = audioread(fileName);
        speechAll = [speechAll;inSpeech];
    end
end

p=floor(3*log(fs));
%提取MFCC参数
speechAll = filter([1 -0.9378], 1 ,speechAll);%预加重
vs = vadsohn(speechAll,fs);%VAD去静音
speech = speechAll(vs==1);
mfcc_delta = melcepst(inSpeech,fs,w,nc,p,n,inc);
%矢量量化
tStart = tic;%start a timer
mfcc_delta_6b = codeBookTrain(mfcc_delta, 6, 1e-10);
mfcc_delta_7b = codeBookTrain(mfcc_delta, 7, 1e-10);
mfcc_delta_8b = codeBookTrain(mfcc_delta, 8, 1e-10);
mfcc_delta_9b = codeBookTrain(mfcc_delta, 9, 1e-10);
toc(tStart);%

save('mfcc_delta_cb.mat','mfcc_delta_6b','mfcc_delta_7b','mfcc_delta_8b','mfcc_delta_9b');
