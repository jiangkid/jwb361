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
% GUIINIT
%
% NSA LPC-10 VOICE CODER GRAPHICAL USER INTERFACE (GUI)
%
% 4-28-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Create base window for current GUI phase.
%
% DESIGN NOTES
%
% This function switches on the value of guiPhase:
%   0 = Startup configuration window - Y/N query for runtime graphical output
%   1 = Runtime output window - either graphical plots or text status
%   2 = Termination window with OK button
%
% VARIABLES
%
% INPUTS
%   guiPhase   -   Current phase of GUI operation (start, runtime, termination)
%
% OUTPUTS
%   Creates output window with text and axes, ready for data.
%
% INTERNALS
%   NameStr    -   Output window title string
%   FileStr    -   Output window filename string
%   StatStr    -   Output window status string - frame number
%   EndStr     -   Simulation termination string
%   WSstr      -   White space string for screen formatting
%   L1STR      -   Output window title string
%   L2STR      -   Output window subtitle string
%   PSTR       -   Percent complete string
%   guiPax     -   Object handle percent complete axes
%   f1         -   Object handle for startup window
%   hh         -   Object handle for miscellaneous window objects
%   YesButton  -   Object handle for startup YES button
%   NoButton   -   Object handle for startup NO button
%   OKButton   -   Object handle for OK termination button
%   ss         -   Screen size vector for host machine
%   xorg       -   Host machine screen X axis origin for output window
%   yorg       -   Host machine screen Y axis origin for output window
%   x          -   X coordinates for percentage complete rectangle
%   y          -   Y coordinates for percentage complete rectangle
%   F1POS      -   Output window location in screen pixels
%
% GLOBALS
%   guiState   -   Graphical output or status output mode
%                  0 = status mode (non-interactive), 1 = graphics mode
%   guiF1      -   Output window object handle
%   guiSline   -   Status output text object handle
%   guiIfile   -   Input file name
%   guiOfile   -   Output file name
%   FrameCnt   -   Number of frames processed so far
%
% CONSTANTS
%    L1POS     -   Text line 1 position in output window (pixels)
%    L2POS     -   Text line 2 position in output window (pixels)
%    L3POS     -   Text line 3 position in output window (pixels)
%    PPOS      -   Percent complete bar graph position
%    FILEPOS   -   File name message position
%    ENDPOS    -   Termination message position
%    OKPOS     -   OK button position in termination window
%    YESPOS    -   Yes button position in startup window
%    NOPOS     -   No button position in startup window
%
% ******************************************************************

function guiinit( guiPhase )

% DECLARE GUI GLOBALS
global guiState guiF1 guiSline FrameCnt guiIfile guiOfile;


cWIN = 'k';

% INITIALIZE GRAPHICAL OBJECT POSITIONS
L1POS = [110,300,400,50];
L2POS = [110,270,400,50];
L3POS = [100,210,400,20];
PPOS = [0.15,0.35,0.7,0.05];
FILEPOS = [5,30,600,20];
ENDPOS = [110,150,400,20];
OKPOS = [285,100,50,30];

% COMPUTE WINDOW POSITIONS BASED ON SCREEN DIMENSIONS
ss = get( 0, 'ScreenSize' );
xorg = ( ss(3) - 600 ) / 2;
yorg = ( ss(4) - 400 ) / 2;
F1POS = [ xorg yorg 600 400 ];

% INITIALIZE TEXT OBJECTS
NameStr = 'NSA LPC-10e VOCODER SIMULATION ';
WSstr = '                                                         ';
QueryStr = 'Is graphical output desired?';
EndStr = sprintf( 'LPC-10e Simulation Complete.  Processed %3d Frames.', FrameCnt );
FileStr = sprintf( 'Input File: %12s%sOutput File: %12s', guiIfile, WSstr, guiOfile );
StatStr = sprintf( 'Processing Frame #%4d', FrameCnt );
L1STR = NameStr;
L2STR = 'FEDERAL STANDARD 1015';
PSTR = 'Percent Complete (%)';

% CREATE BASE WINDOW FOR CURRENT PHASE
% 0 : STARTUP PHASE - Y/N QUERY WINDOW
if guiPhase == 0
    cr;
    guiState = 0;

% 1 : RUNTIME PHASE - EITHER TEXTUAL STATUS OR GRAPHICAL DATA DISPLAY
elseif guiPhase == 1

    % CREATE WINDOW AND TEXT OBJECTS
    guiF1 = figure( 'Position', F1POS, 'number', 'off', 'name', ...
                     NameStr, 'resize', 'off', 'Menubar', 'none', 'color', cWIN  );
    clf;
    hh=uicontrol('style','text','string',L1STR,'position', L1POS);
    set(hh,'backg',get(gcf,'color'),'foreg',[1,1,1]-get(gcf,'color'));
    hh=uicontrol('style','text','string',L2STR,'position',L2POS);
    set(hh,'backg',get(gcf,'color'),'foreg',[1,1,1]-get(gcf,'color'));
    hh=uicontrol('style','text','string',FileStr,'position',FILEPOS);
    set(hh,'backg',get(gcf,'color'),'foreg',[1,1,1]-get(gcf,'color'));
    guiSline=uicontrol('style','text','string',StatStr,'position',L3POS);
    set(guiSline,'backg',get(gcf,'color'),'foreg',[1,1,1]-get(gcf,'color'));

    % CREATE COMPLETION BAR GRAPH
    guiPax = axes('position',PPOS);
    x=[ 0,0,0,0 ];
    y=[ 0,1,1,0];
    fill(x,y,'b');
    xlabel(PSTR);
    axis([0,100,0,1.0]);
    set(guiPax,'box','off','yticklabel','');
    hold on
    drawnow;


% 2 : TERMINATION PHASE - INDICATE NUMBER OF FRAMES PROCESSED AND OK BUTTON
else

    % FIRST, CLOSE RUNTIME WINDOW
    close;

    % CREATE TERMINATION WINDOW
    guiF1 = figure( 'Position', F1POS, 'number', 'off', 'name', NameStr, ...
                    'resize', 'off', 'Menubar', 'none', 'color', cWIN  );
    clf;

    % DISPLAY STANDARD VOCODER TEXT MESSAGES
    hh=uicontrol('style','text','string',L1STR,'position', L1POS);
    set(hh,'backg',get(gcf,'color'),'foreg',[1,1,1]-get(gcf,'color'));
    hh=uicontrol('style','text','string',L2STR,'position',L2POS);
    set(hh,'backg',get(gcf,'color'),'foreg',[1,1,1]-get(gcf,'color'));
    hh=uicontrol('style','text','string',FileStr,'position',FILEPOS);
    set(hh,'backg',get(gcf,'color'),'foreg',[1,1,1]-get(gcf,'color'));

    % DISPLAY TERMINATION MESSAGE AND OK BUTTON
    hh=uicontrol('style','text','string',EndStr,'position',ENDPOS);
    set(hh,'backg',get(gcf,'color'),'foreg',[1,1,1]-get(gcf,'color'));
    OKButton = uicontrol('Style','Pushbutton','Position',OKPOS,'Callback',...
    'close;','String','OK');
end



