function [ bandPassQ,gainQ, pitchQ, LSF_Q ] = melp600( bandPass, gain, pitch, LSF )
%melp600����֡ʸ�����������������Ϊ4֡
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
%��������Ӵ�ǿ�Ƚ����о�
mode = modeDeterm(melp600_BP_d(bandPassQ));
gainQ = gainVQ(gain, mode);
pitchQ = pitchVQ(pitch, mode);
LSF_Q = LSF_VQ(LSF, mode);
end
