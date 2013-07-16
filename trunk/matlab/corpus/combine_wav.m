close all;
clear all;
%cd('F:\语音库\timit 语音库');
cd('F:\语音库\TIMIT完整版\train\dr1');
allDir = dir;
[dirNum,] = size(allDir);
fileCount = 0;
allFileContent  =[];
for idx= 3:dirNum                           % 从3开始。前两个属于系统内部。
    if allDir(idx).isdir == 1 %文件夹
        cd(allDir(idx).name);
        allFiles = dir;
        [fileNum,] = size(allFiles);
        for k= 3:fileNum
            if strfind(allFiles(k).name, '.wav')
                % allFiles(k).name
                fileID = fopen(allFiles(k).name);
                A = fread(fileID, inf, 'short');
                fclose(fileID);
                allFileContent = [allFileContent;A(513:end)./32768];%SPHERE 文件头1024字节
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
