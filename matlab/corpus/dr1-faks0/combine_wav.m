clear all;
fs = 16000;
allFileContent = [];
fileCount = 0;
allFiles = dir;
[fileNum,] = size(allFiles);
for k= 3:fileNum
    if strfind(allFiles(k).name, '.wav')
        fileID = fopen(allFiles(k).name);
        A = fread(fileID, inf, 'short');
        fclose(fileID);
        allFileContent = [allFileContent;A(513:end)./32768];%SPHERE 文件头1024字节
        fileCount = fileCount+1;
    end
end
disp(fileCount);
wavwrite(allFileContent, fs, './wav_16k/dr1-faks0.wav');
