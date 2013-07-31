clear;
close all;
% testFile = './corpus/fdml0/sx69_8k.wav';
testFile = './corpus/fdml0_8k.wav';
pp.pr = 0.7;
[inSpeech,fs] = wavread(testFile);
vs = vadsohn(inSpeech,fs);
speech = inSpeech(vs==1);
fprintf('%d --> %d\n', length(inSpeech),length(speech));
return;
speech = [];
for idx = 1:length(vs)
    if(vs(idx,3) == 1)
        speech = [speech;inSpeech(vs(idx,1):vs(idx,2))];
    end
end
vs2 = vadsohn(speech,fs,'n');

figure(1);
vadsohn(inSpeech,fs,'p',pp);
figure(2);
vadsohn(speech,fs);
