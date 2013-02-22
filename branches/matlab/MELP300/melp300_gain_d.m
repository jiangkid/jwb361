function [gain] = melp300_gain_d(gainQ, mode)
%melp300 ÔöÒæ
global MODE1 MODE2 MODE3 MODE4;
global gainCB_8b;%8bit
global gainCB_65_6 gainCB_65_5;%11bit
global gainCB_76_7 gainCB_76_6;%13bit

switch mode
    case MODE1
        gainDecode = MSVQ_d(gainCB_76_7,gainQ(1),gainCB_76_6,gainQ(2));
    case {MODE2, MODE3}
        gainDecode = MSVQ_d(gainCB_65_6,gainQ(1),gainCB_65_5,gainQ(2));
    case MODE4
        gainDecode = MSVQ_d(gainCB_8b,gainQ);
    otherwise
        err('mode error');
end

gain(1,:) = gainDecode(1:2);
gain(2,:) = gainDecode(3:4);
gain(3,:) = gainDecode(5:6);
gain(4,:) = gainDecode(7:8);
gain(5,:) = gainDecode(9:10);
gain(6,:) = gainDecode(11:12);
gain(7,:) = gainDecode(13:14);
gain(8,:) = gainDecode(15:16);

end