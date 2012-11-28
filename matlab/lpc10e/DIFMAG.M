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
% DIFMAG
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 3-1-94
%
% ******************************************************************
%
% DESCRIPTION
%
% COMPUTE AVERAGE MAGNITUDE DIFFERENCE FUNCTION (AMDF)
%
% DESIGN NOTES
%
% TO COMPUTE THE BALANCED, DOWN-SAMPLED AMDF, USE:
%
% AMDF(TAU) = SUMMATION( |S(I)-S(I+TAU)| )
%
% EACH OF THE WINDOWS OF SAMPLES USED IN THE CALCULATION SLIDE IN
% OPPOSITE DIRECTIONS WITH RESPECT TO THE PITCH WINDOW CENTER. SPEECH
% IS DECIMATED 4:1, RESTRICTING THE BANDWIDTH OF THE COMPUTATION TO
% 1 KHZ AND SPEEDING THE CALCULATION. THE SUMMATION IS CHECKED FOR
% OVERFLOW AND CLAMPED. POINTERS ARE SET TO THE MINIMUM AND MAXIMUM
% OF THE AMDF.
%
% VARIABLES
%
%      amdf    -  average magnitude difference function (60 lags)
%      minptr  -  pointer to amdf min
%      maxptr  -  pointer to amdf max
%      speech  -  inverse filter output, 12-bit + sign
%      tau     -  log spaced table of lags
%      ltau    -  number of lags to compute
%      maxlag  -  maximum possible lag value
%      n1,n2   -  AMDF summation limits
%      AMDFacc -  AMDF summation accumulator
%      i,j     -  AMDF lag and summation indicies, respectively
%
% ******************************************************************

function [ amdf, minptr, maxptr ] = difmag( speech, tau, ltau, maxlag, amdf )
% DECLARE GLOBAL CONSTANTS
global MAXWIN;

% SET INITIAL CONDITIONS
minptr = 1;
maxptr = 1;

% COMPUTE ALL LAGS
for i = 1:ltau
    n1 = fix( ( maxlag - tau(i) ) * 0.5 ) + 1;
    n2 = n1 + MAXWIN - 1;
    ti = tau(i);
    AMDFacc = abs( speech( n1:4:n2 ) - speech( n1+ti:4:n2+ti ) );
    amdf(i) = sum( AMDFacc );
    if amdf(i) < amdf(minptr)
        minptr = i;
    end
    if amdf(i) > amdf(maxptr)
        maxptr = i;
    end
end


