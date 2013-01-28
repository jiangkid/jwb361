function exc = voicePulse(ip)
%此部分代码源于LPC10 C语言，用于产生浊音脉冲激励信号
global Zlpf;
kexc = [8,-16,26,-48,86,-162,294,-502,718,-728,184,672,-610,-672,184,728,718,502,294,162,86,48,26,16,8];
exc = zeros(1, ip);
if ip>25
    exc(1:25) = kexc;
    exc(26:ip) = 0;
else
    exc(1:ip) = kexc(1:ip);
end
Blpf = [0.125, 0.75, 0.125]; 
Bhpf = [-0.125, 0.25, -0.125]; 
Alhpf = [1, 0, 0];
exc = exc + rand(1,ip)*100;%100最佳
[exc, Zlpf] = filter(Blpf, Alhpf, exc,  Zlpf); 

% randData = [-21161, -8478, 30892,-10216, 16950];
% sscale = sqrt(ip) * 0.144341801;
% for i = 1:ip
%     if i> 27
%         temp = 0;
%     elseif i <25
%         lpi0 = sscale * kexc(i);
%         temp = lpi0 * 0.125 + lpi1 * 0.75 + lpi2 * 0.125;
%         lpi2 = lpi1;
%         lpi1 = lpi0;
%     else
%         lpi0 = 0;
%         temp = lpi1 * 0.75 + lpi2 * 0.125;
%         lpi2 = lpi1;
%         lpi1 = lpi0;
%     end
%     hpi0 = randData(fix(1+rand*5))/(2^6);
%     exc(10 + i) = temp + hpi0 * -0.125 + hpi1 * 0.25 + hpi2 * -0.125;
%     hpi2 = hpi1;
%     hpi1 = hpi0;
% end

end