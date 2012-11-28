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
% RCCHK
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 3-24-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Check Reflection Coefficients (RCs).  Repeat previous frame if unstable.
%
% DESIGN NOTES
%
% Any RC which approaches an absolute value of 1 too closely is judged
% to indicate that the filter is unstable.  Instabilities in LPC-10e
% are extremely rare, typcically occurring in the simulation at a rate
% of less than 1 in 3000 frames.   They do, however, cause the synthesizer
% to produce unnatural speech sounds, so the RC's of the previous frame
% are substituted.  This causes a slurring of speech, rather than an
% unnatural sound.
%
% See Also:  Version 52 release notes
%
% VARIABLES
%
% INPUTS
%   rc1f     -   Reflection coefficients, current plus 2 previous frames
%
% OUTPUTS
%   rc1f     -   Reflection coefficients, current plus 2 previous frames
%
% CONSTANTS
%   AF       -   Analysis frame buffer index
%
% ******************************************************************

function rc1f = rcchk( rc1f )

% DECLARE GLOBAL VARIABLES
global AF;

% FOR FRAMES CONTAINING INSTABILITIES, REPEAT RCS FROM PREVIOUS FRAME
if any( abs(rc1f(:,AF)) > 0.99 )
    rc1f(:,AF) = rc1f(:,AF-1);
end


