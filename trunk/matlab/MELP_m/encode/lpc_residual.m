function exc=lpc_residual(lpcs,sig_in) 
% ����������� ������� ������������
% ������� ����������: 
%   lpcs   - ������������ �� 
%   sig_in - ������� ������ 
% �������� ����������:  
%   exc    - ������ ������� ������������ 

exc=filter([1,lpcs],1,sig_in);
exc=exc(11:end);