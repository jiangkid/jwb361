function [pavg,buffer]=melp_APU(p3,rp3,G2,buffer) 
% ��������� ������
% ������� ����������: 
% p3     - ������������� �������� ��
% rp2    - ��������������� ���������� p3 
% G2     - �������� ��� ������� �������� 
% buffer - ����� �������� �� 
% �������� ����������:  
% pavg   - ������� �������� �� 
% buffer - ����������� ����� 

if (rp3>0.8)&&(G2>30) 
    buffer=[buffer(2:3),p3]; 
else
    buffer=buffer*0.95+2.5;
end 
pavg=median(buffer);