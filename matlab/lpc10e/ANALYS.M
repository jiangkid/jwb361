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
% ANALYS
%
% 2-21-94
%
% ******************************************************************
%
% DESCRIPTION
%
% LPC analysis driver.  Determines pitch, voicing, rms energy, and
% reflection coefficients for each frame of input speech.
%
% DESIGN NOTES
%
% See version 52 release notes.
%
% VARIABLES
%
% INPUTS
%   speech          -   Input speech samples (-1.0 to 1.0)
%   analysState     -   ANALYS.M static variables, stored in a single matrix
%   onsetState      -   ONSET.M static variables, stored in a single matrix
%
% OUTPUTS
%   voice           -   Voicing decisions (2)
%   pitch           -   Pitch estimate
%   rms             -   RMS energy measurement
%   rc              -   Reflection coefficients (10)
%   onsetState      -   ONSET.M static variables, stored in a single matrix
%   analysState     -   ANALYS.M static variables, stored in a single matrix
%
% INTERNALS
%   lo              -   Speech buffer base index, frame 1
%   mid             -   Speech buffer base index, frame 2
%   hi              -   Speech buffer base index, frame 3
%   osbuf           -   Onset buffer (buffer of onset indicies)
%   osptr           -   Free pointer into osbuf
%   vwin            -   Voicing window locations (start, end indicies)
%   obound          -   Onset boundary descriptions
%   i, j, half      -   Loop counters
%   fsum            -   Long term DC bias estimator summation
%   ivrc            -   Inverse filter reflection coefficients
%   amdf            -   Average magnitude difference, 1 lag per lag in tau
%   minptr          -   Index of minimum amdf value
%   maxptr          -   Index of maximum amdf value
%   mintau          -   Lag corresponding to minimum AMDF value
%   midx            -   Initial estimate of current frame pitch
%   ipitch          -   Raw and final pitch estimates
%   lanal           -   Length of LPC analysis window
%   dcbl            -   PEBUF lower bound for short term dc bias removal
%   dcbh            -   PEBUF upper bound for short term dc bias removal
%   abuf            -   LPC analysis temporary buffer
%   elen            -   Energy window length
%   elo             -   ABUF lower bound for energy computation
%   ehi             -   ABUF upper bound for energy computation
%   phi             -   LPC covariance matrix
%   psi             -   LPC covariance vector
%   p1, p2, p3      -   Zero padding variables for state matricies (statics)
%
% GLOBALS
%   inbuf           -   Raw speech, scaled to 12 bits magnitude + sign
%   pebuf           -   Preemphasized speech
%   bias            -   Estimate of long term DC bias
%   lpbuf           -   Low pass speech buffer
%   ivbuf           -   Inverse filtered speech
%   tau             -   Table of AMDF lags
%   voibuf          -   Voicing decisions on windows in vwin
%   awin            -   Analysis window indicies
%   ewin            -   Energy window indicies
%   rmsbuf          -   RMS energy
%   rcbuf           -   Reflection coefficients
%   guiSbuf1        -   Input signal buffering for graphical display
%   guiSbuf2        -        "                 "              "
%   guiSin          -        "                 "              "
%
% CONSTANTS
%   LFRAME          -   Input speech frame size
%   OSLEN           -   Onset buffer length
%   AF              -   The analysis frame
%   SBUFL           -   Lower index of speech buffers
%   ORDER           -   LPC predictor order
%
% ******************************************************************

function [ voice, pitch, rms, rc, analysState, onsetState ] = ...
    analys( speech, analysState, onsetState )

% DECLARE GLOBAL CONSTANTS
global LFRAME OSLEN AF SBUFL ORDER;

% DECLARE GLOBAL VARIABLES
global inbuf pebuf bias lpbuf ivbuf tau voibuf awin ewin rmsbuf rcbuf;
global guiSbuf1 guiSbuf2 guiSin;

% INITIALIZE USEFUL CONSTANTS
lo = LFRAME;
mid = 2 * LFRAME;
hi = 3 * LFRAME;

% RESTORE STATIC VARIABLES
osbuf  = analysState( 1:OSLEN, 1 );
osptr  = analysState( 1, 2 );
vwin   = analysState( 1:2, 3:5 );
obound = analysState( 1:3, 6 );

% ANALYSIS BUFFER HOLDS 3 SPEECH FRAMES.  DISCARD OLDEST AND SHIFT MOST
% RECENT FRAMES INTO POSITION.  THIS PREPARES FOR LOADING A NEW FRAME.
inbuf( 1:mid ) = inbuf( lo+1:hi );
pebuf( 1:mid ) = pebuf( lo+1:hi );
lpbuf( 1:516 ) = lpbuf( 181:696 );
ivbuf( 1:132 ) = ivbuf( 181:312 );

% SAVE ANY ONSET INDICIES GREATER THAN LFRAME, ADJUSTED FOR NEW FRAME
j = 1;
for i = 1 : osptr - 1
    if osbuf( i ) > LFRAME
        osbuf( j ) = osbuf( i ) - LFRAME;
        j = j + 1;
    end
end
osptr = j;

