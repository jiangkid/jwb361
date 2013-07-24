%SPHERE 文件转换为wav文件
clear all;
fs = 16000;
allFiles = dir;
[fileNum,] = size(allFiles);
for k= 3:fileNum
    if strfind(allFiles(k).name, '.wav')
        % allFiles(k).name
        fileID = fopen(allFiles(k).name);
        A = fread(fileID, inf, 'short');
        fclose(fileID);
        newFileName = ['./wav_16k/', allFiles(k).name,];
        wavwrite(A(513:end)./32768, fs, newFileName);        
    end
end
