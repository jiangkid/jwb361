close all;
clear all;
%cd('F:\������\timit ������');
cd('F:\������\TIMIT������\train\dr1');
allDir = dir;
[dirNum,] = size(allDir);
fileCount = 0;
allFileContent  =[];
for idx= 3:dirNum                           % ��3��ʼ��ǰ��������ϵͳ�ڲ���
    if allDir(idx).isdir == 1 %�ļ���
        cd(allDir(idx).name);
        allFiles = dir;
        [fileNum,] = size(allFiles);
        for k= 3:fileNum
            if strfind(allFiles(k).name, '.wav')
                % allFiles(k).name
                fileID = fopen(allFiles(k).name);
                A = fread(fileID, inf, 'short');
                fclose(fileID);
                allFileContent = [allFileContent;A(513:end)./32768];%SPHERE �ļ�ͷ1024�ֽ�
                % [content, fs] = wavread(allFiles(k).name);
                %   allFileContent = [allFileContent; content];
                fileCount = fileCount+1;
            end
        end
        cd('..');
    end
end
disp(fileCount);
cd('E:\temp');
wavwrite(allFileContent, fs, 'dr1.wav');
