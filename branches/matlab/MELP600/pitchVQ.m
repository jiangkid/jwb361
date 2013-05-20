function [ pitchQ ] = pitchVQ( pitch, bandPassQ)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
global pitchCB_8b;
global prePitch prePitchQ preUV;
global pitch_m;
superSize = size(pitch, 1);
if superSize ~= 4
    err('bandPass size ~= 4');
end
% %验证对应C算法
% pitch = pitch'*(2^7);%pitch Q7
% bandPass = melp600_BP_d(bandPassQ);
% uv_flags = 1 - bandPass(:,1)';
% pitchQ = melp_matlab(21, pitch, uv_flags);
% return;%验证对应C算法
%pre-process
pitch = pitch';
bandPass = BandPassConstrain( melp600_BP_d(bandPassQ));
w = ones(1,4);
cnt = 0;
for cb_idx = 1:4
    if bandPass(cb_idx,1) == 0
        pitch(cb_idx) = 0;%清音帧，强制为0
        w(cb_idx) = 0;%权值为0
    else
        pitch(cb_idx) = log10(pitch(cb_idx));
        cnt = cnt+1;
    end
end
delta = (log10(160) - log10(20))/(2^6);
%Vector Quantization
if (cnt == 0)
    pitchQ = 0;
elseif(cnt == 1)%标量量化
    for cb_idx = 1:4
        if pitch(cb_idx) ~= 0
            pitchData = max(1.3010, pitch(cb_idx));%log10(20)=1.3010
            pitchData = min(pitch(cb_idx),2.2041);%log10(160)=2.2041
            pitchQ = fix((pitchData-1.3010)/delta);
        end
    end
else%矢量量化
    d = zeros(2^8,1);
    for cb_idx = 1:2^8
        pCB = pitchCB_8b(cb_idx,:);
        d(cb_idx) = sum(((pitch-pCB).*w).^2);
        
        UV = [preUV,w];
        p_temp = [prePitch,pitch];
        pCB_temp = [prePitchQ,pCB];
        deltaP = zeros(1,4);
        deltaP_Q = zeros(1,4);
        for j=1:4
            if (UV(j)~=0) && (UV(j+1)~=0)
                deltaP(j) = p_temp(j+1) - p_temp(j);
                deltaP_Q(j) = pCB_temp(j+1) - pCB_temp(j);
            else
                deltaP(j) = 0;
                deltaP_Q(j) = 0;
            end
        end
        d(cb_idx) = d(cb_idx)+sum((deltaP-deltaP_Q).^2);
    end
    [value, idx] = min(d);
    pitchQ = idx;
end
prePitch = pitch(end);
if pitchQ~=0
    prePitchQ = pitchCB_8b(pitchQ,end);
end
preUV = w(end);
end
