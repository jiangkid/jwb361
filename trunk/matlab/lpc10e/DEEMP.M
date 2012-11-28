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
% DEEMP
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 4-7-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Output deemphasis filter
%
% DESIGN NOTES
%
% Uses IIR filter which is not documented in either the C source
% code or the v52 release notes.  This filter is some kind of all
% pole demphasis filter cascaded with some type of lowpass.
% The filter implemented here has been blindly copied from the
% filter used in the version 55 release.
%
% See Also:  Version 52 release notes
%
% VARIABLES
%
% INPUTS
%   x        -   Input speech from LPC synthesizer output
%
% OUTPUTS
%   x        -   Demphasized output speech
%
% INTERNAL
%   b        -   Demphasis numerator taps (zeros)
%   a        -   Demphasis denominator taps (poles)
%   Zdemph   -   Demphasis filter memory
%
% ******************************************************************

function x = deemp( x )

% DECLARE GLOBALS
global Zdemph;

% INITIALIZE DEEMPHASIS TAPS - DUPLICATE LPC 55 SOURCE
b = [ 1.0, -1.9998,      1,       0,      0 ];
a = [ 1.0, -2.7500, 2.9300, -1.4800, 0.3120 ];

% APPLY DEEMPHASIS FILTER TO INPUT SPEECH
[ x, Zdemph ] = filter( b, a, x, Zdemph );

