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
% LPFILT31
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 2-26-94
%
% ******************************************************************
%
% DESCRIPTION
%
% 31 POINT EQUIRIPPLE FIR LOW-PASS FILTER
%
% PASSBAND:  RIPPLE = 0.5 dB, CUTOFF =  800 HZ
% STOPBAND:  ATTEN  =  40 dB, CUTOFF = 1240 HZ
%
% DESIGN NOTES
%
% LPC55-C DOCUMENTATION DOES NOT INDICATE WHAT DESIGN METHOD WAS USED
% TO OBTAIN THE TAP WEIGHTS FOR THIS FILTER.
% THE OLD VERSION HAD BEEN OBTAINED USING PARKS-MCCLELLAN.
%
% VARIABLES
%
%      inbuf   -   input data, 12-bit + sign
%      lpbuf   -   filter output, 12-bit + sign
%      alpf31  -   H(Z) numerator, FIR tap weights (global)
%      blpf31  -   H(Z) denominator (global)
%      zlpf31  -   filter state (global)
%
% ******************************************************************

function [ lpbuf ] = lpfilt31( inbuf )

% DECLARE GLOBAL VARIABLES
global alpf31 blpf31 zlpf31;

% APPLY FILTER
[ lpbuf, zlpf31 ] = filter( blpf31, alpf31, inbuf, zlpf31 );

