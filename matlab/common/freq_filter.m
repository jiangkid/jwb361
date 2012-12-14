function [ dataOut ] = freq_filter( dataIn, k )
%频域滤波,dataIn 输入信号,k 频域滤波系数
%默认进行512点fft计算, k长度256, dataIn, k均为列向量
%输入校验
kLen = size(k, 1);
dataLen = size(dataIn, 1);
if kLen ~= 256
    error('k is not 256');
end
if dataLen > 512
    error('length of dataIn error');
end
dataIFFT = zeros(512, 1);
dataFFT = fft(dataIn, 512);
dataAmp = abs(dataFFT(1:256)).*k;
dataIFFT(1:256) = dataAmp.*exp(1i*angle(dataFFT(1:256)));
dataIFFT(258:512) = dataIFFT(256:-1:2);
dataIFFT(257) = 0;
dataOutTemp = ifft(dataIFFT);
dataOut = 2*real(dataOutTemp(1:dataLen));

end

