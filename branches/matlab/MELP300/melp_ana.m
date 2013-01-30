%%%%%%%%RUN This Program to Encode%%%%%%%%%%%%%

%Global varible and constant
%global dcr_ord dcr_num dcr_den FRL cheb_s sig_in
%global butt_1000ord butt_1000num butt_1000den state butter_s sig_1000
%global melp_bands state_b melp_envelopes state_e pre_intp
%global G2p ham_win
%global buffer pavg
clear all;
melp_init;
p2_pre_count = 0;
LSF_MSVQ_all = zeros(Nframe, 4);
melp600_init;
interCnt = 0;
superCnt = 0;
bandPassSuper = zeros(4,5);
gainSuper = zeros(4,2);
pitchSuper = zeros(4,1);
LSFSuper = zeros(4,10);
lpcSuper = zeros(4,10);
LSF1Super = zeros(2,10);
LSF2Super = zeros(2,10);

c = struct([]);
frameData = struct([]);
for frameIdx = 1:(Nframe-1)             %%%%%%%%%%%%%%%%%%%%
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
    sig_origin = s((frameIdx-1)*FRL+1:frameIdx*FRL);
    
    %Reduce the direct current
    [sig_in(FRL+1:FRL*2), cheb_in_s, cheb_out_s] = melp_iir(dcr_num, dcr_den, sig_origin,cheb_in_s, cheb_out_s);
    
    %Get integer pitch
    [sig_1000(FRL+1:FRL*2), butter_in_s, butter_out_s] = melp_iir(butt_1000num, butt_1000den, sig_in(FRL+1:FRL*2), butter_in_s, butter_out_s);
    
    cur_intp = intpitch(sig_1000, 160, 40);%粗估计范围40~160，对应200~50HZ
    
    %bandpass analyze
    %Get bandpass and envelopes
    [melp_bands(:, FRL+1:FRL*2), melp_envelopes(:, FRL+1:FRL*2)] = melp_5b(sig_in(FRL+1:FRL*2));
    %Get fractal pitch
    [p2_cur, vbp1_cur] = pitch2(melp_bands(1, :), cur_intp);%0~500Hz
    [p2_pre, vbp1_pre] = pitch2(melp_bands(1, :), pre_intp);%0~500Hz
    if vbp1_cur >vbp1_pre
        p2 = p2_cur;
        vp(1) = vbp1_cur;
    else
        p2_pre_count = p2_pre_count+1;
        p2 = p2_pre;
        vp(1) = vbp1_pre;
    end
    pre_intp = cur_intp;
    %bandpass voicing analyse
    vp(2:5) = melp_bpva(melp_bands, melp_envelopes, p2);
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
    %LSF = poly2lsf([1, e_lpc])';
    LSF = melp_lpc2lsf(e_lpc);
    
    %minimun distance expand
    LSF = lsf_clmp(LSF);
    
    %Muti-stage Vector Quatization
    MSVQ = melp_MSVQ(e_lpc, LSF);
    %Gain quantization
    QG = melp_Qgain(G2p, G);
    G2p = G(2);
    %Fourier Spectrum Magnitude
    lsfs = d_lsf(MSVQ);
    lpc2 = melp_lsf2lpc(lsfs);
    tresid2 = lpc_residual(lpc2, sig_in(76:285), 200);%modify
    resid2 = tresid2.*ham_win;
    resid2(201:512) = 0;
    magf = abs(fft(resid2));
    fm = find_harm(magf, p3);
    
    %Quantize Fourier Magnitude
    QFM = melp_FMCQ(fm);
    
    %%%%%%%%%%%%%%%%%%%
    interCnt = interCnt+1;
    bandPassSuper(interCnt,:) = vp;
    gainSuper(interCnt,:) = G;
    if p3 == 0
        p3 = 20;
    end
    pitchSuper(interCnt,:) = p3;
    LSFSuper(interCnt,:) = LSF;
    lpcSuper(interCnt,:) = e_lpc;
    if 4 == interCnt %四帧联合量化
        interCnt = 0;
        superCnt = superCnt+1;
        [bandPassQ,gainQ,pitchQ,LSF_Q] = melp600(bandPassSuper,gainSuper,pitchSuper,LSFSuper, lpcSuper);
        frameData(superCnt).bandPassQ = bandPassQ;
        frameData(superCnt).gainQ = gainQ;
        frameData(superCnt).pitchQ = pitchQ;
        frameData(superCnt).LSF_Q = LSF_Q;
        frameData(superCnt).QFM = QFM;
    end
    %%%%%%%%%%%%%%%%%%%%%%
    
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
    c(frameIdx).ls = MSVQ;
    c(frameIdx).QFM = QFM;
    c(frameIdx).G = QG;
    c(frameIdx).jt = jitter;
    c(frameIdx).vp = vp(2:5);
    if vp(1)>0.6
        c(frameIdx).pitch = p3;
    else
        c(frameIdx).pitch = 0;
    end
end

%decode
% voice = melp_decoder(c);
voice = melp600_decoder(frameData);
% soundsc(voice, 8000);
wavwrite(voice/32768, 8000, strcat(datestr(now,'HH_MM_SS'),'.wav'));
