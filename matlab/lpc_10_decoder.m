%LPC coder
%lpc_10_decoder.m
%
function outSpeech = lpc_10_decoder(aCoeff, Gain, pitch, sampleRate)

outSpeech = [];
pre_param = -0.9375;
frameLen = 180;

[L1 frameNum] = size(aCoeff);

for frameIdx = 1:frameNum
    residFrame = [];
    
    % first check if it is voiced or unvoiced sound:
	if ( pitch(frameIdx) == 0 )
		residFrame = randn(frameLen, 1);
	else
		t = 0 : frameLen;
        t = t/sampleRate; %ms
		d = 0 : 1/pitch(frameIdx) : 1; % 1/pitchfreq. repetition freq.
		residFrame = (pulstran(t, d, 'tripuls', 0.001))'; % sawtooth width of 0.001s
		%residFrame = residFrame + 0.01*randn(frameLen+1, 1);
	end;    
    
    A = aCoeff(:, frameIdx);
    synFrame = filter(Gain(frameIdx), A', residFrame); % synthesize speech from LPC coeffs
    outSpeech = [outSpeech; synFrame];
end

outSpeech = filter(1, [1 pre_param], outSpeech);

[n,Wn] = buttord(2*3600/sampleRate, 0.9999, 3, 50);
[b,a] = butter(n,Wn);
outSpeech = filter(b, a, outSpeech);