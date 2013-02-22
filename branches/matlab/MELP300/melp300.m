function [ bandPassQ,gainQ, pitchQ, LSF_Q ] = melp300( bandPass, gain, pitch, LSF, lpcSuper)
%melp300����֡ʸ�����������������Ϊ8֡
%   Detailed explanation goes here
global modeCount;
temp1 = size(bandPass, 1);
temp2 = size(gain, 1);
temp3 = size(pitch, 1);
temp4 = size(LSF, 1);
if temp1 ~= 8 || temp2 ~= 8 || temp3 ~= 8 || temp4 ~= 8
    error('superframe size ~= 8');
end
% mode = modeDeterm(bandPass);
bandPassQ = BandPassVQ(bandPass);
%��������Ӵ�ǿ�Ƚ����о�
codeMode = modeDeterm(melp300_BP_d(bandPassQ));
modeCount(codeMode) = modeCount(codeMode)+1;
gainQ = gainVQ(gain, codeMode);
% gain_d = melp300_gain_d(gainQ, codeMode);
% gain_err = sum(sum(abs(gain-gain_d)))
LSF_Q = LSF_VQ(lpcSuper, LSF, codeMode);
pitchQ = pitchVQ(pitch, codeMode, bandPassQ);
% pitch_d = melp300_pitch_d(pitchQ, mode);
% pitch_err = sum(sum(abs(pitch_d-pitch)))
end
