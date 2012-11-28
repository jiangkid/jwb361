
close all;
clear all; % clear the workspace
clc; % clear the command line
% ---------------
InputFilename = 'part3.wav'; %change it according to your wave files  
[inSpeech, sampleRate, bits] = wavread(InputFilename); % read the wavefile

pre_param = -0.9375;
frameLen = 180;

%=============================coder parameter=============================
aCoeff = [];
Gain = [];
pitch = [];
resid = [];

%%coder
%=============================start of coder=============================
%pre-process
speech = filter([1 pre_param], 1, inSpeech);


%loop calculate LSF
order = 10;
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
    resid(:,frameIdx) = errSig/Gain(frameIdx);
end

% perform a discrete cosine transform on the residual
resid = dct(resid);
[a,b] = size(resid);
% only use the first 50 DCT-coefficients this can be done
% because most of the energy of the signal is conserved in these coeffs
resid = [ resid(1:50,:); zeros(a-50, b) ];
 
% quantize the data
resid = uencode(resid,4);
resid = udecode(resid,4);
 
% perform an inverse DCT
resid = idct(resid);
 
% add some noise to the signal to make it sound better
noise = [ zeros(50,b); 0.01*randn(a-50, b) ];
resid = resid + noise;
%============================end of coder==================================


%%decoder
%=============================start of decoder=============================
outSpeech = [];
[L1 frameNum] = size(aCoeff);

for frameIdx = 1:frameNum
    if 1
        residFrame = [];    
        % first check if it is voiced or unvoiced sound:
        if ( pitch(frameIdx) == 0 )
            residFrame = randn(frameLen, 1);
        else
            t = 0 : frameLen;
            t = t/sampleRate; %ms
            d = 0 : 1/pitch(frameIdx) : 1; % 1/pitchfreq. repetition freq.
            residFrame = (pulstran(t, d, 'tripuls', 0.001))'; % sawtooth width of 0.001s
            residFrame = residFrame + 0.75*randn(frameLen+1, 1);
        end;
    else        
        residFrame = resid(:,frameIdx);
    end;
    A = aCoeff(:, frameIdx);
    synFrame = filter(Gain(frameIdx), A', residFrame); % synthesize speech from LPC coeffs
    outSpeech = [outSpeech; synFrame];
end

outSpeech = filter(1, [1 pre_param], outSpeech);

if 1
    [n,Wn] = buttord(2*3600/sampleRate, 0.9999, 3, 50);
    [b,a] = butter(n,Wn);
    outSpeech = filter(b, a, outSpeech);
end;

%==========================end of decoder==================================
soundsc(outSpeech, sampleRate);

if 0
%play original sound
    disp('Press a key to play the original sound!');
    pause;
    soundsc(inSpeech, sampleRate);
end
