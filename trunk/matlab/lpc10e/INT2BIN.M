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
% INT2BIN
%
% DEVELOPED TO SUPPORT BITWISE OPERATIONS WHEN PORTING C TO MATLAB
% 3-30-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Obtain 8-bit, 2's Compliment binary representation for an integer
% MATLAB variable. Input is an integer, output is a vector of 8 bits.
%
% DESIGN NOTES
%
% Use modulo division in place of bit mask, which would have been
% available in C.  Encode negative values in 2's Compliment, as
% is done with most C compilers.
%
% SEE ALSO:  BIN2INT
%
% VARIABLES
%
% INPUTS
%   a        -   Input integer (Actually double float in MATLAB)
%
% OUTPUTS
%   bv       -   8-bit, 2's Compliment bit vector, MSB first
%
% ******************************************************************

function bv = int2bin( a )

% CONVERT USING MODULO DIVISION FOR BITMASK
% MASK HIGH BITS, THEN SUBTRACT REMAINING BITS
% CONVERT NEGATIVE VALUES TO 2'S COMP
if a >= 0
     bv = sign(rem(a,2.^(8:-1:1))-rem(a,2.^(7:-1:0)));
else
     a = a + 1;
     bv = ~sign(rem(a,2.^(8:-1:1))-rem(a,2.^(7:-1:0))); 
end
