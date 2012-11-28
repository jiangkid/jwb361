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
% IRC2PC
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 4-6-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Convert reflection coefficients to predictor (direct form)
% coefficients, using recursion relations.
%
% DESIGN NOTES
%
% See:  Version 52 release notes
%
% VARIABLES
%
% INPUTS
%   gprime   -   Excitation modification gain
%   rc       -   Reflection coefficients
%   where    -   Pitch epoch index
%
% OUTPUTS
%   g2pass   -   Excitation modification sharpening factor
%   pc       -   Predictor coefficients
%
% CONSTANTS
%   ORDER    -   Predictor order
%
% ******************************************************************

function [ pc, g2pass ] = irc2pc( rc, gprime, where )

% DECLARE GLOBAL CONSTANTS
global ORDER;

% INIT LOCAL VARIABLES
pc = zeros(ORDER,1);

% COMPUTE SHARPENING FACTOR
g2pass = gprime * sqrt( prod( 1 - ( rc(:,where) .* rc(:,where) ) ) );

% COMPUTE PREDICTOR COEFFICIENTS

% FIRST COEFFICIENT REQUIRES NO RECURSION
pc(1) = rc(1,where);

% RUN RECURSION RELATIONS TO OBTAIN REMAINING COEFFICIENTS
for i = 2:ORDER
    temp(1:i-1) = pc(1:i-1) - ( rc(i,where) .* pc(i-1:-1:1) );
    pc(1:i-1) = temp(1:i-1);
    pc(i) = rc(i,where);
end

