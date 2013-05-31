
% function for finding MSE and PSNR
function p=psnr(x,xc,g)
x=double(x);
xc=double(xc);
t=(x-xc).^2;
disp('s');
s=sum(sum(t));
disp(s);
%p=g*g*(size(x,1)*size(x,2))/(s);
n=size(x,1)*size(x,2);

disp('p');
p=(g*g)/(s/n);
p=10*log10(p);
disp(p);
 