clear all;
clc;
[speech, fs] = wavread('si2323_8k.wav');
[fx,tx,pv] = fxpefac(speech,fs,0.02);%20ms

rec_s = randn(1, length(speech));
rec_s_org = rec_s;
for idx = 1:length(fx)
    frameStart = floor(tx(idx)*fs - 89);
    frameEnd = floor(tx(idx)*fs + 90);
    frameData = rec_s(frameStart:frameEnd);
    if(pv(idx) > 0.5) %voiced
        f = (1:floor(4000/fx(idx))).*fx(idx);
        frame_fft = fft(frameData,256);
        frame_mag_org = abs(frame_fft(1:129));
        frame_phase = angle(frame_fft(1:129));
        omega = floor(f/4000*129);%
        frame_mag = frame_mag_org;
        frame_mag(omega) = max(frame_mag_org);
        B = frame_mag.*exp(1i*frame_phase);
        B = [B, conj(B(end-1:-1:2))];
        frameData_r = ifft(B);
        rec_s(frameStart:frameEnd) = real(frameData_r(1:180));
%         frame_fft_r = fft(frameData_r,256);
%         frame_mag_r = abs(frame_fft_r(1:129));
%         frame_phase_r = angle(frame_fft_r(1:129));
%         subplot('Position',[0.05 0.55 0.44 0.44]);plot(frame_mag_org,'-*');
%         subplot('Position',[0.55 0.55 0.44 0.44]);plot(frame_phase,'-*');
%         subplot('Position',[0.05 0.05 0.44 0.44]);plot(frame_mag_r,'-*');
%         subplot('Position',[0.55 0.05 0.44 0.44]);plot(frame_phase_r,'-*');
%         figure(2);subplot(211);plot(frameData,'-*');subplot(212);plot(real(frameData_r(1:180)),'-*');
%         pause(0.5);
    end
end
save('initData.mat', 'rec_s','rec_s_org');
