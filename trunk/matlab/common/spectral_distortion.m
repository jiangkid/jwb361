function [ SD ] = spectral_distortion( lsf1, lsf2 )
%spectral_distortion Summary of this function goes here
%calculate spectral distortion of lsf1 and lsf2
%========本函数计算了0~4000Hz内的谱失真============
a1 = lsf2poly(lsf1);
a2 = lsf2poly(lsf2);
[h1, ] = freqz(1, a1, 256);%计算频率响应
[h2, ] = freqz(1, a2, 256);
h1_power_db = 10*log10(abs(h1.^2));%功率
h2_power_db = 10*log10(abs(h2.^2));
SD = sqrt(mean((h1_power_db-h2_power_db).^2));%均方根   
end

