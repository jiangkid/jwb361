function [X2,instfreq] = pvinterp(X, t, hop)
% [X2,instfreq] = pvinterp(X, t, hop)
% interpolate STFT matrix X according to new analysis frame indices
% t starts at 1 and ends at the last column of X

[rows,cols] = size(X);


N = rows;
Nfft = (N-1)*2;

if nargin < 3,
    hop = N-1;
end

% Empty output array
X2 = zeros(rows, length(t));
instfreq = X2;

% Expected phase advance in each bin
dp = zeros(N,1);
dp(2:rows) = 2*pi*hop*(1:N-1)./Nfft;

% Phase accumulator
% Preset to phase of first frame for perfect reconstruction
% in case of 1:1 time scaling
ph = angle(X(:,1));
X = [X X(:,end)];

k = 1;
for tt = t,
  % Take two columns of X
  X1 = X(:,floor(tt)+[0 1]);
  tf = tt - floor(tt);
  Xmag = (1-tf)*abs(X1(:,1)) + tf*(abs(X1(:,2)));
  
  % calculate phase advance
  da = angle(X1(:,2)) - angle(X1(:,1)) - dp;
  
  % Reduce to -pi:pi range
  da = da - 2 * pi * round(da/(2*pi));
  instfreq(:,k) = (dp + da)/2/pi;
  
  % Write the new column
  X2(:,k) = Xmag .* exp(j*ph);
  
  % Cumulate phase, ready for next frame
  ph = ph + dp + da;
  k = k+1;
end

