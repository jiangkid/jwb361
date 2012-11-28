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
% DECODE
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 3-30-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Apply decoding and error correction to all received LPC parameters.
% Generate real-valued parameters to drive LPC synthesizer.
%
% DESIGN NOTES
%
% Pitch and voicing parameters are decoded first.  If error correction
% is not active, the two half-frame voicing decisions are set to 1 to
% indicate a sustained voicing condition.  Details of the pitch and
% voicing decode algorithms are described in the Version 52 release
% notes.
%
% Following pitch and voicing decoding, reflection coefficients 1-10
% are smoothed and decoded.  Pitch is also smoothed in some cases.
%
% Finally, RMS and RCs are converted back to real (floating point)
% values for use in the LPC synthesizer.
%
% See Also:  Version 52 release notes
%
% VARIABLES
%
% INPUTS
%   ipitv    -   Received pitch value, quantized and encoded
%   irms     -   Received RMS energy, quantized and encoded
%   irc      -   Received reflection coefficients, quantized and encoded
%   pitch    -   Place holder for decoded output pitch
%
% OUTPUTS
%   voice    -   Decoded voicing
%   pitch    -   Decoded pitch table index
%   rms      -   Decoded RMS energy
%   rc       -   Decoded reflection coefficients
%
% GLOBALS
%   drc      -   Matrix of past, present, and future frame RCs
%   dpit     -   Vector of past, present, and future frame pitch values
%   drms     -   Vector of past, present, and future frame RMS values
%   ivp2h    -   Voicing condition of previous second half frame
%   erate    -   Measured bit error rate
%   iovoic   -   2-bit voicing condition code for present frame
%   first    -   Flag set only for first frame of data
%
% CONSTANTS
%   ORDER    -   LPC predictor order
%
% INTERNAL
%   fut      -   Index of future frame (drc, etc.)
%   pres     -   Index of present frame (drc, etc.)
%   past     -   Index of past frame (drc, etc.)
%   ivoic    -   2-bit voicing condition code for future frame
%   iavgp    -   Average pitch value
%   icorf    -   Flag bits, used to direct flow of subroutine
%   index    -   Index variable for table lookup purposes
%   iout     -   Hamming 8,4 decoder output bits
%   ipit     -   Pitch indicator
%   ixcor    -   Row address of smoothing threshold table CORTH
%   lsb      -   Variable holding least significant bit
%   errcnt   -   Number of errors detected in error-protected frame
%   ethrs    -   Very high error rate threshold (approx 5%)
%   ethrs1   -   Low error rate threshold (approx 0.1%)
%   ethrs2   -   Medium error rate threshold (approx 1%)
%   ethrs3   -   High error rate threshold (approx 2%)
%   i,i1,i2, -   Integer temporary variables
%   i4
%
% TABLES
%   ivtab    -   All logical flow information for this routine (ICORF)
%   corth    -   Smoothing threshold table, one row per error rate class
%   detau    -   Pitch decoding table
%   detab7   -   Table for inverse LAR decoding of RC1 and RC2
%   descl    -   Table of scale factors for each of the last eight RCs
%   deadd    -   Table of biases of the probability density functions for
%                each of the last eight RCs
%   qb       -   Quantization bias table of last eight RCs
%   nbit     -   Number of bits in each of the RCs
%   zrc      -   Zero-forcing table for RC5 through RC10
%   abit     -   Bit position pointers
%   rmst     -   Energy decoding table
%
% ******************************************************************

function [ voice, pitch, rms, rc ] = lpcdecode( ipitv, irms, irc, pitch )

% DECLARE GLOBAL TABLES
global ivtab corth detau detab7 descl deadd qb nbit zrc abit rmst;

% DECLARE GLOBAL VARIABLES
global drc dpit drms ivp2h erate iovoic first;

% DECLARE GLOBAL CONSTANTS
global ORDER;

% INIT LOCAL VARIABLES
fut = 1;
pres = 2;
past = 3;
iavgp = 60;
ethrs = 2048;
ethrs1 = 128;
ethrs2 = 1024;
ethrs3 = 2048;
voice = zeros(2,1);

% IF NO ERROR CORRECTION, DO PITCH AND VOICING THEN JUMP TO DECODE
i4 = detau(ipitv+1);

% DO ERROR CORRECTION PITCH AND VOICING
if i4 > 4
    dpit(fut) = i4;
    ivoic = 2;
    iavgp = fix( ((15*iavgp)+i4+8) * 0.0625 );
else
    ivoic = i4;
    dpit(fut) = iavgp;
end
drms(fut) = irms;
drc(fut,1:ORDER) = irc(1:ORDER)';

% DETERMINE INDEX TO IVTAB FROM U/UV DECISION.  IF ERROR RATE IS HIGH
% USE ALTERNATE TABLE
index = (16*ivp2h) + (4*iovoic) + ivoic + 1;
i1 = ivtab(index);
ipit = rem(i1,4);
icorf = fix(i1*0.125);
if erate < ethrs
    icorf = fix(icorf*0.015625);
end

% DETERMINE ERROR RATE:  4 = HIGH,  1 = LOW
ixcor = 4;
if erate < ethrs3
    ixcor = 3;
end
if erate < ethrs2
    ixcor = 2;
end
if erate < ethrs1
    ixcor = 1;
end

