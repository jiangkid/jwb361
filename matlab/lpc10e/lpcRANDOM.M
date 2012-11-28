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
% RANDOM
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 4-6-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Generate a vector of random 16-bit integers, taken from a uniform
% distribution between -32768 and 32767.
%
% DESIGN NOTES
%
% See:  Knuth, Volume 2, page 27.
%
% VARIABLES
%
% INPUTS
%   none.
%
% OUTPUTS
%   the_random   -  An nrand element vector of random 16-bit integers,
%                   sample values of a random variable uniformly
%                   distributed between -32768 and 32767.
%
% ******************************************************************

function [ the_random ] = lpcrandom( nrand )

% DECLARE GLOBAL VARIABLES
global y j k;

% DECLARE GLOBAL CONSTANTS
global MAXTAP;

% INITIALIZE LOCALS
the_random = zeros( nrand, 1 );

% APPLY KNUTH RANDOM NUMBER GENERATOR NRAND TIMES TO BUILD RETURN VECTOR
for i = 1:nrand
    y(k) = y(k) + y(j);

    % SIMULATE 16-BIT TWO'S COMPLEMENT ADDITION
    if y(k) > 32767
        y(k) = y(k) - 65536;
    end
    if y(k) < -32768
        y(k) = y(k) + 65536;
    end

    % RETURN THE RESULT
    the_random(i) = y(k);

    % UPDATE ARRAY INDICIES
    k = k - 1;
    if k < 1
        k = MAXTAP;
    end
    j = j - 1;
    if j < 1
        j = MAXTAP;
    end
end




