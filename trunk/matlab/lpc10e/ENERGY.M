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
% ENERGY
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 3-14-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Computes rms energy of speech segment.
%
% DESIGN NOTES
%
% See:  Version 52 release notes.
%
% VARIABLES
%
% INPUTS
%   len      -   Length of input speech segment (unbiased speech)
%   speech   -   Buffer of input samples
%
% OUTPUTS
%   rms      -   rms energy measure
%
% ******************************************************************

function rms = energy( len, speech )

% COMPUTE SHORT-TERM RMS ENERGY
rms = sqrt( sum( speech .* speech ) / len );


