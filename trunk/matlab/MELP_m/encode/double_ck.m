function [pc,cor_pc]=double_ck(sig_in,p,Dth)
% ����������� �� � ��������� ���������
% ������� ���������: 
%   sig_in - ������� ������ 
%   p      - ������� �������� �� 
%   Dth    - ��������� �������� 
% �������� ���������: 
%   pc     - �������� �� (� ������� ���������) 
%   cor_pc - ��������������� ���������� 

pmin=20;                            % ����������� �������� �� 
[pc,cor_pc]=fpr(sig_in,round(p));   % ��������� �������� �������� ��  
for n=1:7                           % ����� ������� ��  
    k=9-n;                          % �������� ��������
    temp_pit=round(pc/k);           % ��������� �������� ��
    if temp_pit>=pmin 
        [temp_pit,temp_cor]=fpr(sig_in,temp_pit); 
                                    % ��������� �������� �������� ��
        if temp_pit<30 
            temp_cor=double_ver(sig_in,temp_pit,temp_cor); 
        end                         % �������� ������� �� 
        if temp_cor>Dth*cor_pc
            [pc,cor_pc]=fpr(sig_in,round(temp_pit)); 
                                    % ��������� �������� �������� ��
            break; 
        end
    end
end
if pc<30 
    cor_pc=double_ver(sig_in,pc,cor_pc); % �������� ������� �� 
end