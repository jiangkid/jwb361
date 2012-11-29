%the size of s is 64+180
%pulse dispersion
function [out, state_disp] = disper_filter(in,state_disp,disperse)
buffer1 = [state_disp,in];
out(1:180) = 0;
for i = 1:180
   out(i) = buffer1(i:i+64)*disperse;
end
state_disp = in(116:180);