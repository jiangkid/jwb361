% MATLAB SIMULATION OF FS-1015 LPC-10e
% COPYRIGHT (C) 1996-99 ANDREAS SPANIAS and TED PAINTER
%
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
%
% MATLAB is trademark of The Mathworks Inc
%
% ALL DERIVATIVE WORKS MUST INCLUDE THIS COPYRIGHT NOTICE.
%
% ******************************************************************
%
% ENCODE
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 3-28-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Encode and quantize LPC parameters for transmission in standard LPC
% bit format.
%
% DESIGN NOTES
%
% First convert input real RMS and RC values to integers.  Pitch is
% encoded by the following rules: For a fully voiced frame (v1=v2=1),
% ipitch is obtained by table lookup from table entau, using pitch as
% the index.  If a frame is fully unvoiced then ipitch is set to 0.
% If the frame is a voicing transition frame and we are error correcting
% ipitch is set to 127.  If the frame is a transition and we are not
% error correcting then ipitch is set to 1 for a transition to voiced and
% 2 for a transition to unvoiced.
%
% Second, encode RMS by a binary table search of the rmst table.
%
% Third, encode RC1 and RC2 as log-area-ratios by table lookup into entab6.
%
% Fourth, linearly encode RC3 through RC10.
%
% Finally, apply error protection during unvoiced frames to the most
% significant bits of the most important parameters.
%
% See Also:  Version 52 release notes
%
% VARIABLES
%
% INPUTS
%   voice    -   Half frame voicing decisions (2)
%   pitch    -   Pitch index
%   rms      -   RMS energy
%   rc       -   Reflection coefficients
%
% OUTPUTS
%   ipitch   -   Quantized pitch index
%   irms     -   Quantized energy
%   irc      -   Quantized reflection coefficients (10)
%
% INTERNAL
%   j        -   RMS binary search place holder
%   idel     -   RMS binary search step size
%   i2       -   Integer temporary value
%   mrk      -   Sign vector
%   p        -   Parity encoding lookup index
%   q        -   Intermediate values for lookup computation, parity bits
%   qi       -   Index vector for lookup computation, parity bits
%
% TABLES
%   enctab   -   Error protection lookup table for RC parity bits
%   entau    -   Pitch lookup table
%   rmst     -   RMS energy lookup table
%   enadd    -   RC3-RC10 linear encoding offset lookup table
%   enscl    -   RC3-RC10 linear encoding scaling lookup table
%   entab6   -   RC1-RC2 log-area-ratio lookup table
%   enbits   -   Bit allocation table for RC encoding
%
% ******************************************************************

function [ ipitch, irms, irc ] = lpcencode( voice, pitch, rms, rc )

% DECLARE GLOBAL TABLES
global entau rmst entab6 enadd enbits enscl enctab;

% SCALE RMS AND RCS TO INTEGERS
irms = fix( rms );
irc = fix( rc .* 32768 );

% ENCODE PITCH AND VOICING
if all( voice )
    ipitch = entau( pitch );
else
    ipitch = 0;
    if voice(1) ~= voice(2)
        ipitch = 127;
    end
end

% ENCODE RMS BY BINARY TABLE SEARCH
j = 32;
idel = 16;
irms = min( [irms,1023] );
while idel > 0
    if irms > rmst(j)
        j = j - idel;
    end
    if irms < rmst(j)
        j = j + idel;
    end
    idel = fix( idel * 0.5 );
end
if irms > rmst(j)
    j = j - 1;
end
irms = fix( 31 - (j*0.5) );

% ENCODE RC1 AND RC2 AS LOG-AREA-RATIOS
i2 = irc(1:2);
mrk = sign((2.*sign(i2))+1);
i2 = abs( fix( i2 ./ 512 ) );
i2 = min([ i2'; 63,63 ])';
i2 = entab6(i2+1);
irc(1:2) = i2 .* mrk;

% ENCODE RC3, RC4, ..., RC10 LINEARLY, REMOVE BIAS, THEN SCALE
i2 = fix( irc(3:10) ./ 2 );
i2 = ( i2+enadd(8:-1:1) ) .* enscl(8:-1:1);
i2 = max([i2';-127+zeros(1,8)]);
i2 = min([i2;127+zeros(1,8)])';
mrk = i2 < 0;
i2 = fix( i2 ./ ( 2 .^ enbits(8:-1:1) ) );
i2 = i2 - mrk;
irc(3:10) = i2;

% PROTECT THE MOST SIGNIFICANT BITS OF THE MOST IMPORTANT PARAMETERS
% DURING NON-VOICED FRAMES.  RC1 THROUGH RC4 ARE PROTECTED USING
% 20 PARITY BITS, REPLACING RC5 - RC10.
if (ipitch==0) | (ipitch==127)
    q = [irc(1:3);irms;irc(4);irc(4)];
    
    % CORRECT FOR 2S COMPLEMENT (IN C VERSION) ENCODING OF NEGATIVE VALS 
    qi = find(q<0);
    q(qi) = q(qi) + 32;
    p = fix( (q-rem(q,2)) / 2 ) + 1;
    irc(5:10) = enctab(p);
    irc(9) = fix( irc(9) / 2 );
    irc(10) = rem( irc(10), 2 );
end

