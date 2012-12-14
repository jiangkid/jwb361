function [ areaC ] = areaCombine( areaA, areaB )
%区域合并 areaA, areaB --> areaC
areaC = [];
if isempty(areaA) && isempty(areaB)    
    return;
end
if isempty(areaA) 
    areaC = areaB;
    return;
end
if isempty(areaB) 
    areaC = areaA;
    return;
end
%areaA areaB areaC 每行(两个数)代表一个数据区域
if(size(areaA,2) ~= 2) || (size(areaB,2) ~= 2)
    error('areaA or areaB columns error');
end
areaC = [];
for i = 1:size(areaA, 1)
    A = areaA(i,:);
    flag = 0;
    sizeB = size(areaB, 1);
    for j = 1:sizeB
        B = areaB(j,:);
        if(B(1)<A(1) && A(1)<B(2))||(B(1)<A(2) && A(2)<B(2))
            areaC(i, 1) = min([A(1),A(2),B(1),B(2)]);
            areaC(i, 2) = max([A(1),A(2),B(1),B(2)]);
            areaB(j,:) = [];
            flag = 1;
            break;
        end
    end
    if 0 == flag %本次没有A B合并
        areaC(i,:) = A;        
    end
end
areaC = [areaC;areaB];

end

