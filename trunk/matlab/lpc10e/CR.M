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

% ******************************************************************
%

function cr

% COMPUTE WINDOW POSITIONS BASED ON SCREEN DIMENSIONS
ss = get( 0, 'ScreenSize' );
xorg = ( ss(3) - 600 ) / 2;
yorg = ( ss(4) - 400 ) / 2;
F1POS = [ xorg yorg 600 400 ];

% INIT COPYRIGHT NOTICE POSITIONS AND TEXT
TOP = 360; W = 600; H = 20; COL1 = 70; COL2 = 80; COL3 = 90; COL4 = 170;
C1P = [COL4 TOP W H];
C2P = [COL2 TOP-H W H];
C3P = [COL1 TOP-3*H W H];
C4P = [COL1 TOP-4*H W H];
C5P = [COL1 TOP-5*H W H];
C6P = [COL1 TOP-6*H W H];
C7P = [COL1 TOP-7*H W H];
C8P = [COL1 TOP-8*H W H];
C9P = [COL1 TOP-9*H W H];
C10P = [COL1 TOP-10*H W H];
C11P = [COL1 TOP-11*H W H];
C12P = [COL1 TOP-12*H W H];
C13P = [COL3 TOP-15*H W H];
C14P = [COL1 TOP-13*H W H];
OKCPOS = [285,30,50,30];

NameStr = 'NSA FS-1015 LPC-10e';
C1S = 'MATLAB SIMULATION OF FS-1015 LPC-10e';
C2S = 'COPYRIGHT (C) 1994-99 ANDREAS SPANIAS & TED PAINTER';
C3S = 'This Copyright applies only to this particular MATLAB implementation';
C4S = 'of the LPC-10e coder.  The MATLAB software is intended only for educational';
C5S = 'purposes.  No other use is intended or authorized.  This is not a public';
C6S = 'domain program and unauthorized distribution to individuals or networks';
C7S = 'is prohibited. Be aware that use of the standard in any form is governed';
C8S = 'by rules of the US DoD.';
C9S = 'This program is free software. It is distributed in the hope that it will';
C10S = 'be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of';
C11S = 'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  There is no';
C12S = 'commitment or even implied commitment on behalf of Andreas Spanias or';
C14S = 'Ted Painter for maintenance or support of this code.';
C13S = 'ALL DERIVATIVE WORKS MUST INCLUDE THIS COPYRIGHT NOTICE.';


% CREATE COPYRIGHT WINDOW
guiF1 = figure( 'Position', F1POS, 'number', 'off', 'name', NameStr, ...
                'resize', 'off', 'Menubar', 'none' );
clf;

% DISPLAY COPYRIGHT NOTICE
set(gcf,'color','k');
guitext( C1P, C1S, 'k', 'w' );
guitext( C2P, C2S, 'k', 'w' );
guitext( C3P, C3S, 'k', 'w' );
guitext( C4P, C4S, 'k', 'w' );
guitext( C5P, C5S, 'k', 'w' );
guitext( C6P, C6S, 'k', 'w' );
guitext( C7P, C7S, 'k', 'w' );
guitext( C8P, C8S, 'k', 'w' );
guitext( C9P, C9S, 'k', 'w' );
guitext( C10P, C10S, 'k', 'w' );
guitext( C11P, C11S, 'k', 'w' );
guitext( C12P, C12S, 'k', 'w' );
guitext( C13P, C13S, 'k', 'w' );
guitext( C14P, C14S, 'k', 'w' );

% OK BUTTON
OKButton = uicontrol('Style','Pushbutton','Position',OKCPOS,'Callback',...
'close; lpcexec;','String','OK');

