function [e, T]=d_mix(fm, T, jt, vp, factor)
%fm �вT �������ڣ�jt�������ӣ�vp ��ͨ�����о�
%modify by jiangwenbin
global melp_firs;
global noise_FIR_pre;
global pluse_FIR_pre;
global state_pluse;
global state_noise;
%����jitter��������
T=T*(1+jt*0.5*(rand-0.5));
T=round(T);
%�޶�����
if T>160
    T=160;
elseif T<20
    T=20;
end

%���㼤���źŲ�ѭ����λ
m(1:10)=fm;
m(T-10:T-1)=fliplr(fm);
if T>21
    m(11:T-11)=1;
end
m=[0,m];
pluse=real(ifft(m));
pluse=[pluse(T-9:T),pluse(1:T-10)];%ѭ����λ
%Scale
pluse=pluse*sqrt(T)*1000;%�Ƿ�Ҫ��lpc_gain?
noise=(rand(1,T)-0.5)*3464;%�Ƿ�Ҫ��lpc_gain?

%�˲���ϵ��������ֵ
factor = sqrt(factor);
pluse_FIR(1:31, 1:5) = 0;
noise_FIR(1:31, 1:5) = 0;
for i=1:5
    if vp(i)>0.5 %����������
        pluse_FIR(:,i) = factor*(melp_firs(:,i)-pluse_FIR_pre(:,i)) + pluse_FIR_pre(:,i);
    else %����������
        noise_FIR(:,i) = factor*(melp_firs(:,i)-noise_FIR_pre(:,i)) + noise_FIR_pre(:,i);
    end
end
pluse_FIR_pre = pluse_FIR;
noise_FIR_pre = noise_FIR;
%pluse noise�ֱ�����˲�
pluse_sig(1:T)=0;
noise_sig(1:T)=0;
buffer_pluse = [state_pluse, pluse];
buffer_noise = [state_noise, noise];
for i = 1 :T
    pluse_sig(i) = sum(buffer_pluse(i:30+i)*pluse_FIR);
    noise_sig(i) = sum(buffer_noise(i:30+i)*noise_FIR);
end
if T < 30
    state_pluse(1:30) = 0;
    state_noise(1:30) = 0;
    state_pluse(30-T+1:30) = pluse_sig;
    state_noise(30-T+1:30) = noise_sig;
else
    state_pluse = pluse_sig(end-30+1 : end);
    state_noise = noise_sig(end-30+1 : end);
end
e = pluse_sig + noise_sig;

%ep=[state_pul,ep];
%en=[state_noi,en];
%for i=1:T
%    e(i)=sum(ep(i:30+i)*pfirs+en(i:30+i)*efirs);
%end
end