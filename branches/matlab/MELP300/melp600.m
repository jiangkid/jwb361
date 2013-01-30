function [ bandPassQ,gainQ, pitchQ, LSF_Q ] = melp600( bandPass, gain, pitch, LSF, lpcSuper)
%melp600超级帧矢量量化，输入参数均为4帧
%   Detailed explanation goes here
global modeCount;
temp1 = size(bandPass, 1);
temp2 = size(gain, 1);
temp3 = size(pitch, 1);
temp4 = size(LSF, 1);
if temp1 ~= 4 || temp2 ~= 4 || temp3 ~= 4 || temp4 ~= 4
    error('superframe size ~= 4');
end
% mode = modeDeterm(bandPass);
bandPassQ = BandPassVQ(bandPass);
%量化后的子带强度进行判决
codeMode = modeDeterm(melp600_BP_d(bandPassQ));
modeCount(codeMode) = modeCount(codeMode)+1;
gainQ = gainVQ(gain, codeMode);
% gain_d = melp600_gain_d(gainQ, mode);
% gain_err = sum(sum(abs(gain-gain_d)))
pitchQ = pitchVQ(pitch, codeMode, bandPassQ);
% pitch_d = melp600_pitch_d(pitchQ, mode);
% pitch_err = sum(sum(abs(pitch_d-pitch)))
LSF_Q = LSF_VQ(lpcSuper, LSF, codeMode);
end
