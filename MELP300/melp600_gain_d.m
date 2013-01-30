function [gain] = melp600_gain_d(gainQ, mode)
%melp600 ÔöÒæ
global MODE1 MODE2 MODE3 MODE4 MODE5 MODE6;
global gainCB_9b;%9bit
global gainCB_65_6 gainCB_65_5;%11bit
global gainCB_76_7 gainCB_76_6;%13bit

switch mode
    case {MODE1,MODE2}
        gainData = MSVQ_d(gainCB_76_7,gainQ(1),gainCB_76_6,gainQ(2));
    case {MODE3, MODE4, MODE5}
        gainData = MSVQ_d(gainCB_65_6,gainQ(1),gainCB_65_5,gainQ(2));
    case MODE6
        gainData = MSVQ_d(gainCB_9b,gainQ);
    otherwise
        err('mode error');
end

gain(1,:) = gainData(1:2);
gain(2,:) = gainData(3:4);
gain(3,:) = gainData(5:6);
gain(4,:) = gainData(7:8);

end