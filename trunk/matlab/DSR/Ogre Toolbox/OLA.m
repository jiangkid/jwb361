function a = OLA(amat,overlap,olanorm)
% a = OLA(amat,overlap,norm)
% Ovelap add of sample matrix to produce a sample vector
% amat - matrix of samples (overlapping)
% overalp - overlap factor
% olanorm - normalization factor (in case windows sum up to more then 1)

if nargin < 2,
    overlap = 2;
end
if nargin < 3,
    olanorm = 1;
end

[M N] = size(amat);
hop = M/overlap;

a = zeros (1,N*(hop-1) + M);
win_pos = [1: hop: length(a) - M];

w2 = hanning(M,'periodic'); %second smoothing window
%w2 = ones(N,1);

for i=1:length(win_pos)
   a(win_pos(i):win_pos(i)+M-1) = a(win_pos(i):win_pos(i)+M-1) + amat(:,i)'.*w2';
   %a(win_pos(i):win_pos(i)+M-1) = a(win_pos(i):win_pos(i)+M-1) + amat(:,i)';
end

a = real(a)/overlap*2/olanorm;
