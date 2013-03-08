function [ pitchQ ] = pitchVQ2( pitch, codeMode, bandPassQ)
%相关性加权法
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
UV = ones(1,8);
for cb_idx = 1:8
    if bandPass(cb_idx,1) == 0
        pitch(cb_idx) = 0;%清音帧，强制为0
        UV(cb_idx) = 0;
    else
        pitch(cb_idx) = log10(pitch(cb_idx));
        UV(cb_idx) = 1;
    end
end
UV = [preUV,UV];
preUV  = UV(end);
pitch_temp = [prePitch,pitch];
prePitch = pitch(end);

%计算权值
w = zeros(1,8);
for i = 1:8
    deltaP = pitch_temp(i+1) - pitch_temp(i);
    if(deltaP<0.08)
        w(i) = 1;
    else
        w(i) = 0.4 + 0.6^(deltaP/0.08);
    end
end
for i = 1:8
    if UV(i) == 0 %前一帧为清音帧
        w(i) = 1;
    end
end
for i = 1:8
    if UV(i+1) == 0 %当前帧为清音帧
        w(i) = 0;
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
        d = zeros(2^9,1);
        for cb_idx = 1:2^9
            pCB = pitchCB_9b(cb_idx,:);
            d(cb_idx) = sum(((pitch-pCB).*w).^2);            
        end
        [value, idx] = min(d);
        pitchQ = idx;
end

end
