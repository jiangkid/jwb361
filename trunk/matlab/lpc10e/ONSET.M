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
% ONSET
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 2-23-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Onset Detection. Detects onsets (rapid changes in speech character)
% in the futuremost frame of input speech.  Onset locations are used
% to position windows for voicing, spectral, and energy computations.
%
% DESIGN NOTES
%
% Onsets are detected by passing a modified signal through two filters,
% then applying hysteresis to prevent excessive onsets. The process is:
%
% 1) Forward prediction coefficients are computed from preemphasized
%    input speech:
%
%                s(i)s(i-1)
%     fpc(i) =  ------------
%               s(i-1)s(i-1)
%
% 2) Above numerator and denominator are passed through an IIR filter:
%
%                    b
%       H(Z) =  -------------  where b = 1/64 and a = -63/64
%                1 + a(Z^-1)
%
%    Expression (1) is evaluated and resulting fpc(i)s are clamped to +/-1.
%    In case of a zero denominator, fpc(i-1) is used for f(i).
%
% 3) Using an FIR filter, fpc(i)s are differentiated. Because fpc(i) is an
%    indicator of spectral tilt, its derivative is expected to become large
%    in magnitude at an onset.  Differentiator is:
%
%       H(Z) =   1 + Z^-1 + Z^-2 + ... + Z^-7 - Z^-8 - Z^-9 - ... - Z^-15
%
% 4) Finally, thresholding is applied to d(i) terms. d(i)s of sufficient
%    magnitude indicate onset existence. Hysteresis is incorporated to
%    prevent excessive onsets.
%
% VARIABLES
%
%      in      -   input frame (-1.0 to 1.0)
%      b, a    -   filter taps
%
% ******************************************************************

function [ osbuf, osptr, onsetState ] = onset( pe, osbuf, osptr, statics )

% RESTORE FUNCTION STATE (static variables)
hyst = statics( 1, 1 );
lasti = statics( 1, 2 );
zn = statics( 1:2, 3 );
zd = statics( 1:2, 4 );
flast = statics( 1, 5 );
zdiff = statics( 1:15, 6 );

% DECLARE ALL GLOBAL CONSTANTS
global LFRAME OSLEN;

% INITIALIZE USEFUL CONSTANTS
lo = LFRAME;
mid = 2 * LFRAME;
hi = 3 * LFRAME;

% INITIALIZE LOCAL VARIABLES
fpc = zeros( LFRAME, 1 );
n = zeros( LFRAME, 1 );
d = zeros( LFRAME, 1 );
diff = zeros( LFRAME, 1 );
OnsetThreshold = 1.7;
DiffLag = 9;
OsHyst = 10;

% INITIALIZE TAPS, FILTERS 2 AND 3 (SEE ABOVE)
bexp = [ 1.0/64.0, 0.0, 0.0 ];
aexp = [ 1.0, -63.0/64.0, 0.0 ];
bdiff = [ 1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0, ...
         -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0 ];
adiff = [ 1.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, ...
          0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0 ];

% MAINTAIN HYSTERESIS TRACKING
if hyst == 1
    lasti = lasti - 180;
end

% COMPUTE AND FILTER FPC TERMS
n = pe( mid + 1 : hi ) .* pe( mid : hi - 1 );
d = pe( mid : hi - 1 ) .* pe( mid : hi - 1 );
[ n, zn ] = filter( bexp, aexp, n, zn );
[ d, zd ] = filter( bexp, aexp, d, zd );

% CLAMP TO +/-1, TRAP DIVIDE BY ZERO
for i = 1 : LFRAME
    if d( i ) == 0.00
        fpc( i ) = flast;
    else
        if abs( n( i ) ) > d( i )
            fpc( i ) = sign( n( i ) );
        else
            fpc( i ) = n( i ) / d( i );
        end
        flast = fpc( i );
    end
end

% DIFFERENTIATE FPCs TO FIND ONSETS
[ diff, zdiff ] = filter( bdiff, adiff, fpc, zdiff );

% INCORPORATE THRESHOLDING AND HYSTERESIS, STORE RESULTS
diff = abs( diff );
for i = 1 : LFRAME
    if diff( i ) > OnsetThreshold
        if hyst == 0
	    if osptr <= OSLEN
                osbuf( osptr ) = i - DiffLag + 540;
                osptr = osptr + 1;
            end
            hyst = 1;
	end
        lasti = i;
    else
        if ( hyst == 1 ) & ( ( i - lasti ) >= OsHyst )
            hyst = 0;
        end        
    end
end

% SAVE FUNCTION STATE (STATIC VARIABLES)
p1 = zeros( 14, 1 );
p2 = zeros( 13, 1 );
onsetState = [ [hyst;p1], [lasti;p1], [zn;p2], [zd;p2], [flast;p1], zdiff ];