% VOICE/UNVOICE DECISION DETERMINED FROM BITS 0 AND 1 OF IVTAB
voice(1) = rem(fix(icorf*0.5),2);
voice(2) = rem(icorf,2);

if first == 1

    % SKIP DECODING ON FIRST FRAME BECAUSE PRESENT DATA NOT YET AVAILABLE
    first = 0;
else

    % IF BIT 4 OF ICORF IS SET THEN CORRECT RMS AND RC1 - RC4.
    % DETERMINE ERROR RATE AND CORRECT ERRORS USING A HAMMING
    % 8,4 CODE DURING TRANSITION OR UNVOICED FRAMES.  IF IOUT
    % IS NEGATIVE, MORE THAN 1 ERROR OCCURRED, USE PREVIOUS
    % FRAME'S PARAMETERS.
    if rem(icorf,32)-rem(icorf,16) ~= 0
	errcnt = 0;
	lsb = rem(drms(pres),2);
	index = fix( (drc(pres,8)*16)+(drms(pres)*0.5) );
	[ iout, errcnt ] = ham84( index, errcnt );
	drms(pres) = drms(past);
	if iout >= 0
	    drms(pres) = (iout*2) + lsb;
	end
	for i = 1:4
	    if i == 1
		i1 = ( 2 * lpcbitand(drc(pres,9),7) ) + lpcbitand(drc(pres,10),1);
	    else
		i1 = lpcbitand(drc(pres,9-i),15);
	    end
	    i2 = lpcbitand(drc(pres,5-i),31);
	    lsb = lpcbitand(i2,1);
	    index = fix((16*i1)+(i2*0.5));
	    [ iout, errcnt ] = ham84( index, errcnt );
	    if iout >= 0
		iout = (iout*2) + lsb;
		if lpcbitand(iout,16) == 16
		    iout = iout - 32;
		end
	    else
		iout = drc(past,5-i);
	    end
	    drc(pres,5-i) = iout;
	end

	% DETERMINE ERROR RATE
	erate = (erate*0.96875) + (errcnt*102);
    end

    % GET UNSMOOTHED RMS, RC'S AND PITCH
    irms = drms(pres);
    irc(1:ORDER) = drc(pres,1:ORDER)';
    if ipit == 1
	dpit(pres) = dpit(past);
    end
    if ipit == 3
	dpit(pres) = dpit(fut);
    end
    pitch = dpit(pres);

    % IF BIT 2 OF ICORF IS SET THEN SMOOTH RMS AND RC'S
    if rem(icorf,8)-rem(icorf,4) ~= 0
	if (abs(drms(pres)-drms(fut))  >= corth(ixcor,2)) & ...
	   (abs(drms(pres)-drms(past)) >= corth(ixcor,2))
	    irms = median([drms(past),drms(pres),drms(fut)]);
	end
	for i=1:6
	    if (abs(drc(pres,i)-drc(fut,i))  >= corth(ixcor,i+2)) & ...
	       (abs(drc(pres,i)-drc(past,i)) >= corth(ixcor,i+2))
		irc(i) = median([drc(past,i),drc(pres,i),drc(fut,i)]);
	    end
	end
    end

    % IF BIT 3 OF ICORF IS SET THEN SMOOTH PITCH
    if rem(icorf,16)-rem(icorf,8) ~= 0
	if (abs(dpit(pres)-dpit(fut))  >= corth(ixcor,1)) & ...
	   (abs(dpit(pres)-dpit(past)) >= corth(ixcor,1))
	    pitch = median([dpit(past),dpit(pres),dpit(fut)]);
	end
    end
end

% IF BIT 5 OF ICORF IS SET THEN RC5 - RC10 ARE LOADED WITH
% VALUES SO THAT AFTER QUANTIZATION BIAS IS REMOVED IN DECODE
% THE VALUES WILL BE ZERO
if rem(icorf,64)-rem(icorf,32) ~= 0
    irc(5:ORDER) = zrc(5:ORDER);
end

% ONE FRAME DELAY
iovoic = ivoic;
ivp2h = voice(2);
dpit(past) = dpit(pres);
dpit(pres) = dpit(fut);
drms(past) = drms(pres);
drms(pres) = drms(fut);
drc(past,1:ORDER) = drc(pres,1:ORDER);
drc(pres,1:ORDER) = drc(fut,1:ORDER);

% DECODE RMS
irms = rmst( ((31-irms)*2) + 1 );

% DECODE RC1 AND RC2 FROM LOG-AREA-RATIOS, PROTECT FROM ILLEGAL
% CODED VALUE (-16) CAUSED BY BIT ERRORS
i2 = irc(1:2);
i1 = sign((2.*sign(i2))+1);
i2 = abs(i2);
fi = find(i2>15);
i2(fi) = zeros(length(fi),1);
i2 = detab7( (2 .* i2) + 1 );
i2 = i2 .* i1;
irc(1:2) = i2 .* ( 2 .^ (15-nbit(1:2)) );

% DECODE RC3 - RC10 TO SIGN PLUS 14-BITS
i2 = irc(3:ORDER);
i2 = i2 .* ( 2 .^ (15-nbit(3:ORDER)) );
i2 = i2 + qb(1:ORDER-2);
irc(3:ORDER) = fix( ( i2 .* descl(1:ORDER-2) ) + deadd(1:ORDER-2) );

% SCALE RMS AND RC'S TO REALS
rms = irms;
rc = irc .* (6.103515625e-5);



