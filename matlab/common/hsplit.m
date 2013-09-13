function [ B ] = hsplit( A, n)
%HCAT, horizon Concatenate Array
%   Detailed explanation goes here
[row, col] = size(A);
if row~=1
    error('row~=1');
end
if mod(col, n) ~=0
    error('col%n~=0');
end
col_new = col/n;
B = zeros(n, col_new);
for idx = 1:n
    B(idx,:) = A(1,col_new*(idx-1)+1:col_new*idx);
end
end

