%CONST
global FMCQ_CODEBOOK;
global Wf;
global ham_win;
global stage1 stage2;
ham_win=hamming(200)';    			            %汉明窗系数
coeff;
stage;                        					%MSVQ四级本码(stage1(128),stage2(64,64,64))
melp_wf;                      					%傅立叶幅度加权距离系数
CODEBOOK_FMCQ1;	              					%傅立叶谱幅度码本(256)
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
sig_in(1:FRL*2)=0;          					   %前一帧信号
%global cheb_s;
cheb_in_s(1:4)=0;  					               %60Hz四阶车比雪夫高通滤波器的初始状态
cheb_out_s(1:4)=0;

butter_in_s(1:6)=0;
butter_out_s(1:6)=0;

resid_in_s(1:6)=0;
resid_out_s(1:6)=0;

%global sig_1000
sig_1000(1:FRL*2)=0;

%global melp_bands state_b state_e statet
melp_bands(1:5,1:FRL*2)=0;            		   %前一帧的五个子带信号
global bands_in_s bands_out_s
bands_in_s(1:5,1:6)=0;
bands_out_s(1:5,1:6)=0;
global envelop_in_s envelop_out_s
envelop_in_s(1:4,1:2)=0;
envelop_out_s(1:4,1:2)=0;
%state_b(1:5,1:6)=0;                          %带通滤波器的状态
%state_e(1:4,1:2)=0;                          %全波整形滤波器的初始状态

state_t(1:4,1:6)=0;        				      %包络检波中间过程的状态
%global melp_envelopes
melp_envelopes(1:4,1:FRL*2)=0;              	%前一幀的四个包络信号
%global pre_intp
pre_intp=40;                  					%前一帧的整数基音
%pre_intr=0.1;                 					%前一帧的整数基音对应的相关系数
frame_num=320;                 					%取的幀数
%global buffer
pavg_buffer=[50,50,50];                           %最近三个最强的基音值
%global pavg G2p
pavg=50;                                     %平均基音
G2p=20;                                      %前一帧的第2增益
