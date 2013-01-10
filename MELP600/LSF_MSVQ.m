function [ VQ ] = LSF_MSVQ( LSFData, w, CB1, CB2, CB3 )
%LSF_MSVQ, LSF多级矢量量化

%stage1
[value, idx] = GetMatch(LSFData, CB1, w);
VQ(1) = idx;
residStage1 = LSFData - CB1(idx,:);
%stage2
[value, idx] = GetMatch(residStage1, CB2, w);
VQ(2) = idx;
residStage2 = residStage1 - CB2(idx,:);
%stage3
[value, idx] = GetMatch(residStage2, CB3, w);
VQ(3) = idx;

end