clear;
J = 24;
n = 128;
all_GMM = struct([]);
K = 16;
options = statset('Display', 'final');
fileList = char('fdaw0', 'fecd0', 'fjsp0', 'fmem0', 'fsjk1', 'fcjf0', 'fdml0', 'fetb0', 'fkfb0', 'fsah0');
fileNum = length(fileList);

for fileIdx = 1:fileNum
    fileName =[ './corpus/',fileList(fileIdx,:), '_8k.wav'];
    [inSpeech, fs, bits] = wavread(fileName);  
    all_GMM(fileIdx).fileName = fileList(fileIdx,:);
    %提取MFCC参数    
	inSpeech = filter([1 -0.9378], 1 ,inSpeech);%预加重
    vs = vadsohn(inSpeech,fs);%VAD去静音
    speech = inSpeech(vs==1);
    all_GMM(fileIdx).data_mfcc = mfcc(speech, fs, 'My', J, J, n, n);%overlap 0%
    %训练模型
    all_GMM(fileIdx).obj_gmm = gmdistribution.fit(all_GMM(fileIdx).data_mfcc, K, 'Options', options, 'CovType', 'diagonal', 'Regularize', 1e-15);
end
save('all_GMM.mat','all_GMM');
