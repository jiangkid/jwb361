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
% HP100
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 2-14-94
%
% ******************************************************************
%
% DESCRIPTION
%
% 100 Hz High Pass Filter
%
% DESIGN NOTES
%
% Implemented as a 2-stage cascade.
% Tap values and gain have been taken from LPC-55 source code.
%
% VARIABLES
%
% INPUTS
%   input      -   Input speech samples (-1.0 to 1.0)
%
% OUTPUTS
%   output     -   Output speech samples (-1.0 to 1.0)
%
% INTERNALS
%   a1, b1     -   Stage 1 filter taps
%   a2, b2     -   Stage 1 filter taps
%   regs1      -   Filter memory temp storage
%   regs2      -   Filter memory temp storage
%   o1         -   Stage 1 output
%   o2         -   Stage 2 output
%
% GLOBALS
%   hp100z1    -   Filter memory, stage 1
%   hp100z2    -   Filter memory, stage 2
%
% ******************************************************************

function output = hp100( input )

% DECLARE GLOBAL VARIABLES
global hp100z1 hp100z2;

% INITIALIZE FILTER TAPS
b1 = [ 1.0, -2.0, 1.0 ];
a1 = [ 1.0, -1.859076, 0.8648249 ];
b2 = [ 1.0, -2.0, 1.0 ];
a2 = [ 1.0, -1.935715, 0.9417004 ];

% FILTER THE INPUT FRAME
[ o1, regs1 ] = filter( b1, a1, input, hp100z1 );
[ o2, regs2 ] = filter( b2, a2, o1, hp100z2 );

% RETAIN FILTER MEMORY FOR NEXT FRAME
hp100z1 = regs1;
hp100z2 = regs2;

% SCALE BY GAIN TERM
output = 0.902428 .* o2;
