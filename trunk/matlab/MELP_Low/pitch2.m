%fractal pitch  refine
%Precondition:   sig is the 0~500Hz of the voice signal;int_pitch and r is a two elments
%                array.
%Postcondition:  p and r
%Input:
%        sig(input signal)
%        intp(integer pitch)
%output:
%        p(fractal pitch)
%        r(the corresponding correlation)

function [p,r]=pitch2(sig,intp)
%��һ֡�ļ������أ�

%-5 ~ +5 ��Χ��
low=intp-5;
if low<20
	low=20;
end
up=intp+5;
if up>160
	up=160;
end
p=intpitch(sig,up,low);
[p,r]=FPR(sig,p);%�����������ڹ���