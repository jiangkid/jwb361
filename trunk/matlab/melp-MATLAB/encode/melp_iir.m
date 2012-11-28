%IIR filter
%INPUT: 
%	sig_in(input signal)
%       state(initial state of filter)
%       iir_ord(filter order)
%	iir_num(filter numerator)
%	iir_den(filter denumerator)
%       length(input signal's length)
%OUTPUT:
%	sig_out(output signal)
%	state(final state of filter)
function [sig_out,state_in,state_out]=melp_iir(b,a,sig_in,state_in,state_out)
order = size(a, 2) - 1;
sig_len = size(sig_in, 2);
sig_out(1:sig_len) = 0;
buffer_in = [state_in, sig_in];
buffer_out = [state_out, sig_out];
for i = 1 : sig_len
    temp = buffer_in(i: i+order)*(fliplr(b)');
    buffer_out(i+order) = temp - buffer_out(i: i+order-1)*(fliplr(a(2:end))');
end
sig_out(1:sig_len) = buffer_out(order+1:end);
state_in = sig_in(end-order+1:end);
state_out = buffer_out(end-order+1:end);
%buffer1=state;
%for n=1:length
 %   buffer1(n+iir_ord)=sig_in(n)-buffer1(n:n+iir_ord-1)*(fliplr(iir_den(2:iir_ord+1))');  	%All pole filt
 %   sig_out(n)=buffer1(n:n+iir_ord)*(fliplr(iir_num)');						%All zero filt
%end
%state=buffer1(n+1:n+iir_ord);	%state Refresh
%state=state-mean(state);
%plot(buffer)
%state's dimension is iir_ord
       %[sig_out,state]=filter(iir_num,iir_den,sig_in,state);