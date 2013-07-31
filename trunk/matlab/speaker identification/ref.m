% 初始化
GMM_com = 16;

training_count = 6;	% 训练数据集类别数，有几个人就是几类
testing_count = 36;	% 测试数据个数，至少录36段录音
wavdir = '/tmp/voice_test';	% 这是放数据的文件路径，如果提示文件无法打开，改用绝对路径

mu_train = zeros(training_count, 12, GMM_com);
sigma_train = zeros(training_count, 12, GMM_com);
c_train = zeros(training_count, GMM_com, 1);

% 训练过程
% 在<wavdir>/training/下为每个人建立一个文件夹，名称按数字顺序。
% 每个文件夹里是对应那个人的两段训练数据，分别命名为1.wav和2.wav。
for n = 1 : training_count
    twavdir = [wavdir, '/training/' num2str(n), '/1.wav'];
    twavdir2 = [wavdir, '/training/' num2str(n), '/2.wav'];
    [train_data1, fs] = readwav(twavdir);
    train_data1=filter([1 -0.9378],1,train_data1);%预加重
    train_feature1 = melcepst(train_data1, fs);	% 提取MFCC特征
    [train_data2, fs] = readwav(twavdir2);
    train_data2=filter([1 -0.9378],1,train_data2);%预加重
    train_feature2 = melcepst(train_data2, fs);
    % 训练高斯混合模型(Gauss Mixture Model)，返回值是GMM模型的3个参数
    [mu_train1, sigma_train1, c_train1] = gmm_estimate([train_feature1', train_feature2'], GMM_com);
    mu_train(n, : , : ) = mu_train1;
    sigma_train(n, : , : ) = sigma_train1;
    c_train(n, : , : ) = c_train1;
end

score = zeros(testing_count, training_count);

% 测试过程
for o = 1 : testing_count
    newlabel = [wavdir, '/testing/', num2str(o), '.wav'];
    [test_data, fs] = readwav(newlabel);
    test_data=filter([1 -0.9378],1,test_data);%预加重
    test_feature = melcepst(test_data, fs);	% 提特征
    for n = 1 : training_count
        sigma_train1 = zeros(12, GMM_com);
        mu_train1 = zeros(12, GMM_com);
        c_train1 = zeros(GMM_com, 1);
        for t = 1 : 12
            for k = 1 : GMM_com
                sigma_train1(t, k) = sigma_train(n, t, k);
                mu_train1(t, k) = mu_train(n, t, k);
            end
        end
        for t = 1 : GMM_com
            c_train1(t, 1) = c_train(n, t, 1);
        end
        % 把第o个测试数据的特征与第n个GMM模型做匹配，计算得分
        [lYM, lY] = lmultigauss(test_feature', mu_train1, sigma_train1, c_train1);
        [score(o, n)] = mean(lY);
    end
end

for h = 1 : testing_count
    [~, i] = max(score(h, : ));
    fprintf('results[%d]: %3d\n', h, i);
end