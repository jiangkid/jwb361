function [bands,state_b,envelopes,state_e]=melp_5b(sig_in,state_b,state_e) 
% ������ 5 ��������� �������� � ��������� ��� 2-5 ����� 
% ������� ����������: 
%   sig_in  - ������� ������ 
%   state_b - �������� ��������� ��������� ������� 
%   state_e - �������� ��������� �������� ��������� 
% �������� ����������:
%   bands     - ��������� ������� 
%   state_b   - �������� ��������� ��������� ������� 
%   envelopes - ��������� ��������� ��������
%   state_e   - �������� ��������� �������� ���������

global butt_bp_num butt_bp_den 
global smooth_num smooth_den 

for i=1:5  % ���������� � ������ �� 5 �����
    [bands(i,:),state_b(i,:)]=filter(butt_bp_num(i,:),butt_bp_den(i,:),...
        sig_in,state_b(i,:)); 
end 
temp1=abs(bands(2:5,:)); % ���������� �������� ��������� (2-5) ��������
for i=1:4 
    [envelopes(i,:),state_e(i,:)]=filter(smooth_num(1,:),...
        smooth_den(1,:),temp1(i,:),state_e(i,:)); % ������������ ������
end