function [ B ] = hcat( A )
%HCAT, horizon Concatenate Array
%   Detailed explanation goes here
[row, col] = size(A);
B = zeros(1, row*col);
for idx = 1:row
    B(1,col*(idx-1)+1:col*idx) = A(idx,:);
end
end

