function [rec , D] = LSEE(y1,window,overlap,stopdB)
% [rec , D] = LSEE(y1,window,overlap)

if nargin == 3,
    stopdB = 60;
end

D = [];

[m1 n1] = size(y1);
window_length = length(window);
step_dist = window_length/overlap;

if isreal(y1),
    %generate the Initial Estimate according to Normal Distribution :
    cols = n1*step_dist+window_length;
    curr = randn(1,cols);
else
    %resynth[esize the signal with approximate initial phase as given by y1
    curr = IStftw2(y1,overlap,window);
    y1 = abs(y1);
end

for(pp = 1:500)
    %compute STFT :
    curr_t = curr';
    y2 = Stft(curr_t,window,overlap);
    
    %let's subtitute the amplitude with given magnitude :
    y6 = y2./abs(y2);
    y3 = (y1 .* y6);
    %theta = angle(y2);
    %    y3 = y1 .* exp(i*theta);
    
    old = curr;
    %curr = IStft(y3,overlap,length(window));
    curr = IStftw2(y3,overlap,window);
    %curr = IStftw2cola(y3,overlap,window);
    curr = real(curr);
    
    err = sum((old-curr).^2);
    sig = sum(curr.^2);
    errdB = 20*log10(sig/err);
    
    if  errdB > stopdB, %err < 1e-6,
        disp(['Stop iteration at err = ', num2str(errdB) ' dB']);
        break
    end
    
    disp(['iteration ' int2str(pp) ', error = ' num2str(err) ', dB = ', num2str(errdB)]);
    
    %       
    %    soundsc(real(curr),fs);
    %  dif = (abs(curr(1:length(signal))) - abs(signal')).^2;
    dm = (abs(y2)-y1).^2;
    %    dif = ifft(dm);
    Di = sum(sum(dm));  
    
    D(pp) = abs(Di);
    
end
rec = curr(1:end-window_length);

