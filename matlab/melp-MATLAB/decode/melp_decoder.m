%C is the struct array which contain the coded data produced by coder.
%function v = melp_decoder(C)
%  C(N)  =  struct('ls', 'QFM', 'pitch', 'G', 'vp', 'jt');
clear all;
%clc;
load('c_data.mat');
d_init;
C = c;
TEMPSIZE = size(C);
FRN = TEMPSIZE(2);
%add by jiangwenbin
unvoiced_count = 0;

global fm2 jt2 vp2;
for i = 1:FRN
    lsf_cur = d_lsf(C(i).ls);%get lsf
    [G1,G2,G2pt,G2p_error] = d_gains(C(i).G,G2pt,G2p_error);
    Gno = noise_est(G1,Gno);% Gno: initial 20
    G1 = noise_sup(G1,Gno);
    Gno = noise_est(G2,Gno);
    G2 = noise_sup(G2,Gno);
    
    if C(i).pitch ~= 0; %voiced
        fm2 = FMCQ_CODEBOOK(C(i).QFM,:);
        if 1 == C(i).jt;
            jt2 = 0.25;
        else
            jt2 = 0;
        end
        vp2 = [1,C(i).vp];
        pitch_cur = C(i).pitch;
    else %unvoiced
        pitch_cur = 50;
        jt2 = 0;
        vp2(1:5) = 0;
    end
    
    %temp = melp_lsf2lpc(lsf_cur);
    %u_cur = max(0, d_k1(temp)*0.5);
    ploy = lsf2poly(pi*lsf_cur/4000);
    rc = poly2rc(ploy);
    u_cur = max(0,rc(1)*0.5);
    
    if (pitch_pre == 0)&&(pitch_cur ~= 0)    %Judge transform from u to v
        fm1 = fm2;
        pitch_pre = pitch_cur;
        jt1 = jt2;
        vp1 = vp2;
    end
    if t0>1
        sig_fr = sig_fr(181:t0+179);
    else
        sig_fr = [];
    end
    while t0<181 %t0基音周期的起始点
        e = 0;
        g = 0;
        h = 0;
        %Decode in a period
        %d_interpolate;
        %parameter interpolate
        factor = t0/180;
        %基音周期插值
        if t0<91
            G = G2p+2*factor*(G1-G2p);   %0~90
        else
            G = G1+(2*factor-1)*(G2-G1); %91~180
        end
        %特殊情况，改变插值系数
        if G2-G2p>6
            factor = (G-G2p)/(G2-G2p);
            factor = min(factor,1);
            factor = max(0,factor);
        end
        lsfs = factor*(lsf_cur-lsf_pre)+lsf_pre;
        u = factor*(u_cur-u_pre)+u_pre;
        
        %if pitch_cur == 0        %unvoiced
        %    T = 50;
        %    vp(1:5) = 0;
        %    jt = 0.25;
        %else             %voiced
            jt = factor*(jt2-jt1)+jt1;
            fm = factor*(fm2-fm1)+fm1;
            vp = factor*(vp2-vp1)+vp1;
            T = factor*(pitch_cur-pitch_pre)+pitch_pre;
            if ((G1-G2p)>6)&&(pitch_pre>2*pitch_cur)
                T = pitch_cur;
            end
        %end
        
        %产生激励信号
        %if p2 == 0
            %ep1(1:5) = 0;
        %    e = rand(1,T)-0.5;
        %    unvoiced_count = unvoiced_count+1;
        %else
            [e,T] = d_mix(fm,T,jt,vp,factor);
        %end
        
        lpcs = melp_lsf2lpc(lsfs);
        [g,state_ase,state_tilt] = d_ase(e,lpcs,G,Gno,u,T,state_ase,state_tilt);%自适应谱增强滤波
        %v_nase = [v_nase,g];
        [h,state_syn] = d_lps(lpcs,g,T,state_syn);%LP合成
        t0 = t0 + T;
        h = d_ga(T,h,G);%增益调整
        sig_fr = [sig_fr,h];
    end
    [temp,state_disp] = disper_filter(sig_fr,state_disp,disperse);%脉冲散布滤波
    v = [v,temp];
    G2p = G2;
    lsf_pre = lsf_cur;
    u_pre = u_cur;
    t0 = t0-180;
    if pitch_cur ~= 0
        pitch_pre = pitch_cur;
        fm1 = fm2;
        jt1 = jt2;
    end
end
%wavwrite(v/32768, 8000, strcat(datestr(now,'HH_MM_SS'),'.wav'));
soundsc(v, 8000);
