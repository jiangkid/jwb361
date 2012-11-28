function [ out, delay ] = FIR_filter( in, delay, b)
%  FIR filter
% note: 输入没有进行错误判断
buffer = [delay, in];
in_size = size(in, 2);
delay_size = size(delay, 2);
out(1:in_size) = 0;
for i = 1 : in_size
   out(i) = buffer(i : i+delay_size)*b;
end
delay = in(end-delay_size : end);
end

