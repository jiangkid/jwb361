function [ bandPassQ,gainQ, pitchQ, LSF_Q ] = melp600( bandPass, gain, pitch, LSF )
%melp600超级帧矢量量化，输入参数均为4帧
%   Detailed explanation goes here
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
mode = modeDeterm(melp600_BP_d(bandPassQ));
gainQ = gainVQ(gain, mode);
pitchQ = pitchVQ(pitch, mode);
LSF_Q = LSF_VQ(LSF, mode);
end
