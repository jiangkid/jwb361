function [u, w, nw]=findweight(diff,win,c,fno,alpha,beta,gamma)
%        diff is the ||x-v||^2
%        win is the index of winning prototype
%         c->no.of prototypes
% alpha=1;
% beta=1;
% gamma=.5;
diff=diff+.1;
z=diff(win)./diff; 
z(win)=0;
if(fno==1)
    
u=z./(1+alpha.*z);
u(win)=1;
w=1./(1+alpha.*z).^2;
nw=alpha.*u.^2;
elseif(fno==2)
    e=exp(-beta.*z);
    u=z.*(e);
w=(1-beta.*z).*e;
nw=beta.*u.^2.*e;
else
    u=z.*(1-gamma.*z);
w=(1-2*gamma.*z);
nw=gamma.*z.^2;
end


u=u';
nw=nw';
w=w';

w(win)=0;
n(win)=0;