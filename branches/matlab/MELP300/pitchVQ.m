function [ pitchQ ] = pitchVQ( pitch, codeMode, bandPassQ)
%采用MELP 1.2k的加权方案
%   Detailed explanation goes here
global MODE1 MODE2 MODE3 MODE4;
global  pitchCB_9b;
global  pitchCB_10b;
global prePitch prePitchQ preUV;
superSize = size(pitch, 1);
if superSize ~= 8
    err('bandPass size ~= 8');
end

%median filter(3 order)
% pitch(1) = median([pitch_m(1),pitch_m(2),pitch(1)]);
% pitch(2) = median([pitch_m(2),pitch(1),pitch(2)]);
% pitch(3) = median([pitch(1),pitch(2),pitch(3)]);
% pitch(4) = median([pitch(2),pitch(3),pitch(4)]);
% pitch_m = [pitch(3),pitch(4)];

%pre-process
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
        %         distance = pdist2(pitchData, pitchCB_6b);
        %         [value, idx] = min(distance);
        %         pitchQ = idx;
    case {MODE3, MODE4}
        %         distance = pdist2(log10(pitch'), pitchCB_9b);
        %         [value, idx] = min(distance);
        %         pitchQ = idx;
        d = zeros(2^9,1);
        for cb_idx = 1:2^9
            pCB = pitchCB_9b(cb_idx,:);
            d(cb_idx) = sum(((pitch-pCB).*w).^2);
            
            UV = [preUV,w];
            p_temp = [prePitch,pitch];
            pCB_temp = [prePitchQ,pCB];
            deltaP = zeros(1,8);
            deltaP_Q = zeros(1,8);
            for j=1:8
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
    prePitchQ = pitchCB_9b(pitchQ,end);
end
preUV = w(end);
end
