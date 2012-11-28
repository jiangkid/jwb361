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
% DCBIAS
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 3-14-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Removes the short-term DC bias from a segment of speech by
% averaging samples in the current analysis window.
%
% DESIGN NOTES
%
% See:  Version 52 release notes.
%
% VARIABLES
%
% INPUTS
%   len      -   Length of input speech segment (biased speech)
%   speech   -   Buffer of input samples
%
% OUTPUTS
%   sigout   -   Buffer of output speech (unbiased speech)
%
% INTERNAL
%   bias     -   Computed estimate of short-term DC bias
%
% ******************************************************************

function sigout = dcbias( len, speech )

% COMPUTE SHORT-TERM DC BIAS
bias = mean( speech );

% SUBTRACT FROM SPEECH AND RETURN
sigout = speech - bias;

