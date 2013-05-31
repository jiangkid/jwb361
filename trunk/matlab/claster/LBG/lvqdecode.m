

function y=lvqdecode(x,v)

xorig=x;
x=double(x);
nx=size(x,1);
ny=size(x,2);
s=sqrt(size(v,2));
c=size(v,1);

%y=cell(size(x,1),1);

%y(i,:)=v(index(i),:);
%if(s==4)
%y{i}=[v(index(i),1:s:s*s);v(index(i),2:s:s*s);v(index(i),3:s:s*s);v(index(i),4:s:s*s)];
%elseif(s==2)
 %   y{i}=[v(index(i),1:s:s*s);v(index(i),2:s:s*s)];
 %end

%clear temp;
%end

t=v(x(:),:)';
%--------change structure of the y---------------------------
%y1=reshape(temp,nx*s,ny*s);

y=col2im(t,[s s],[nx*s ny*s],'distinct');

   
   %------------------------------------------------------------