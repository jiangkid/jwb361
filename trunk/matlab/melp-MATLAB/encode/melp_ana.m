%%%%%%%%RUN This Program to Encode%%%%%%%%%%%%%

%Global varible and constant
%global dcr_ord dcr_num dcr_den FRL cheb_s sig_in
%global butt_1000ord butt_1000num butt_1000den state butter_s sig_1000
%global melp_bands state_b melp_envelopes state_e pre_intp
%global G2p ham_win
%global buffer pavg
clear all;
melp_init;
SD(1:Nframe) = 0;
for FRN = 1:(Nframe-1)             %%%%%%%%%%%%%%%%%%%%
    %Refresh buffers，分析窗为两帧
    %Get new speech(filted by 4-order chebyshev filter)
    sig_in(1:FRL) = sig_in(FRL+1:FRL*2);                  
    %Refresh 1000Hz speech buffer
    sig_1000(1:FRL) = sig_1000(FRL+1:FRL*2);
    %Refresh bandpass speech                       
    melp_bands(:, 1:FRL) = melp_bands(:, FRL+1:FRL*2);              
    %Refresh envelope bandpass speech
    melp_envelopes(:, 1:FRL) = melp_envelopes(:, FRL+1:FRL*2);      

    %Get a new frame speech
    sig_origin = s((FRN-1)*FRL+1:FRN*FRL);

    %Reduce the direct current, modify by jiangwenbin
    %[sig_in(FRL+1:FRL*2), cheb_s] = filter(dcr_num, dcr_den, sig_origin, cheb_s);
    [sig_in(FRL+1:FRL*2), cheb_in_s, cheb_out_s] = melp_iir(dcr_num, dcr_den, sig_origin,cheb_in_s, cheb_out_s);
    %[sig_in(FRL+1:FRL*2), cheb_s] = melp_iir(sig_origin, cheb_s, dcr_ord, dcr_num, dcr_den, FRL);

    %Get integer pitch, modify by jiangwenbin
    %[sig_1000(FRL+1:FRL*2), butter_s] = filter(butt_1000num, butt_1000den, sig_in(FRL+1:FRL*2), butter_s);
    [sig_1000(FRL+1:FRL*2), butter_in_s, butter_out_s] = melp_iir(butt_1000num, butt_1000den, sig_in(FRL+1:FRL*2), butter_in_s, butter_out_s);
    
    %[sig_1000(FRL+1:FRL*2), butter_s] = melp_iir(sig_in(FRL+1:FRL*2), butter_s, butt_1000ord, butt_1000num, butt_1000den, 180);
    cur_intp = intpitch(sig_1000, 160, 40);%粗估计范围40~160，对应200~50HZ

    %bandpass analyze
    %Get bandpass and envelopes
    [melp_bands(:, FRL+1:FRL*2), melp_envelopes(:, FRL+1:FRL*2)] = melp_5b(sig_in(FRL+1:FRL*2));
    %Get fractal pitch
    [p2, vp(1)] = pitch2(melp_bands(1, :), cur_intp);%0~500Hz
    %bandpass voicing analyse
    vp(2:5) = melp_bpva(melp_bands, melp_envelopes, p2);
    %pre_intp = cur_intp;
    r2 = vp(1);

    %jitter
    if vp(1)<0.5
        jitter = 1;
    else
        jitter = 0;
    end

    %LPC analyse
    e_lpc = melp_lpc(sig_in(81:280));
    %temp_lpc = lpc(sig_in(81:280), 10);
    %e_lpc = temp_lpc(2:11);

    %LPC Residual
    e_resid = lpc_residual(e_lpc, sig_in, 350);

    %Peakness Check
    peak = sqrt(e_resid(106:265)*e_resid(106:265)'/160)/(sum(abs(e_resid(106:265)))/160);
    %peak = sqrt(160)*norm(e_resid(106:265))/norm(e_resid(106:265), 1);

    %jitter voice detect
    if peak>1.34
        vp(1) = 1;
    end
    if peak>1.6
        vp(2:3) = 1;
    end

    %Final pitch dectect
    [fltd_resid, resid_in_s, resid_out_s] = melp_iir(butt_1000num, butt_1000den, e_resid, resid_in_s, resid_out_s);
    fltd_resid = [[0,0,0,0,0], fltd_resid, [0,0,0,0,0]];
    [p3, r3] = pitch3(sig_in, fltd_resid, p2, pavg);

    %Gain
    G = melp_gain(sig_in, vp(1), p2);

    %Refresh average pitch
    [pavg, pavg_buffer] = melp_APU(p3, r3, G(2), pavg_buffer);

    %Get LSF 
    LSF = poly2lsf([1, e_lpc])';%modify by jiangwenbin
    %LSF = melp_lpc2lsf(e_lpc);

    %minimun distance expand
    LSF = lsf_clmp(LSF);

    %Muti-stage Vector Quatization
    MSVQ = melp_MSVQ(e_lpc, LSF);
    %MSVQ = melp_MSVQ_jwb(e_lpc, LSF);

    %Gain quantization
    QG = melp_Qgain(G2p, G);
    G2p = G(2);

    %Fourier Spectrum Magnitude
    lsfs = d_lsf(MSVQ);
    lpc2 = melp_lsf2lpc(lsfs);
    tresid2 = lpc_residual(lpc2, sig_in(76:285), 200);
    resid2 = tresid2.*ham_win;
    resid2(201:512) = 0;
    magf = abs(fft(resid2));
    fm = find_harm(magf, p3);
    
    %计算谱失真,add by jiangwenbin
    [e_lpc_h, ] = freqz(1, [1, e_lpc], 256);%计算频率响应
    [lpc2_h, ] = freqz(1, [1, lpc2], 256);
    e_lpc_power_db = 10*log10(abs(e_lpc_h.^2));%功率
    lpc2_power_db = 10*log10(abs(lpc2_h.^2));
    SD(FRN) = sqrt(mean((e_lpc_power_db-lpc2_power_db).^2));%均方根
    
    %Quantize Fourier Magnitude
    QFM = melp_FMCQ(fm);
    
    %quantize vp
    if vp(1)<=0.6
        vp(2:5) = 0;    
    else
        for i = 2:5
            if vp(i) > 0.6
                vp(i) = 1;
            else
                vp(i) = 0;
            end
        end
        if vp(2:5) == 0001
            vp(5) = 0;
        end
    end
    
    %组帧  C(N) = struct('ls', 0, 'fm', 0, 'pitch', 0, 'G', 0, 'vp', 0, 'jt', 0);
    c(FRN).ls = MSVQ;
    c(FRN).QFM = QFM;
    c(FRN).G = QG;
    c(FRN).jt = jitter;
    c(FRN).vp = vp(2:5);
    if vp(1)>0.6
        c(FRN).pitch = p3;
    else
        c(FRN).pitch = 0;
    end
end
save('..\decode\c_data.mat', 'c');