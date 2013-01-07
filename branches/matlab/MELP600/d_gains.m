%recover the gains
%G2pt, 前一帧G2增益
%G2p_error, G2pt是否有误码
function [G1,G2,G2pt,G2p_error]=d_gains(G,G2pt,G2p_error)
delta=67/32;
G2=(G(2)+0.5)*delta+10;%decode G2, +0.5为减少量化误差
if G(1)==0
    if abs(G2-G2pt)>5
        if G2p_error==0
            G2=G2pt;
        end
        G2p_error=1;
    else
        G2p_error=0;
    end
    G1=0.5*(G2+G2pt);
else
    gain_max=max(G2pt,G2)+6;
    gain_min=min(G2pt,G2)-6;
    if gain_min<10
        gain_min=10;
    end
    if gain_max>77
        gain_max=77;
    end
    %G1=(G(1)-1)*(gain_max-gain_min)/6+gain_min;%???
    G1=(G(1)-1+0.5)*(gain_max-gain_min)/7+gain_min;%modify by jiangwenbin
    G2p_error=0;
end
G2pt=G2;
end