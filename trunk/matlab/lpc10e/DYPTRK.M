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
% DYPTRK
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 3-11-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Dynamic Pitch Tracker. Determines the transmitted pitch by
% performing a minimum cost search of the pitch over DEPTH previous
% frames.
%
% DESIGN NOTES
%
% See considerable discussion of dynamic programming algorithm in
% version 52 release notes.
%
% VARIABLES
%
% INPUTS
%   amdf   - Average Magnitude Difference Function array
%   minptr - Location of minimum AMDF value
%   voice  - Voicing decision
%
% OUTPUTS
%   pitch  - Smoothed pitch value, 2 frames delayed
%   midx   - Initial estimate of current frame pitch
%
% COMPILE TIME CONSTANTS
%   depth  - Number of frames to trace back
%   LTAU   - Number of lags in AMDF
%
% INTERNAL
%   sbar   - Value of imaginary ray
%   minsc  - Winner's minimum value
%   maxsc  - Winner's maximum value
%   alpha  - Confidence level of the AMDF minimum
%   pbar   - Index of imaginary ray
%   i,j    - loop indicies
%   iptr   - Current column of P (IPOINT+1)
%   path   - history
%   alphax - Scaled version of alpha
%   ipoint - Current frame position pointer
%
% ******************************************************************

function [ pitch, midx ] = dyptrk( amdf, minptr, voice )

% DECLARE GLOBAL VARIABLES
global LTAU alphax ipoint s p;

% DECLARE AND INITIALIZE LOCAL VARIABLES
depth = 2;

% CALCULATE THE CONFIDENCE FACTOR ALPHA, USED AS A THRESHOLD SLOPE IN
% SEESAW.  IF UNVOICED, SET HIGH SLOPE SO THAT EVERY POINT IN P ARRAY
% IS MARKED AS A POTENTIAL PITCH FREQUENCY.  A SCALED UP VERSION (ALPHAX)
% IS USED TO MAINTAIN ARITHMETIC PRECISION.
if voice == 1
    alphax = 0.75*alphax + amdf(minptr)*0.5;
else
    alphax = (0.984375)*alphax;
end
alpha = alphax*0.06250;

if (voice==0) & (alphax<128)
    alpha = 8;
end

% SEESAW: CONSTRUCT A PITCH POINTER ARRAY AND INTERMEDIATE WINNER FUNCTION
% LEFT TO RIGHT PASS
iptr = ipoint+1;
p(1,iptr) = 1;
i = 1;
pbar = 1;
sbar = s(1);
for i = 1:LTAU
    sbar = sbar + alpha;
    if sbar < s(i)
        s(i) = sbar;
        p(i,iptr) = pbar;
    else
        sbar = s(i);
        p(i,iptr) = i;
        pbar = i;
    end
end

% RIGHT TO LEFT PASS
i = pbar-1;
sbar = s(pbar);
while i >= 1
	sbar = sbar + alpha;
	if sbar < s(i)
		s(i) = sbar;
		p(i,iptr) = pbar;
	else
		pbar = p(i,iptr);
		i = pbar;
		sbar = s(i);
    end
	i = i-1;
end

% UPDATE S USING AMDF
% FIND MAXIMUM, MINIMUM, AND LOCATION OF MINIMUM
s = s + ( amdf .* 0.5 );
maxsc = max(s);
[ minsc, midx ] = min(s);

% SUBTRACT MINSC FROM S TO PREVENT OVERFLOW
s = s - minsc;
maxsc = maxsc - minsc;

% USE HIGHER OCTAVE PITCH IF SIGNIFICANT NULL THERE
j = 0;
for i = 20:10:40
    if midx > i
	    if s(midx-i) < maxsc*0.25
            j = i;
        end
    end
end
midx = midx - j;

% TRACE: LOOK BACK TWO FRAMES TO FIND MINIMUM COST PITCH ESTIMATE
j = ipoint;
pitch = midx;
for i = 1:depth
    j = rem(j,depth) + 1;
    pitch = p(pitch,j);
    path(i) = pitch;
end
ipoint = rem( ipoint+depth-1,depth );





