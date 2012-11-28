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
% HAM84
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 3-30-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Implement Hamming 8,4 decoder. Correct one error bit out of seven
% or detect up to two errors.
%
% DESIGN NOTES
%
% Compute parity on incoming word.  Eliminate MSB (8th bit) and use
% remaining quantity to index into decoder table.  Finally, analyze
% errors.  Correct single bit errors, discard values with more than
% one bit error (set to -1).
%
% See Also:  Version 52 release notes
%
% VARIABLES
%
% INPUTS
%   input    -   Eight bit data word, 4 bits parameter info, 4 parity
%   errcnt   -   Present error count value
%
% OUTPUTS
%   output   -   Decoded parameter bits (corrected)
%   errcnt   -   Number of errors detected (up to 2)
%
% INTERNAL
%   parity   -   Computed parity - odd or even (1 or 0)
%   i        -   Table lookup temporary value
%   j        -   Bit 4 tester
%
% TABLES
%   dactab   -   Hamming 8,4 decoder lookup table
%
% ******************************************************************

function [ output, errcnt ] = ham84( input, errcnt )

% DECLARE GLOBAL TABLES
global dactab;

% DETERMINE PARITY OF INPUT WORD
parity = rem(sum(int2bin(input)),2);

% DO TABLE LOOKUP FOR DECODING
i = dactab( bin2int(int2bin(input)&[0,1,1,1,1,1,1,1]) + 1 );
output = rem(i,16);
j = rem(i,32) - output;

if j ~= 0
    % NO ERRORS DETECTED IN SEVEN BITS
    if parity ~= 0
        errcnt = errcnt + 1;
    end
else
    % ONE OR TWO ERRORS DETECTED
    errcnt = errcnt + 1;
    if parity == 0
        % TWO ERRORS DETECTED
        errcnt = errcnt + 1;
        output = -1;
    end
end