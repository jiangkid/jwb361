function [ codeBook ] = codeBookInit( trainSignal, codeBookSize, codeBookDim)
%随机选择法，生成初始码本

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
