%CONST
global FMCQ_CODEBOOK;
global Wf;
global ham_win;
global stage1 stage2;
ham_win=hamming(200)';    			            %������ϵ��
coeff;
stage;                        					%MSVQ�ļ�����(stage1(128),stage2(64,64,64))
melp_wf;                      					%����Ҷ���ȼ�Ȩ����ϵ��
CODEBOOK_FMCQ1;	              					%����Ҷ�׷����뱾(256)
CODEBOOK_FMCQ2;

%source
%changed by jiang
%path=input('Please input drive[C:,D:...]\path..\path\filename(the type is .wav):\n    ','s');
%s=wavread(path)';        %%%%%%%%%%%%%%%
s=wavread('part2.wav')';
%soundsc(s, 8000);
%modify by jiangwenbin
%[FileName,PathName,FilterIndex] = uigetfile('*.wav','select a wav file');
%if FilterIndex == 0
%    s=wavread('test.wav')';
%else
%    s=wavread(strcat(PathName,FileName))';
%end

s=s*32767;               %%%%%%%%%%%%%%%
FRL=180;             %length of frame
Nframe=fix(length(s)/FRL);  %compute the frame number of the input file
%global sig_in
sig_in(1:FRL*2)=0;          					   %ǰһ֡�ź�
%global cheb_s;
cheb_in_s(1:4)=0;  					               %60Hz�Ľ׳���ѩ���ͨ�˲����ĳ�ʼ״̬
cheb_out_s(1:4)=0;

butter_in_s(1:6)=0;
butter_out_s(1:6)=0;

resid_in_s(1:6)=0;
resid_out_s(1:6)=0;

%global sig_1000
sig_1000(1:FRL*2)=0;

%global melp_bands state_b state_e statet
melp_bands(1:5,1:FRL*2)=0;            		   %ǰһ֡������Ӵ��ź�
global bands_in_s bands_out_s
bands_in_s(1:5,1:6)=0;
bands_out_s(1:5,1:6)=0;
global envelop_in_s envelop_out_s
envelop_in_s(1:4,1:2)=0;
envelop_out_s(1:4,1:2)=0;
%state_b(1:5,1:6)=0;                          %��ͨ�˲�����״̬
%state_e(1:4,1:2)=0;                          %ȫ�������˲����ĳ�ʼ״̬

state_t(1:4,1:6)=0;        				      %����첨�м���̵�״̬
%global melp_envelopes
melp_envelopes(1:4,1:FRL*2)=0;              	%ǰһ�����ĸ������ź�
%global pre_intp
pre_intp=40;                  					%ǰһ֡����������
%pre_intr=0.1;                 					%ǰһ֡������������Ӧ�����ϵ��
frame_num=320;                 					%ȡ�Ď���
%global buffer
pavg_buffer=[50,50,50];                           %���������ǿ�Ļ���ֵ
%global pavg G2p
pavg=50;                                     %ƽ������
G2p=20;                                      %ǰһ֡�ĵ�2����
