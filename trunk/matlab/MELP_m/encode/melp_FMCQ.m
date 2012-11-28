function f=melp_FMCQ(mag,Wf) 
% ��������� ������������ �������� �����-�������
% ������� ����������:
%   mag - ��������� �����-�������
%   Wf  - ���� ��� ��������� ���������� �������� �����
% �������� ����������:
%   f   - ������ � �� �������� �����-�������

global FMCQ_CODEBOOK; 

temp=1000; 
for n=1:256 
    u=FMCQ_CODEBOOK(n,1:10)-mag; 
    rms=Wf*(u.*u)'; 
    if rms<temp 
        temp=rms; 
        f=n; 
    end 
end