function k=d_k1(p) 
% ������ ������� ������������ ���������
% ������� ���������:
%   p - ������������ ��������� ������������
% �������� ��������:
%   k - ������ ����������� ���������

k=-p(10); 
for n=1:9 
    j=11-n; 
    for i=1:j-1 
        pp(i)=(p(i)-k*p(j-i))/(1-k^2);
    end
    p=pp;
    k=-p(j-1); 
end