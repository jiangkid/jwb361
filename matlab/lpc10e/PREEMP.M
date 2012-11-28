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
% ******************************************************************
% PREEMP
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 2-21-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Preemphasis filter. Provides spectral whitening or flattening to
% improve speech signal suitability for LPC analysis.
%
% DESIGN NOTES
%
% This filter is poorly described in the documentation which accompanied
% the LPC 52 release.  It was an IIR filter at one time, with both poles
% and zeros but was modified to a simple FIR with no explanation.
% The version implemented here duplicates the LPC 55 source code filter,
% with 0.4 as the second tap.
%
% VARIABLES
%
% INPUTS
%   in              -   Input speech samples (-1.0 to 1.0)
%   coef            -   3rd FIR tap
%
% OUTPUTS
%   out             -   Preemphasized output samples (-1.0 to 1.0)
%
% INTERNALS
%   z               -   Filter memory, local copy
%   b, a            -   Filter taps
%   o               -   Filter output
%
% GLOBALS
%   zpre            -   Filter memory
%
% ******************************************************************

function out = preemp( in, coef )

% DECLARE GLOBALS
global zpre;

% INITIALIZE PREEMPHASIS TAPS - DUPLICATE LPC 55 SOURCE
b = [ 1.0, -1.0, coef ];
a = [ 1.0, 0.0, 0.0 ];

% APPLY PREEMPHASIS FILTER TO INPUT FRAME
[ o, z ] = filter( b, a, in, zpre );

% UPDATE FILTER MEMORY AND RETURN PREEMPHASIZED DATA
zpre = z;
out = o;
