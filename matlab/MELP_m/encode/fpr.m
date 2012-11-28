function [fp,fr]=fpr(sig,T) 
% ��������� �������� �������� ��  
% �����������: ������� ������ sig - 240 ��������: 180 �������� ��������
                                    % ����� � 60 �������� ���������� �����
% ������� ����������: 
%   sig - ������� ������ 
%   T   - ������� ������������� �������� �� 
% Output: 
%   fp  - ������� �������� �� 
%   fr  - ��������������� ���������� 

k=fix(T/2); 
% �������������� 
c0_tm1=sig(100-k:259-k)*sig(100-k+T-1:259-k+T-1)'; % c(0,t-1) 
c0_t1=sig(100-k:259-k)*sig(100-k+T+1:259-k+T+1)';  % c(0,t+1) 
c0_t=sig(100-k:259-k)*sig(100-k+T:259-k+T)';       % c(0,t) 
if c0_tm1>c0_t1 %������ ��������� fp 
    c0_t1=c0_t; 
    c0_t=c0_tm1; 
    T=T-1; 
end 
ct_t=sig(100-k+T:259-k+T)*sig(100-k+T:259-k+T)';            % c(t,t) 
c0_0=sig(100-k:259-k)*sig(100-k:259-k)';                    % c(0,0) 
ct_t1=sig(100-k+T:259-k+T)*sig(100-k+T+1:259-k+T+1)';       % c(t,t+1) 
ct1_t1=sig(100-k+T+1:259-k+T+1)*sig(100-k+T+1:259-k+T+1)';  % c(t+1,t+1) 

%�������� ���������� 
den=c0_t1*(ct_t-ct_t1)+c0_t*(ct1_t1-ct_t1); %����������� delta
if abs(den)>0.01 
    delta=(c0_t1*ct_t-c0_t*ct_t1)/den; % ������ ��������� ����������
else
    delta=0.5;
end 
% �������� ��������� ������� ��� ��������� ����������
if delta<-1 
    delta=-1; 
end 
if delta>2 
    delta=2; 
end 

fp=T+delta; % ���������� �������� � �������������� �������� ��
% ������ ��������������� ����������
den=c0_0*(ct_t*(1-delta)^2+2*delta*(1-delta)*ct_t1+delta^2*ct1_t1); 
den=sqrt(den); 
if den>0.01 
    fr=((1-delta)*c0_t+delta*c0_t1)/den; 
else
    fr=0;
end 
% �������� ��������� ������� ��� �������� ��
if fp<20 
    fp=20; 
end 
if fp>160 
    fp=160; 
end