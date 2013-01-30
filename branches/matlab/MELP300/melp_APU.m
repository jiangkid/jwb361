%median filt
%Input:
%        p3(final pitch)
%        rp2(the corresponding correlation of p3)
%        G2(the 2nd Gain)
%        pavg_buffer(pitch pavg_buffer)
%Output:
%        pavg(average pitch)
%        pavg_buffer(refreshed pavg_buffer)
function [pavg,pavg_buffer]=melp_APU(p3,rp3,G2,pavg_buffer)
if (rp3>0.8)&&(G2>30)
    pavg_buffer=[pavg_buffer(2:3),p3];
else
    pavg_buffer=pavg_buffer*0.95+2.5;
end
pavg=median(pavg_buffer);
end