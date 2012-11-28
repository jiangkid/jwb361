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
% LPC10
%
% NSA LPC-10 VOICE CODER
%
% PORTED TO MATLAB FROM NSA LPC-55 C RELEASE
% 2-14-94
%
% THIS LPC-10e SOFTWARE WAS PORTED FROM 'C' TO MATLAB BY TED PAINTER 
% AT ASU DURING THE SPRING OF 1994.
%
% ******************************************************************
%
% DESCRIPTION
%
% LPC-10 simulation, including analysis, transmission, synthesis,
% and graphical user interface (GUI).  Operates on .WAV speech data files.
%
% DESIGN NOTES
%
% With the exception of a graphical user interface (gui), this
% simulation has been ported from the NSA version of LPC-10e, LPC-55-C,
% available in source code form via Internet anonymous ftp@super.org.
% All MATLAB code has been optimized ("vectorized") to run in the
% MATLAB environment where possible.  For example, all for loops have
% been replaced with array-wise or column/row-wise operations,
% where possible. In addition, many operations which were done by
% loop based summations, such as filtering, have been replaced with
% calls to simple MATLAB built in functions.  These would include
% operations such as filter() and median(). With some work, it is probably
% still be possible to optimize some sections further.
%
% Given an identical input speech file, differences in LPC-10e MATLAB
% output when compared to UNIX-based LPC-10e output are due to
% floating point precision and resultant round-off differences. LPC-55-C
% has been written with single-precision floating point operations,
% whereas MATLAB floating point operations are, by definition, double
% precision.  The resulting "errors" are difficult to track, because
% the LPC all pole synthesis filter is recursive (IIR), and hence "errors"
% are cumulative.  One place in the simulation particularly sensitive to
% roundoff error is parameter quantization, where a small error
% at quantizer input can produce a very large error at quantizer output.
%
% For the most part, MATLAB .m files which form the body of this simulation
% follow the same name, purpose, and passing conventions as the C version,
% except for parameter encoding and decoding in the
% transmitter/receiver sections require some integer bitwise operations,
% which are not included in standard MATLAB.  Several .m functions have
% been added to compensate for the lack of bitwise operations and keep the
% coding as clear as possible.
%
% LPC10.M begins the simulation by calling init (which calls guiinit) to
% initialize all data structures and variables.
%
% ******************************************************************

% INITIALIZE SIMULATION VARAIBLES
init




