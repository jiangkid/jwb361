% training vector quantization


function [v]=trainlvq(x,p)
global para;
p=0;
x=imread('rice.tif');
c=para.clusters;
if(p==0)
s=para.s(1);
else
    s=para.s(p)
end
x=double(x);

%preprocess---------------------
rn=size(x,1);
cn=size(x,2);
rem1=mod(rn,s);
rem2= mod(cn,s);
rn=rn-rem1;
cn=cn-rem2;
x=x(1:rn,1:cn);
%--------------------------------

x1=im2col(x,[s s],'distinct');
x1=x1';


v=lvq(x1,para,p);
%vp=lvqproposed(x1,para,p);
if(p==0)
 imwrite(uint8(v),'codebook.bmp');
%imwrite(uint8(vp),'codebookp.bmp');
end

