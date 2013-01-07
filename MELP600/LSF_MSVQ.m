function [ VQ ] = LSF_MSVQ( LSFData, CB_stage1, CB_stage2, CB_stage3 )
%LSF_MSVQ, LSF多级矢量量化

%stage1
distance = pdist2(LSFData, CB_stage1);
[value, idx] = min(distance);
VQ(1) = idx;
residStage1 = LSFData - CB_stage1(idx,:);
%stage2
distance = pdist2(residStage1, CB_stage2);
[value, idx] = min(distance);
VQ(2) = idx;
residStage2 = residStage1 - CB_stage2(idx,:);
%stage3
distance = pdist2(residStage2, CB_stage3);
[value, idx] = min(distance);
VQ(3) = idx;

end