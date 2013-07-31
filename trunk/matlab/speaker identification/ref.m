% ��ʼ��
GMM_com = 16;

training_count = 6;	% ѵ�����ݼ���������м����˾��Ǽ���
testing_count = 36;	% �������ݸ���������¼36��¼��
wavdir = '/tmp/voice_test';	% ���Ƿ����ݵ��ļ�·���������ʾ�ļ��޷��򿪣����þ���·��

mu_train = zeros(training_count, 12, GMM_com);
sigma_train = zeros(training_count, 12, GMM_com);
c_train = zeros(training_count, GMM_com, 1);

% ѵ������
% ��<wavdir>/training/��Ϊÿ���˽���һ���ļ��У����ư�����˳��
% ÿ���ļ������Ƕ�Ӧ�Ǹ��˵�����ѵ�����ݣ��ֱ�����Ϊ1.wav��2.wav��
for n = 1 : training_count
    twavdir = [wavdir, '/training/' num2str(n), '/1.wav'];
    twavdir2 = [wavdir, '/training/' num2str(n), '/2.wav'];
    [train_data1, fs] = readwav(twavdir);
    train_data1=filter([1 -0.9378],1,train_data1);%Ԥ����
    train_feature1 = melcepst(train_data1, fs);	% ��ȡMFCC����
    [train_data2, fs] = readwav(twavdir2);
    train_data2=filter([1 -0.9378],1,train_data2);%Ԥ����
    train_feature2 = melcepst(train_data2, fs);
    % ѵ����˹���ģ��(Gauss Mixture Model)������ֵ��GMMģ�͵�3������
    [mu_train1, sigma_train1, c_train1] = gmm_estimate([train_feature1', train_feature2'], GMM_com);
    mu_train(n, : , : ) = mu_train1;
    sigma_train(n, : , : ) = sigma_train1;
    c_train(n, : , : ) = c_train1;
end

score = zeros(testing_count, training_count);

% ���Թ���
for o = 1 : testing_count
    newlabel = [wavdir, '/testing/', num2str(o), '.wav'];
    [test_data, fs] = readwav(newlabel);
    test_data=filter([1 -0.9378],1,test_data);%Ԥ����
    test_feature = melcepst(test_data, fs);	% ������
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
        % �ѵ�o���������ݵ��������n��GMMģ����ƥ�䣬����÷�
        [lYM, lY] = lmultigauss(test_feature', mu_train1, sigma_train1, c_train1);
        [score(o, n)] = mean(lY);
    end
end

for h = 1 : testing_count
    [~, i] = max(score(h, : ));
    fprintf('results[%d]: %3d\n', h, i);
end