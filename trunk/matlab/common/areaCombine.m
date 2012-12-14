function [ areaC ] = areaCombine( areaA, areaB )
%����ϲ� areaA, areaB --> areaC
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
%areaA areaB areaC ÿ��(������)����һ����������
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
    if 0 == flag %����û��A B�ϲ�
        areaC(i,:) = A;        
    end
end
areaC = [areaC;areaB];

end

