%LPC coder
%lpc_10_coder.m
%
function [aCoeff, Gain, pitch] = lpc_10_coder(inSpeech)

%pre-process
pre_param = -0.9375;
speech = filter([1 pre_param], 1, inSpeech);

%loop calculate LSF
order = 10;
frameLen = 180;
frameNum = length(inSpeech)/frameLen;
for frameIdx = 1:frameNum
    frameData = speech(frameLen*(frameIdx-1)+1 : frameLen*frameIdx);
    if 0
        plot(current_frame);
        grid on;
        pause(0.1);
    end
    [a, g] = lpc(frameData, order); %calculate lpc coefficient
    aCoeff(:,frameIdx) = a;
    Gain(frameIdx) = g;
    %lsf = poly2lsf(a); %conver to LFS
    errSig = filter(a, 1, frameData); % find excitation noise
    autoCorErr = xcorr(errSig); % calculate pitch & voicing information
	[B,I] = sort(autoCorErr);
	num = length(I);
	if B(num-1) > .01*B(num)
		pitch(frameIdx) = abs(I(num) - I(num-1));
	else
		pitch(frameIdx) = 0;
	end
end