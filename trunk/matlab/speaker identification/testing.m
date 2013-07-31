clear;
load('all_GMM.mat');%all_GMM
J = 24;
n = 128;
dir_list = char('fdaw0', 'fecd0', 'fjsp0', 'fmem0', 'fsjk1', 'fcjf0', 'fdml0', 'fetb0', 'fkfb0', 'fsah0');
ok_count = 0;
for dirIdx = 1:length(dir_list)
    curr_path = ['./corpus/', dir_list(dirIdx,:), '/'];
    allFiles = dir(curr_path);
    [fileNum,col] = size(allFiles);
    for k= 3:fileNum
        file = [curr_path, allFiles(k).name];
        [inSpeech,fs] = wavread(file);
        
        %提取MFCC参数
        inSpeech = filter([1 -0.9378], 1 ,inSpeech);%预加重
        vs = vadsohn(inSpeech,fs);%VAD去静音
        speech = inSpeech(vs==1);
        mfcc_data = mfcc(speech, fs, 'My', J, J, n, n);%overlap 0%
        y = zeros(length(mfcc_data), length(all_GMM));
        % p = zeros(length(mfcc_data), length(all_GMM));
        for i = 1:length(all_GMM)
            y(:,i) = pdf(all_GMM(i).obj_gmm,mfcc_data);
        end
        sum_log_y = sum(log(y))
        [prob, max_idx] = max(sum_log_y);
        [prob, min_idx] = min(sum_log_y);
        fprintf('[%s] max:%s, min:%s \n', dir_list(dirIdx,:), all_GMM(max_idx).fileName, all_GMM(min_idx).fileName);
        if(dir_list(dirIdx,:) == all_GMM(max_idx).fileName)
            ok_count = ok_count+1;
        end
    end
end
fprintf('rate: %.2f\n', ok_count/20);