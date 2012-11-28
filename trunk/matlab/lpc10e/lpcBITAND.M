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
% BITAND
%
% DEVELOPED TO SUPPORT BITWISE OPERATIONS WHEN PORTING C TO MATLAB
% 3-30-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Compute bitwise AND (like C '&' operator) for two 8-bit integers
%
% DESIGN NOTES
%
% Uses 8-bit integer to binary forward/backward conversions, int2bin 
% and bin2int.
%
% SEE ALSO:  BIN2INT, INT2BIN
%
% VARIABLES
%
% INPUTS
%   a, b       -   Input integers (Actually double floats in MATLAB)
%                  These are truncated to 8 bits.
%
% OUTPUTS
%   aandb      -   Output integer result, a & b.
%
% ******************************************************************

function aandb = lpcbitand( a, b )
aandb = bin2int( int2bin(a) & int2bin(b) );
