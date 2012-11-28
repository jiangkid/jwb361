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
% PLACEV
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 2-24-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Places voicing window somewhere within three frame input buffer.
% There are three cases, described both in the LPC10-55 source code
% and in the LPC10 documentation (1987).
%
% Unfortunatly, neither description is very clear. It is included
% here.
%
% DESIGN NOTES
%         __________________ __________________ ______________
%        |                  |                  |
%        |        1F        |        2F        |        3F ...
%        |__________________|__________________|______________
%
%    Previous |
%      Window |
%  ...________|
%
%             |                                |
%      ------>| This window's placement range  |<------
%             |                                |
%
%   There are three cases.  Note that these are different from those
%   given in the LPC-10e phase 1 report.
%
%   1.  If there are no onsets in this range, then the voicing window
%   is centered in the pitch window.  If such a placement is not within
%   the window's placement range, then the window is placed in the left-
%   most portion of the placement range.  Its length is always MAXWIN.
%
%   2.  If the first onset is in 2F and there is sufficient room to place
%   the window immediately before this onset, then the window is placed
%   there, and its length is set to the maximum possible under these
%   constraints.
%
%       "Critical Region Exception":  If there is another onset in 2F
%       such that a window can be placed between the two onsets, the
%       window is placed there (ie, as in case 3).
%
%   3.  Otherwise, the window is placed immediately AFter the onset.  The
%   window's length
%   is the longest length that can fit in the range under these constraints,
%   except that the window may be shortened even further to avoid overlapping
%   other onsets in the placement range.  In any case, the window's length
%   is at least MINWIN.
%
%   Note that the values of MINWIN and LFRAME must be chosen such
%   that case 2 = false implies case 3 = true.   This means that
%   MINWIN <= LFRAME/2.  If this were not the case, then a fourth case
%   would have to be added for when the window cannot fit either before
%   or AFter the onset.
%
%   Note also that onsets which weren't in 2F last time may be in 1F this
%   time, due to the filter delays in computing onsets.  The result is that
%   occasionally a voicing window will overlap that onset.  The only way
%   to circumvent this problem is to add more delay in processing input
%   speech.  In the trade-off between delay and window-placement, window
%   placement lost.
%
%
% VARIABLES
%
%      osbuf    Buffer which holds sorted indexes of onsets
%      osptr    Free pointer into OSBUF
%      vwin         Buffer of Voicing Window Positions (Modified)
%      obound   This variable is set by this procedure and used
%                       in placing analysis windows (PLACEA).  Bit 1
%                       indicates whether an onset bounds the left side
%                       of the voicing window, and bit 2 indicates whether
%                       an onset bounds the right side of the voicing window.
%      osptr1   OSPTR excluding samaples in 3F
%      lrange   Range in which window is placed
%      hrange
%
% ******************************************************************

function [ obound, vwin ] = placev( osbuf, osptr, vwin )

% DECLARE ALL GLOBAL CONSTANTS
global LFRAME AF;

% INITIALIZE LOCAL CONSTANTS
DVWINL      = 307;
DVWINH      = 462;
MINWIN      = 90;
MAXWIN      = 156;

% INITIALIZE LOCAL VARIABLES
lrange = max( [ vwin(2,AF-1)+1, ((AF-2)*LFRAME)+1 ] );
hrange = AF*LFRAME;

% COMPUTE THE PLACEMENT RANGE
% COMPUTE OSPTR1, SO THE FOLLOWING CODE ONLY LOOKS AT RELEVANT ONSETS
osptr1 = osptr-1;
while osptr1 >= 1
    if osbuf(osptr1) <= hrange, break, end
    osptr1 = osptr1-1;
end
osptr1 = osptr1+1;
% CHECK FOR CASE 1 FIRST (FAST CASE) 
if osptr1 <= 1 
    vwin(1,AF) = max( [ vwin(2,AF-1)+1, DVWINL ] );
    vwin(2,AF) = vwin(1,AF) + MAXWIN - 1;
    obound = 0;
elseif osbuf( osptr1-1 ) < lrange 
    vwin(1,AF) = max( [ vwin(2,AF-1)+1, DVWINL ] );
    vwin(2,AF) = vwin(1,AF) + MAXWIN - 1;
    obound = 0;
else
    % SEARCH BACKWARD IN OSBUF FOR FIRST ONSET IN RANGE.  THIS CODE RELIES
    % ON THE CASE 1 CHECK BEING PERFORMED FIRST.
    q = osptr1-1;
    while q >= 1
	if osbuf(q) < lrange, break, end
	q = q-1;        
    end
    q = q+1;
    % CHECK FOR CASE 2 (PLACEMENT BEFORE ONSET)
    % CHECK FOR CRITICAL REGION EXCEPTION
    crit = 0;
    i = q+1;
    while i <= osptr1-1
	if ( osbuf(i) - osbuf(q) ) >= MINWIN
	    crit = 1;
	    break;
	end
	i = i+1;
    end
    if ( crit ~= 1 ) & ( osbuf(q) > max([(AF-1)*LFRAME,lrange+MINWIN-1]) )
	vwin(2,AF) = osbuf(q) - 1;
	vwin(1,AF) = max([lrange, vwin(2,AF)-MAXWIN+1]);
	obound = 2;
    % CASE 3 (PLACEMENT AFTER ONSET)
    else
	vwin(1,AF) = osbuf(q);
	q = q+1;
	Vmax = vwin(1,AF) + MAXWIN;
	Vmin = vwin(1,AF) + MINWIN;
	while ( q<osptr1 ) & ( osbuf(q)<=Vmax ) & ( osbuf(q)<Vmin )
	    q = q+1;
	end
	if q < osptr1
	    if osbuf(q) <= Vmax
		vwin(2,AF) = osbuf(q) - 1;
		obound = 3;
	    else
		vwin(2,AF) = min( [vwin(1,AF)+MAXWIN-1,hrange] );
		obound = 1;
	    end
	else
	    vwin(2,AF) = min( [vwin(1,AF)+MAXWIN-1,hrange] );
	    obound = 1;
	end
    end
end


