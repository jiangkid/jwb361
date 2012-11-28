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
% ******************************************************************************
% VPARMS
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 3-8-94
%
% ******************************************************************************
%
% DESCRIPTION
%
%  Calculate voicing parameters
%
% DESIGN NOTES
%
%  See:  Version 52 release notes.
%
% VARIABLES
%
% INPUTS
%  vwin   - Voicing window limits
%  inbuf  - Input speech buffer
%  lpbuf  - Low pass filtered speech
%  buflim - Array bounds for INBUF and LPBUF
%  half   - Half frame (1 or 2)
%  dither - Zero crossing threshold
%  mintau - Lag corresponding to minimum AMDF value (pitch estimate)
%
% OUTPUTS
%  zc     - Zero crossing rate
%  lbe    - Low band energy (sum of magnitudes - SM)
%  fbe    - Full band energy (SM)
%  qs     - Ratio of 6 dB/oct preemphasized energy to full band energy
%  rc1    - First reflection coefficient
%  ar_b   - Product of the causal forward and reverse pitch
%           prediction gains
%  ar_f   - Product of the noncausal forward and reverse pitch
%           prediction gains
%
% INTERNAL
%  oldsgn - Previous sign of dithered signal
%  vlen   - Length of voicing window
%  start  - Lower address of current half of voicing window
%  stop   - Upper address of current half of voicing window
%  e_0    - Energy of LPF speech (sum of squares - SS)
%  e_b    - Energy of LPF speech backward one pitch period (SS)
%  e_f    - Energy of LPF speech forward one pitch period (SS)
%  r_b    - Autocovariance of LPF speech backward one pitch period
%  r_f    - Autocovariance of LPF speech forward one pitch period
%  lp_rms - Energy of LPF speech (sum of magnitudes - SM)
%  ap_rms - Energy of all-pass speech (SM)
%  e_pre  - Energy of 6dB preemphasized speech (SM)
%  e0ap   - Energy of all-pass speech (SS)
%
% ******************************************************************************

function [ dither, zc, lbe, fbe, qs, rc1, ar_b, ar_f ] = ...
   vparms( vwin, inbuf, lpbuf, half, dither, mintau )

% DECLARE GLOBAL VARIABLES
global LBUFL SBUFL;

% DECLARE AND INITIALIZE LOCAL VARIABLES

% ESTABLISH BOUNDS FOR ENERGY AND CORRELATION MEASURES
vlen = vwin(2,3) - vwin(1,3) + 1;
start = vwin(1,3) + ((half-1)*(fix(vlen/2))) + 1;
stop = start + (fix(vlen/2)) - 1;
lpStart = start - LBUFL + 1;
lpStop = stop - LBUFL + 1;
inStart = start - SBUFL + 1;
inStop = stop - SBUFL + 1;
oldsgn = sign( inbuf(inStart-1) - dither );

% SETUP FOR ZERO CROSSING DETECTION, USING DITHER
dmax = stop-start+1;
signs=zeros(dmax,1);
dt=zeros(dmax,1);
dt(1:2:dmax) = dt(1:2:dmax)+dither;
dt(2:2:dmax) = dt(2:2:dmax)-dither;

% CALCULATE ZERO CROSSINGS (ZC) AND SEVERAL ENERGY AND CORRELATION
% MEASURES ON LOW BAND AND FULL BAND SPEECH.  EACH MEASURE IS TAKEN
% OVER EITHER THE FIRST OR THE SECOND HALF OF THE VOICING WINDOW,
% DEPENDING ON THE VARIABLE HALF.
signs = sign( dt + inbuf(inStart:inStop) );
zc = sum( ~( signs + [ oldsgn; signs(1:dmax-1) ] ) );
lp_rms = sum( abs( lpbuf(lpStart:lpStop) ) );
ap_rms = sum( abs( inbuf(inStart:inStop) ) );
e_pre = sum( abs( inbuf(inStart:inStop) - inbuf(inStart-1:inStop-1) ) );
e0ap = sum( inbuf(inStart:inStop) .* inbuf(inStart:inStop) );
rc1 = sum( inbuf(inStart:inStop) .* inbuf(inStart-1:inStop-1) );
e_0 = sum( lpbuf(lpStart:lpStop) .* lpbuf(lpStart:lpStop) );
e_b = sum( lpbuf(lpStart-mintau:lpStop-mintau) .* lpbuf(lpStart-mintau:lpStop-mintau) );
e_f = sum( lpbuf(lpStart+mintau:lpStop+mintau) .* lpbuf(lpStart+mintau:lpStop+mintau) );
r_f = sum( lpbuf(lpStart:lpStop) .* lpbuf(lpStart+mintau:lpStop+mintau) );
r_b = sum( lpbuf(lpStart:lpStop) .* lpbuf(lpStart-mintau:lpStop-mintau) );

% NORMALIZED SHORT-TERM AUTOCOVARIANCE COEFFICIENT AT UNIT SAMPLE DELAY
rc1 = rc1 / max( [ e0ap, 1.0 ] );

% RATIO OF THE ENERGY OF THE FIRST DIFFERENCE SIGNAL (6 DB/OCT PREEMPHASIS)
% TO THE ENERGY OF THE FULL BAND SIGNAL
qs = e_pre / max( [ 2.0*ap_rms, 1.0 ] );

% AR_B IS THE PRODUCT OF THE FORWARD AND REVERSE PREDICTION GAINS,
% LOOKING BACKWARD IN TIME (THE CAUSAL CASE).
ar_b = ( r_b*r_b ) / ( max( [ e_b, 1.0 ] ) * max( [ e_0, 1.0 ] ) );

% AR_F IS THE SAME AS AR_B, BUT LOOKING FORWARD IN TIME (NON CAUSAL CASE).
ar_f = ( r_f / max( [ e_f, 1.0 ] ) ) * ( r_f / max( [ e_0,1.0 ] ) );

% NORMALIZE ZC, LBE, AND FBE TO OLD FIXED WINDOW LENGTH OF 180.
% (THE FRACTION 90/VLEN HAS A RANGE OF .58 TO 1)
zc  = fix( ( zc * 2 * ( 90.0 / vlen ) ) + .5 );
lbe = fix( min( [ (lp_rms*0.25*(90.0/vlen))+.5, 32767 ] ) );
fbe = fix( min( [ (ap_rms*0.25*(90.0/vlen))+.5, 32767 ] ) );

