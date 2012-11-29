function [e, T]=d_mix(fm, T, jt, vp, factor)
%fm 残差，T 基音周期，jt抖动因子，vp 带通清浊判决
%modify by jiangwenbin
global melp_firs;
global noise_FIR_pre;
global pluse_FIR_pre;
global state_pluse;
global state_noise;
%加入jitter计算周期
T=T*(1+jt*0.5*(rand-0.5));
T=round(T);
%限定周期
if T>160
    T=160;
elseif T<20
    T=20;
end

%计算激励信号并循环移位
m(1:10)=fm;
m(T-10:T-1)=fliplr(fm);
if T>21
    m(11:T-11)=1;
end
m=[0,m];
pluse=real(ifft(m));
pluse=[pluse(T-9:T),pluse(1:T-10)];%循环移位
%Scale
pluse=pluse*sqrt(T)*1000;%是否要乘lpc_gain?
noise=(rand(1,T)-0.5)*3464;%是否要乘lpc_gain?

%滤波器系数，并插值
factor = sqrt(factor);
pluse_FIR(1:31, 1:5) = 0;
noise_FIR(1:31, 1:5) = 0;
for i=1:5
    if vp(i)>0.5 %浊音，脉冲
        pluse_FIR(:,i) = factor*(melp_firs(:,i)-pluse_FIR_pre(:,i)) + pluse_FIR_pre(:,i);
    else %清音，噪声
        noise_FIR(:,i) = factor*(melp_firs(:,i)-noise_FIR_pre(:,i)) + noise_FIR_pre(:,i);
    end
end
pluse_FIR_pre = pluse_FIR;
noise_FIR_pre = noise_FIR;
%pluse noise分别进行滤波
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