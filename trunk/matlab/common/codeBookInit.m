function [ codeBook ] = codeBookInit( trainSignal, codeBookSize, codeBookDim)
%���ѡ�񷨣����ɳ�ʼ�뱾

[m,n] = size(trainSignal);         % �ж��������Ĵ�С
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
