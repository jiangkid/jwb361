function [y]=testlvq1(x)
tic; %start watch

global para;

s=para.s(1);

x=double(x);

%preprocess---------------------
rn=size(x,1);
cn=size(x,2);
rem1=mod(rn, s);
rem2= mod(cn,s);
rn=rn-rem1;
cn=cn-rem2;
x=x(1:rn,1:cn);
%--------------------------------

x1=im2col(x,[s s],'distinct');
x1=x1';


%compress and decompress
for i=1:1
    if(i==1)
    v=imread('codebook.bmp');
    s1='Reconstructed';
    else
%         s1='Reconstructed- proposed';
%     v=imread('codebookp.bmp');
    end 
    
    c=size(v,1);

    
yc=lvqcode(x,v); 
yp=lvqdecode(yc,v);
%------------------------
if(i==1)
    y=yp;
end
y=uint8(yp);


end

toc; % stop watch
