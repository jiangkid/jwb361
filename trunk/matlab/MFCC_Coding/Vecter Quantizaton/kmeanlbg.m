function [x,esq,j] = kmeanlbg(d,k)
%modify by jiangwenbin
%KMEANLBG Vector quantisation using the Linde-Buzo-Gray algorithm [X,ESQ,J]=(D,K)
%
%Inputs:
% D contains data vectors (one per row)
% K is number of centres required
%
%Outputs:
% X is output row vectors (K rows)
% ESQ is mean square error
% J indicates which centre each data vector belongs to
%
%  Implements LBG K-means algorithm:
% Linde, Y., A. Buzo, and R. M. Gray,
% "An Algorithm for vector quantiser design,"
% IEEE Trans Communications, vol. 28, pp.84-95, Jan 1980.


nc=size(d,2);
[j,x,esq]=kmeans(d,1);

m=1;
while m<k
   n=min(m,k-m);
   m=m+n;
   e=1e-4*sqrt(esq)*rand(1,nc);
   [j,x,esq]=kmeans(d,m,'start',[x(1:n,:)+e(ones(n,1),:); x(1:n,:)-e(ones(n,1),:); x(n+1:m-n,:)]);
end
