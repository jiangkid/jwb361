% ������������� ���������� � ��������
global FMCQ_CODEBOOK; 
global Wf; 
global stage1 stage2;

coeff; 
stage;  
codebook_fmcq1;  
codebook_fmcq2; 

% �������� �������� ������� 
[file, path]=uigetfile('*.wav','Open Speech Signal');
S=strcat(path,file);
s=wavread(S)'; 
s=s*32767; 
FRL=180; % ����� �����
Nframe=fix(length(s)/FRL); % ����� ������ �� ������� ������� 
% ��������� �������
sig_in(1:FRL*2)=0;             % ������� ������
sig_1000(1:FRL*2)=0;           % ������ �� ����� ��� (1000 ��)
melp_bands(1:5,1:FRL*2)=0;     % ��������� �������
% ��������� ��������� 
cheb_s(1:4)=0; 
butter_s(1:6)=0; 
state_b(1:5,1:6)=0;
state_e(1:4,1:2)=0; 
state_t(1:4,1:6)=0;
state_syn(1:10)=0;  % !!!!!!!!!!!!!!
melp_envelopes(1:4,1:FRL*2)=0; % ��������� ��������� ��������
pre_intp=40; 
frame_num=320;
buffer=[50,50,50]; % ����� ���������� ������� ��
pavg=50;    % �������� �� ��� ������ ������ ���������� �������� ��, 
            % ������������ �� �������� ������� � ������� ������� 
G2p=20;     % �������� �������� ��� ����������� �����