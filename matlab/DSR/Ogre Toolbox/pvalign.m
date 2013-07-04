function Xi = pvalign(X,S,hop)

if nargin < 3, %assuming win = nfft and overlap 2
    hop = size(X,1)-1;
end

t = linspace(1,size(X,2),size(S,2));
Xi = pvinterp(X,t,hop);