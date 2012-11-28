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
% BIN2INT
%
% DEVELOPED TO SUPPORT BITWISE OPERATIONS WHEN PORTING C TO MATLAB
%
% 3-30-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Obtain MATLAB scalar variable (integer) from an 8-bit,
% 2's Compliment binary representation, as provided by int2bin().
% Input is a 8-bit bit vector, output is a scalar integer.
%
% DESIGN NOTES
%
% Compute weighted sum of powers of two.  Incorporate 8-bit offset
% for negative values, assuming 2's Compliment input format.
%
% VARIABLES
%
% INPUTS
%   v        -   8-bit, 2's Compliment bit vector, MSB first
%
% OUTPUTS
%   i        -   Scalar integer output
%
% ******************************************************************
function i = bin2int( v )

% TEST FOR NEGATIVE INPUT VECTOR
if v(1) == 1
     offset = 256;
else
     offset = 0;
end

% COMPUTE WEIGHTED SUM, ADJUST FOR SIGN
i = sum( v .* (2 .^ (7:-1:0)) ) - offset;
