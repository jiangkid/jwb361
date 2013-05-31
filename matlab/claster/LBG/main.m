load parameter;

global para


x=imread('rice.tif');

original=x;


% v=rand(256,16);
% imwrite(uint8(v),'codebook.bmp');

[v]=trainlvq(x,0);
compressed=v;

%imwrite(uint8(vp),'codebook.bmp');

[y]=testlvq1(x);

 

[psnrvalue]=psnr(original,y,255);

% error=0;
%   for y=1:240
%      for x=1:291
%         MSE=(((Original(x,y))-(DecompressedImage(x,y)))^2);
%         error=MSE+error;
%     end
%  end
%  MSE=(1/(291*240))*error;    
%  disp('PSNR');
%  PSNR=20*log10(255/sqrt(MSE));
%  disp(PSNR);
%   
figure,imshow(original);
title('Original Image');
 
% figure,imshow(compressed);
% title('compressed Image');

figure,imshow(uint8(y));
title('Decompressed Image');
