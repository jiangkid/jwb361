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
% BUFMAN
%
% MATLAB REVISION HISTORY
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 4-7-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Speech sequence buffer management.  Used to match irregular
% sized synthesizer output frames to a 180-sample per frame
% output rate.
%
% DESIGN NOTES
%
% Implements circular buffering as in LPC-55 C
%
% VARIABLES
%
% INPUTS
%   InBuf    -   Incoming speech data (LPC synthesizer output)
%   len      -   Number of incoming samples
%
% OUTPUTS
%   OutBuf   -   Next 180 samples of output speech
%
% INTERNAL
%   BigBuf   -   Circular buffer of output speech
%
% ******************************************************************

function OutBuf = bufman( InBuf, len )

% DECLARE GLOBALS
global BigBuf sPtr ePtr BBUFSIZE LFRAME;

% INIT LOCAL VARIABLES
OutBuf = zeros( LFRAME, 1 );

% LOAD NEW SPEECH INTO CIRCULAR BUFFER
if ePtr+len-1 > BBUFSIZE
    b = BBUFSIZE - ePtr + 1;
    BigBuf(ePtr:BBUFSIZE) = InBuf(1:b);
    BigBuf(1:len-b) = InBuf(b+1:len);
    ePtr = len-b+1;
else
    BigBuf(ePtr:ePtr+len-1) = InBuf(1:len);
    ePtr = ePtr+len;
end

% COPY NEXT LFRAME OUTPUT SAMPLES TO THE OUTPUT BUFFER
if sPtr+LFRAME-1 > BBUFSIZE
    b = BBUFSIZE - sPtr + 1;
    OutBuf(1:b) = BigBuf(sPtr:BBUFSIZE);
    OutBuf(b+1:LFRAME) = BigBuf(1:LFRAME-b);
    sPtr = LFRAME-b+1;
else
    OutBuf = BigBuf(sPtr:sPtr+LFRAME-1);
    sPtr = sPtr+LFRAME;
end


