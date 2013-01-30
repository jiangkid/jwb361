function [dataOut] = MSVQ_d(CB1,idx1,CB2,idx2,CB3,idx3,CB4,idx4)
%MSVQ_d 多级矢量量化解码
switch nargin
    case 2
        dataOut = CB1(idx1,:);
    case 4
        dataOut = CB1(idx1,:)+CB2(idx2,:);
    case 6
        dataOut = CB1(idx1,:)+CB2(idx2,:)+CB3(idx3,:);
    case 8
        dataOut = CB1(idx1,:)+CB2(idx2,:)+CB3(idx3,:)+CB4(idx4,:);
    otherwise
        err('input error');
end
end