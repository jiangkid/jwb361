function v=lvq(x,para,p)
%initialize
etaz=para.etaz;
N=para.it;
i=0;
n=size(x,1);
c=para.clusters;
fno=para.fno;
if(p==0)
s=para.s(1);
else
    s=para.s(p);
end
%------------------------

%initialize codebook

 v=rand(c,s*s);
 v=v*255;
imwrite(uint8(v),'codebook.bmp');
v=imread('codebook.bmp');
v=double(v);
%------------------------

N1=1;
if(para.cit~=0)
    N1=para.cit;
    N=10;%+para.step;
end

 for i=N1:N
     eta=etaz*(1-i/N);
     
    for j=1:n
     %find winning prototype by euclidean
     %mini=(norm(x(j,:)-v(1,:)));
       %dif(1)=mini;
       %win=1;
        %for k=2:c
          % dif(k)=(norm(x(j,:)-v(k,:)));
           %   if(dif(k)<mini)
           %   mini=dif(k);
           %   win=k;
           %end
           
        
           %end
         
           mini=(((repmat(x(j,:),[c 1])-v(:,:)).^2))';
           
           %--------------------
           %t=find(mini==0);
           %mini(t(1:end))=.01;
           %t=find(mini==inf);
           %mini(t(1:end))=10000;
           %---------------------
if(not (size(x,2)==1))
    mini=(sum(mini))';
end
mini=sqrt(mini);

m=min(mini);
temp=find(mini==m);
if(length(temp)==1)
    win=temp;
else
win=temp(1);
end
dif=mini;
     %-------------------------------------
     
     %calculate u,w,n
     %---------------------
     [u ,w ,nw]=findweight(dif,win,c,fno,para.alpha,para.beta,para.gama);
     %--,---------------------
     
     %update prototype
     
     vnew=v(win,:)+eta*(x(j,:)-v(win,:)).*(1+sum(w));
      for k=1:c
          v(k,:) = v(k,:) + eta.*(x(j,:)-v(k,:)).*nw(k);
      end
     v(win,:)=vnew;
     
   clear temp;  
 end
 
end
v=v(:,1:s*s);


            