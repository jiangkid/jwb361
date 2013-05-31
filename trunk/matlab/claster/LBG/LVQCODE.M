function y=lvqcode(x,v)
v=double(v);
xorig=x;
nx=size(x,1);
ny=size(x,2);
x=double(x);
s=sqrt(size(v,2));
%take blockwise
%--------------------------------
x1=im2col(x,[s s],'distinct');
x=x1';
%---------------------------------

c=size(v,1);
n=size(x,1);

%-------------find nearest code--------------------
for i=1:n
mini=(((repmat(x(i,:),[c 1])-v(:,:)).^2))';
if(not (size(x,2)==1))
    mini=(sum(mini))';
end
mini=sqrt(mini);

m=min(mini);
temp=find(mini==m);
if(length(temp)==1)
    index(i)=temp;
else
index(i)=temp(1);
end
clear temp;
end
%------------------------------------------------------
%y=col2im(index,[1 1],[nx/s ny/s],'distinct');
y=reshape(index,nx/s,ny/s);