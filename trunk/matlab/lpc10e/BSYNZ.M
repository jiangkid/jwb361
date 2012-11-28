% MATLAB SIMULATION OF FS-1015 LPC-10e
% COPYRIGHT (C) 1996-99 ANDREAS SPANIAS and TED PAINTER

% This Copyright applies only to this particular MATLAB implementation
% of the LPC-10e coder.  The MATLAB software is intended only for educational
% purposes.  No other use is intended or authorized.  This is not a public
% domain program and unauthorized distribution to individuals or networks 
% is prohibited. Be aware that use of the standard in any form is goverened
% by rules of the US DoD.  
% This program is free software. It is distributed in the hope that it will
% be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  There is no commitment 
% or even implied commitment on behalf of Andreas Spanias or Ted Painter
% for maintenance or support of this code.

% MATLAB is trademark of The Mathworks Inc

% ALL DERIVATIVE WORKS MUST INCLUDE THIS COPYRIGHT NOTICE.

%
% ******************************************************************
%
% BSYNZ
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 4-6-94
% ******************************************************************
%
% DESCRIPTION
%
% Synthesize one pitch epoch of output speech.
%
% DESIGN NOTES
%
% First determines LPC filter tail scale factor. Filter memory is
% scaled appropriately.  Voicing is then examined to determine
% filter excitation requirements.  Unvoiced epochs are excited by
% random numbers uniformly distributed between -512 and 512.
%
% For voiced epochs, a voiced excitation is generated, consisting
% of a low-pass filtered 25 sample waveform added to high-pass
% filtered random noise samples.
%
% The excitation sequence is then passed through an excitation
% modification, all-zero filter.
%
% Finally, the modified excitation sequence is passed through the
% all-pole LPC synthesis filter.
%
% This routine is called once for each epoch within a speech frame.
%
% See Also:  Version 52 release notes
%
% VARIABLES
%
% INPUTS
%   coef     -   Predictor coefficients
%   ip       -   Pitch period (length of epoch to be synthesized)
%   iv       -   Voicing decision for current epoch
%   rms      -   Energy for current epoch
%   ratio    -   Frame energy slope for unvoiced epoch plosive scaling
%   g2pass   -   Sharpening factor for excitation modification filter
%
% OUTPUTS
%   sout     -   Synthesized speech epoch buffer
%
% GLOBALS
%   kexc     -   Voiced excitation base sequence (predefined)
%   exc      -   Input excitation for LPC synthesis filter I (all zero)
%   exc2     -   Input and output for LPC synthesis filter II (all pole)
%   ipo      -   Pitch epoch length, previous epoch
%   bsRmso   -   Previous epoch energy
%   Zlpf     -   Filter memory, excitation LPF
%   Zhpf     -   Filter memory, excitation HPF
%
% INTERNAL
%   xy       -   LPC filter history tail energy scale factor
%   px       -   Position of plosive impluse doublet
%   pulse    -   Impulse doublet magnitudes, unvoiced excitation
%   sscale   -   Voiced pulse excitation scale factor
%   Blpf     -   Filter taps, excitation sequence low-pass
%   Bhpf     -   Filter taps, excitation additive noise high-pass
%   Alhpf    -   Filter denominators, lpf and hpf = 1 (FIR filters)
%   noise    -   Additive noise for voiced excitation modification
%   xssq     -   Precorrected energy of entire output epoch
%   ssq      -   Desired energy of output speech
%   gain     -   Output energy correction factor
%   clip     -   Number of samples to used from standard voiced
%                excitation sequence.
%   rvals    -   Random values used in unvoiced excitation
%   mrk      -   Negative value marker vector for unvoiced excitation
%   el       -   Excitation buffer low index
%   eh       -   Excitation buffer high index
%
% CONSTANTS
%   ORDER    -   LPC predictor order
%   MAXORD   -   LPC predictor order
%   MAXPIT   -   Maximum pitch epoch length
%
% ******************************************************************

function [ sout ] = bsynz( coef, ip, iv, rms, ratio, g2pass, sout )

% DECLARE GLOBAL CONSTANTS
global ORDER MAXORD MAXPIT

% DECLARE GLOBAL VARIABLES
global kexc exc exc2 ipo bsRmso Zlpf Zhpf;
global guiExcit;

% INITIALIZE LOCAL VARIABLES
Blpf = [  0.125, 0.75,  0.125 ];
Bhpf = [ -0.125, 0.25, -0.125 ];
Alhpf = [ 1, 0, 0 ];
el = 1 + ORDER;
eh = ip + ORDER;
noise = zeros( MAXPIT+MAXORD, 1 );