% UPDATE WINDOW INDICIES
voibuf(1,1) = voibuf(1,2);
voibuf(2,1) = voibuf(2,2);
for i = 1 : AF - 1
    vwin( 1, i ) = vwin( 1, i + 1 ) - LFRAME;
    vwin( 2, i ) = vwin( 2, i + 1 ) - LFRAME;
    awin( 1, i ) = awin( 1, i + 1 ) - LFRAME;
    awin( 2, i ) = awin( 2, i + 1 ) - LFRAME;
    ewin( 1, i ) = ewin( 1, i + 1 ) - LFRAME;
    ewin( 2, i ) = ewin( 2, i + 1 ) - LFRAME;
    obound( i ) = obound( i + 1 );
    voibuf( 1, i + 1 ) = voibuf( 1, i + 2 );
    voibuf( 2, i + 1 ) = voibuf( 2, i + 2 );
    rmsbuf( i ) = rmsbuf( i + 1 );
    rcbuf( 1:ORDER, i ) = rcbuf( 1:ORDER, i + 1 );
end

% COPY NEWEST INPUT FRAME TO THE ANALYSIS BUFFER, REMOVING LONG TERM DC BIAS.
inbuf( mid + 1 : hi ) = ( speech .* 4096 ) - bias;

% UPDATE BIAS ESTIMATE
fsum = sum( inbuf( mid + 1 : hi ) );
if fsum > LFRAME
   bias = bias + 1;
end
if fsum < -LFRAME
   bias = bias - 1;
end

% APPLY PREEMPHASIS FILTER TO FLATTEN INPUT SPECTRUM FOR LPC ANALYSIS,
% THEN FIND ONSETS AND PLACE VOICING WINDOW
pebuf( mid+1:hi )                = preemp( inbuf( mid + 1 : hi ), 0.4 );
[ osbuf, osptr, onsetState ]     = onset( pebuf, osbuf, osptr, onsetState );
[ obound( AF ), vwin ]           = placev( osbuf, osptr, vwin );
lpbuf( 517:696 )                 = lpfilt31( inbuf( 359:538 ) );
[ ivbuf( 133:312 ), ivrc ]       = ivfilt( lpbuf );
[ amdf, minptr, maxptr, mintau ] = tbdm( ivbuf, tau );

% GENERATE VOICING STATE ESTIMATES FOR EACH HALF FRAME
for half = 1:2
    voibuf = voicing( vwin, inbuf, lpbuf, half, amdf(minptr), ...
                      amdf(maxptr), mintau, ivrc, obound, voibuf );
end

% FIND THE MINIMUM COST PITCH DECISION OVER SEVERAL FRAMES GIVEN THE
% CURRENT VOICING DECISION AND THE AMDF ARRAY
[ pitch, midx ] = dyptrk( amdf, minptr, voibuf(2,AF+1) );
ipitch = tau(midx);

% PLACE THE SPECTRUM ANALYSIS AND ENERGY WINDOWS
[ awin, ewin ] = placea( ipitch, voibuf, obound(AF), vwin, awin, ewin );
lanal = awin(2,AF) + 1 - awin(1,AF);

% REMOVE SHORT-TERM DC BIAS OVER THE ANALYSIS WINDOW, PUT RESULT IN ABUF
dcbl = awin(1,AF) - SBUFL + 1;
dcbh = awin(1,AF) - SBUFL + lanal;
abuf = dcbias( lanal, pebuf(dcbl:dcbh) );

% COMPUTE RMS ENERGY OVER INTEGER NUMBER OF PITCH PERIODS WITHIN
% THE ANALYSIS WINDOW
elen = ewin(2,AF) - ewin(1,AF) + 1;
elo = ewin(1,AF) - awin(1,AF) + 1;
ehi = elo + elen - 1;
rmsbuf(AF) = energy( elen, abuf(elo:ehi) );

% ALLOW GRAPHICAL OUTPUT TO TRACK LPC-10 BUFFERING BY TRIPLE BUFFERING
% INPUT SIGNAL FOR DELAYED DISPLAY OUTPUT.
% THIS WILL ALLOW SIMULTANEOUS DISPLAY OF SYNTHESIZER OUTPUT AND
% CORRESPONDING ANALYZER INPUT.
% DATA ENTERS AT STAGE 2, IS SHIFTED TO STAGE 1, AND FINALLY TO Sin.
guiSin = guiSbuf1;
guiSbuf1 = guiSbuf2;
guiSbuf2 = abuf;

% MATRIX LOAD AND INVERT, CHECK REFLECTION COEFFICIENTS FOR STABILITY
[ phi, psi ] = mload( lanal, abuf );
rcbuf = invert( phi, psi, rcbuf );
rcbuf = rcchk( rcbuf );

% SET RETURN PARAMETERS
voice = voibuf(:,AF-1);
rms = rmsbuf(AF-2);
rc = rcbuf(:,AF-2);

% PRESERVE STATIC VARIABLES
p1=zeros(9,1); p2=zeros(8,3); p3=zeros(7,1);
analysState = [ osbuf, [osptr;p1], [vwin;p2], [obound;p3] ];
