function [ pitchQ ] = pitchVQ2( pitch, codeMode, bandPassQ)
%未加权
%   Detailed explanation goes here
global MODE1 MODE2 MODE3 MODE4;
global pitchCB_9b;
global prePitch prePitchQ preUV;
superSize = size(pitch, 1);
if superSize ~= 8
    err('bandPass size ~= 8');
end

%只对浊音帧量化
pitch = pitch';
bandPass = BandPassConstrain( melp300_BP_d(bandPassQ));
w = ones(1,8);
for cb_idx = 1:8
    if bandPass(cb_idx,1) == 0
        pitch(cb_idx) = 0;%清音帧，强制为0
        w(cb_idx) = 0;%权值为0
    else
        pitch(cb_idx) = log10(pitch(cb_idx));
    end
end

%Vector Quantization
switch codeMode
    case MODE1
        pitchQ = 0;
    case MODE2 %标量量化 6b
        for cb_idx = 1:8
            if pitch(cb_idx) ~= 0
                pitchData = max(1.3010, pitch(cb_idx));%log10(20)=1.3010
                pitchData = min(pitch(cb_idx),2.2041);%log10(160)=2.2041
                pitchQ = fix(2^6*(pitchData-1.3010)/2.2041);
                break;
            end
        end
    case {MODE3, MODE4}
        distance = pdist2(pitch, pitchCB_9b);
        [value, idx] = min(distance);
        pitchQ = idx;
end

end
