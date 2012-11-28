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
% GUISTAT
%
% NSA LPC-10 VOICE CODER GRAPHICAL USER INTERFACE (GUI)
%
% 4-28-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Updates simulation status information in status window during
% non-interactive simulations (no graphical output).
%
% DESIGN NOTES
%
% Computes percent complete in terms of frames remaining to be processed.
%
% VARIABLES
%
% INPUTS
%   none
%
% OUTPUTS
%   none
%
% INTERNALS
%   StatStr    -   Status string
%   Pcomp      -   Percent complete (simulation overall, in terms of frames)
%   px         -   Percent complete bar graph x boundaries
%   py         -   Percent complete bar graph y boundaries
%
% GLOBALS
%   guiSline   -   Handle for status line object
%   guiFrames  -   Total number of frames in input speech file
%   FrameCnt   -   Current frame number
%
% CONSTANTS
%    STATPOS   -   Status line position in status window
%
% ******************************************************************

function guistat

global guiSline FrameCnt guiFrames;

% ESTABLISH STATUS STRING POSITION IN STATUS WINDOW
STATPOS = [210,200,200,20];

% DELETE EXISTING STATUS AND OVERWRITE WITH NEW STATUS
delete(guiSline);
StatStr = sprintf( 'Processing Frame %3d of %3d', FrameCnt, guiFrames );
guiSline = uicontrol( 'style','text','string',StatStr,'position',STATPOS );

% SET DISPLAY ATTRIBUTES TO WHITE TEXT
set( guiSline,'backg',get(gcf,'color'),'foreg',[1,1,1]-get(gcf,'color') );
Pcomp = (FrameCnt/guiFrames) * 100;

% COMPUTE PERCENT COMPLETE AND UPDATE BAR GRAPH
px = [0,0,Pcomp,Pcomp];
py = [0,1,1,0];
fill(px,py,'b');
drawnow;