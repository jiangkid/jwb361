function [ codeBook ] = CodeBookInit( trainSignal, codeBookSize, codeBookDim)
%CODEBOOKINIT Summary of this function goes here
%   Detailed explanation goes here
[m,n] = size(trainSignal);         % 判断输入量的大小
if(n ~= codeBookDim)
    error('trainSignal colums ~= codeBookDim ');
end
codeBook = zeros(codeBookSize,codeBookDim);

%random select codeBook from trainSignal
randomIdx = fix(n*rand(1,codeBookSize)+1);
for idx = 1:codeBookSize
    codeBook(idx,:) = trainSignal(randomIdx(idx),:);
end
end
