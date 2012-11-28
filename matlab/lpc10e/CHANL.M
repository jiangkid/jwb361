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
% CHANL
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 3-30-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Duplicate the channel effects built-in to LPC-55 C implementation.
% All reflection coefficient quantized parameters are sign extended,
% given their bit allocations.
%
% DESIGN NOTES
%
% Sign extension takes into account the actual bit allocation.  For
% example, a 3-bit quantized parameter is sign extended from the 3rd
% bit on up.  The MATLAB version must duplicate the behavior of 2s
% complement encoding in the C version.  This is complicated by the
% fact that all MATLAB variables are floating point.
%
% Unlike the C implementation, which packs 54 bits per frame into
% a bitwise buffer, this implementation only duplicates the channel
% output for a given channel input.  The intermediate bit packing
% (Parallel to serial at transmitter) and bit unpacking (Serial to
% parallel at receiver) have been omitted for simplicity.  Bitwise
% manipulation in MATLAB becomes very clumsy because of the floating
% point representation and the lack of bitwise operators.
%
% The important fact is that this channel will produce identical output
% to the C implementation for a given channel input.
%
% See Also:  Version 52 release notes
%
% VARIABLES
%
% INPUTS
%   irc      -   Integer reflection coefficients
%
% OUTPUTS
%   irc      -   Sign extended integer reflection coefficients
%
% INTERNAL
%   t        -   Temp vector for sign extending RCs
%   ti       -   Index vector for RCs to be sign extended
%
% ******************************************************************

function irc = chanl( irc )

% SIMULATE THE EFFECT OF THE CHANNEL BUILT IN TO THE C IMPLEMENTATION
% BY SIGN EXTENDING VALUES, GIVEN THEIR BIT ALLOCATION

% SIGN EXTEND 5-BIT PARAMETERS
t = irc(1:4);
ti = find( t >= 16 );
t(ti) = t(ti) - 32;
irc(1:4) = t;

% SIGN EXTEND 4-BIT PARAMETERS
t = irc(5:8);
ti = find( t >= 8 );
t(ti) = t(ti) - 16;
irc(5:8) = t;

% SIGN EXTEND 3-BIT PARAMETERS
t = irc(9:10);
ti = find( t >= 4 );
t(ti) = t(ti) - 8;
irc(9:10) = t;