% CALCULATE HISTORY SCALE FACTOR XY AND SCALE FILTER STATE
xy = min( [bsRmso/(rms+0.000001), 8.0] );
bsRmso = rms;
exc2(1:ORDER) = exc2(1+ipo:ORDER+ipo) .* xy;
ipo = ip;

% GENERATE WHITE NOISE FOR UNVOICED EPOCHS; DETERMINISTIC + NOISE FOR VOICED
if iv == 0

    % UNVOICED EPOCH EXCITATION
    rvals = lpcrandom(ip);
    mrk = rvals < 0;
    rvals = rvals + ( 65536 .* mrk );
    exc(el:eh) = fix( rvals ./ 64 ) - ( mrk .* 1024 );

    % NOTE:  ABOVE ADD/SUBTRACT IS REQUIRED TO MATCH BEHAVIOR OF
    % C VERSION OF LPC55-C, WHERE INTEGER VALUES ARE SHIFTED
    % RIGHT BY SIX BITS.  RIGHT SHIFTS ON NEGATIVE QUANTITIES
    % ARE EQUIVALENT TO FIXED POINT DIVISION OF A DIFFERENT VALUE
    % BECAUSE OF 2S COMPLEMENT ENCODING. SAME TECHNIQUE IS USED
    % BELOW TO ACHIEVE SIMILAR RESULT. THIS SECTION CAN
    % EVENTUALLY BE REPLACED BY MATLAB RANDOM SETUP FOR UNIFORM
    % OVER -512 to 512. THIS PAINFUL METHOD HAS ONLY BEEN USED
    % TO ALLOW EASIER PORT TESTING.

    % ADD IMPULSE DOUBLET TO UNVOICED EXCITATION FOR PLOSIVES
    px = fix( ((lpcrandom(1)+32768)*(ip-1)) / 65536 ) + ORDER + 1;
    pulse = ratio * 85.5;
    if pulse > 2000
        pulse = 2000;
    end
    exc(px) = exc(px) + pulse;
    exc(px+1) = exc(px+1) - pulse;
else

    % VOICED EPOCH EXCITATION
    % LOWPASS FILTER STANDARD EXCITATION SEQUENCE
    sscale = sqrt(ip) * 0.144341801;
    exc(el:eh) = zeros(ip,1);
    clip = min([25,ip]);
    exc(el:clip+ORDER) = sscale .* kexc(1:clip);
    [ exc(el:eh), Zlpf ] = filter( Blpf, Alhpf, exc(el:eh), Zlpf );

    % HIGHPASS FILTER ADDITIVE NOISE SEQUENCE
    rvals = lpcrandom(ip);
    mrk = rvals < 0;
    rvals = rvals + ( 65536 .* mrk );
    noise(el:eh) = fix( rvals ./ 64 ) - ( mrk .* 1024 );
    [ noise(el:eh), Zhpf ] = filter( Bhpf, Alhpf, noise(el:eh), Zhpf );

    % COMBINE FILTERED NOISE PLUS FILTERED PULSE
    exc(el:eh) = exc(el:eh) + noise(el:eh);
end

% COPY EXCITATION TO GRAPHICAL OUTPUT BUFFER    
guiExcit = [guiExcit;exc(el:eh)];

% SYNTHESIS FILTER I
% MODIFY THE EXCITATION WITH AN ALL-ZERO FILTER, 1+G*SUM
for i = el:eh
    exc2(i) = ( g2pass * sum( coef .* exc(i-1:-1:i-ORDER) ) ) + exc(i);
end

% SYNTHESIS FILTER II
% APPLY ALL-POLE LPC FILTER TO THE MODIFIED EXCITATION (1/1-SUM)
for i = el:eh
    exc2(i) = exc2(i) + sum( coef .* exc2(i-1:-1:i-ORDER) );
end

% COMPUTE RMS SIGNAL LEVEL
xssq = sum( exc2(el:eh) .* exc2(el:eh) );

% SAVE FILTER MEMORY FOR NEXT EPOCH
exc(1:ORDER) = exc(ip+1:ip+ORDER);
exc2(1:ORDER) = exc2(ip+1:ip+ORDER);

% APPLY GAIN TO MATCH RMS
ssq = rms * rms * ip;
gain = sqrt( ssq / xssq );
sout(1:ip) = gain .* exc2(el:eh);





