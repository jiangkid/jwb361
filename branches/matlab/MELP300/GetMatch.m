function [value, index] = GetMatch(A, B, w, n)
%在B中找A最匹配的向量, w为权值,n为返回的个数
[rowA, columnA] = size(A);
[rowB, columnB] = size(B);
if rowA ~= 1 || rowB < 2 || columnA ~= columnB
    error('A B size error');
end
switch nargin
    case 2
        distance = pdist2(A, B);
        [value, index] = min(distance);
    case 3
        if size(w, 2) ~= columnA
            error('w size error');            
        end
        distance = zeros(rowB,1);
        for j=1:rowB
            distance(j) = sqrt(sum(((A-B(j,:)).*w).^2));
        end
        [value, index] = min(distance);
    case 4
        error('not implement');
    otherwise
        error('nargin err');
end
end