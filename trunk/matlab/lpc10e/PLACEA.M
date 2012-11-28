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
% PLACEA
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 3-12-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Place the analysis window based on the voicing window placement,
% onsets, tentative voicing decision, and pitch.
%
% DESIGN NOTES
%
% Case 1:  Sustained Voiced Speech
% If the five most recent voicing decisions are
% voiced, then the window is placed phase-synchronously with the
% previous window, as close to the present voicing window if possible.
% If onsets bound the voicing window, then preference is given to
% a phase-synchronous placement which does not overlap these onsets.
%
% Case 2:  Voiced Transition
% If at least one voicing decision in AF is voicied, and there are no
% onsets, then the window is placed as in case 1.
%
% Case 3:  Unvoiced Speech or Onsets
% If both voicing decisions in AF are unvoiced, or there are onsets,
% then the window is placed coincident with the voicing window.
%
% Note:  During phase-synchronous placement of windows, the length
% is not altered from MAXWIN, since this would defeat the purpose
% of phase-synchronous placement.
%
% See Also:  Version 52 release notes.
%
% VARIABLES
%
% INPUTS
%   ipitch   -   Initial pitch estimate for the analysis frame (AF)
%   voibuf   -   Buffer of voicing decisions
%   obound   -   Buffer of onset bounds (whether an onset occurs on 
%                each voicing window boundary)
%   vwin     -   Buffer of voicing window positions
%
% OUTPUTS
%   awin     -   Buffer of analysis window positions
%   ewin     -   Buffer of energy window positions
%
% COMPILE TIME CONSTANTS
%   AF       -   The analysis frame (3)
%   LFRAME   -   Length of a frame (180)
%   MAXWIN   -   Maximum window length (156)
%
% INTERNAL
%   ephase   -   TRUE if the energy window should be placed phase-
%                synchronously with the previous energy window.
%   allv     -   TRUE if the five most recent half-frame voicing
%                decisions are all voiced.
%   winv     -   TRUE if either of the two most recent half-frame
%                voicing decisions is voiced.
%   i,j,k,l  -   Counter indicies
%   temp     -   Intermediate result for nearest pitch multiple
%   delta    -   Used for analysis window bounds checking
%   lrange   -   Lower limit for placement of the analysis and energy
%                windows (181)
%   hrange   -   Upper limit for placement of the analysis and energy
%                windows (540)
%
% ******************************************************************

function [ awin, ewin ] = placea( ipitch, voibuf, obound, vwin, awin, ewin )

% DECLARE GLOBAL VARIABLES
global allv AF LFRAME MAXWIN

% DECLARE AND INITIALIZE LOCAL VARIABLES
lrange = ((AF-2)*LFRAME) + 1;
hrange = AF*LFRAME;
winv = 0;

% SETUP TO CHECK THREE CASES
allv = ( voibuf(2,AF-1) == 1 );
allv = allv & ( voibuf(1,AF) == 1 );
allv = allv & ( voibuf(2,AF) == 1 );
allv = allv & ( voibuf(1,AF+1) == 1 );
allv = allv & ( voibuf(2,AF+1) == 1 );
winv = ( voibuf(1,AF+1) == 1 ) |  ( voibuf(2,AF+1) == 1 );

% CASES 1 AND 2     
if allv | ( winv & (obound == 0) ) 

    % APHASE:  PHASE SYNCHRONOUS WINDOW PLACEMENT 
    % GET MINIMUM LOWER INDEX OF THE WINDOW                    
    i = fix( (lrange+ipitch-1-awin(1,AF-1))/ipitch );
    i = i * ipitch;
    i = i + awin(1,AF-1);

    % L = THE ACTUAL LENGTH OF THIS FRAME'S ANALYSIS WINDOW          
    % CALCULATE THE LOCATION WHERE A PERFECTLY CENTERED WINDOW WOULD START     
    l = MAXWIN;
    k = fix( (vwin(1,AF)+vwin(2,AF)+1-l) * 0.5 );

    % CHOOSE THE ACTUAL LOCATION TO BE THE PITCH MULTIPLE CLOSEST TO THIS    
    temp = fix( ((k-i)/ipitch)+.5 );
    awin(1,AF) = i + (temp*ipitch);
    awin(2,AF) = awin(1,AF) + l - 1;

    % IF THERE IS AN ONSET BOUNDING THE RIGHT OF THE VOICING WINDOW AND THE
    % ANALYSIS WINDOW OVERLAPS THAT, THEN MOVE THE ANALYSIS WINDOW BACKWARD
    % TO AVOID THIS ONSET     
    if ( obound >= 2 ) & ( awin(2,AF) > vwin(2,AF) ) 
        awin(1,AF) = awin(1,AF) - ipitch;
        awin(2,AF) = awin(2,AF) - ipitch;
    end        

    % SIMILARLY FOR THE LEFT OF THE VOICING WINDOW            
    if ( (obound==1) | (obound==3) ) & ( awin(1,AF) < vwin(1,AF) )   
        awin(1,AF) = awin(1,AF) + ipitch;
        awin(2,AF) = awin(2,AF) + ipitch;
    end

    % IF THIS PLACEMENT PUTS THE ANALYSIS WINDOW ABOVE HRANGE, THEN
    % MOVE IT BACKWARD AN INTEGER NUMBER OF PITCH PERIODS     
    delta = awin(2,AF) - hrange;
    if delta > 0
        delta = ipitch * (fix(delta/ipitch)+1);
        awin(1,AF) = awin(1,AF) - delta;
        awin(2,AF) = awin(2,AF) - delta;
    end

   % SIMILARLY IF THE PLACEMENT PUTS THE ANALYSIS WINDOW BELOW LRANGE       
    delta = awin(1,AF) - lrange;
    if delta < 0
        delta = ipitch * (fix(delta/ipitch)+1);
        awin(1,AF) = awin(1,AF) - delta;
        awin(2,AF) = awin(2,AF) - delta;
    end

   % MAKE ENERGY WINDOW BE PHASE-SYNCHRONOUS           
   ephase = 1;
else  
   
   % CASE 3          
   awin(1,AF) = vwin(1,AF);
   awin(2,AF) = vwin(2,AF);
   ephase = 0;
end

% RMS IS COMPUTED OVER AN INTEGER NUMBER OF PITCH PERIODS IN THE ANALYSIS
% WINDOW.  WHEN IT IS NOT PLACED PHASE-SYNCHRONOUSLY, IT IS PLACED AS CLOSE 
% AS POSSIBLE TO ONSETS     
j = fix( (awin(2,AF)-awin(1,AF)+1)/ipitch ) * ipitch;
if (j==0) | (winv==0)
    ewin(1,AF) = vwin(1,AF);
    ewin(2,AF) = vwin(2,AF);
else     
    if (ephase==0) & (obound==2)
        ewin(1,AF) = awin(2,AF) - j + 1;
        ewin(2,AF) = awin(2,AF);
    else    
        ewin(1,AF) = awin(1,AF);
        ewin(2,AF) = awin(1,AF) + j - 1;
    end
end
