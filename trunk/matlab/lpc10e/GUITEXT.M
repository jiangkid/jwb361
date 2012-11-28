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
% GUITEXT
%
% NSA LPC-10e GRAPHICAL USER INTERFACE (GUI)
%
% 8-25-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Display a text object in the current window at the specified
% position with the specified color scheme.
%
% DESIGN NOTES
%
% This routine is used by guiqual.m to generate the objective quality
% measurement window.
%
% VARIABLES
%
% INPUTS
%   pos        -   Desired text placement position
%   str        -   Text object to be placed in the window
%   bc         -   Desired background color
%   fc         -   Desired foreground color
%
% ******************************************************************

function guitext( pos, str, bc, fc )

uicontrol('style', 'text', 'position', pos, ...
          'string', str, 'backg',bc, 'foreg',fc,'horiz','left' );


