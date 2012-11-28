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
% TBDM
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 3-1-94
%
% ******************************************************************
%
% DESCRIPTION
%
% COMPUTE HIGH RESOLUTION AVERAGE MAGNITUDE DIFFERENCE FUNCTION (AMDF)
% FOR USE IN FIRST-PASS PITCH ESTIMATE.
%
% DESIGN NOTES
%
% A)  A LOGARITHMICALLY SPACED LAG, 60-POINT AMDF IS CALCULATED AND ITS
%     MINIMUM FOUND.  AMDF MINIMA USUALLY INDICATE PERIODICITY IN
%     THE INPUT SIGNAL.
% B)  PRECEDING COARSE ESTIMATES OF THE MINIMUM AND LAG VALUES ARE
%     RESOLVED TO ONE SAMPLE.
% C)  LAGS AT THE UPPER OCTAVE FREQUENCY ARE CHECKED. IF THE MINIMUM
%     OF THE AMDF IS FOUND IN THIS REGION, THE MINPTR IS SET TO THE
%     UPPER OCTAVE FREQUENCY (-20 LAGS).
% D)  MINIMUM OF THE AMDF COARSE RESOLUTION FUNCTION IS ASSIGNED TO THE
%     HIGH-RESOLUTION MINIMUM FOUND ABOVE, EVEN THOUGH THE TAU ARRAY MAY
%     NOT CONTAIN THE CORRESPONDING LAG VALUE.
% E)  THE LOCAL MAXIMUM OF THE AMDF FUNCTION IS FOUND WITHIN +/- HALF
%     AN OCTAVE OF THE AMDF MINIMUM.
%
% A MAXIMUM OF 68 AMDF POINTS ARE COMPUTED.  EACH AMDF POINT REQUIRES
% 39 SUMMATIONS, THEREFORE A MAXIMUM OF 2652 AMDF SUMMATIONS ARE
% COMPUTED.
%
% VARIABLES
%
%      OUTPUTS
%      amdf     -   average magnitude difference function, 60 lags (tau)
%      minptr   -   index of AMDF min
%      maxptr   -   index of AMDF max within +/- 1/2 octave of min
%      mintau   -   lag corresponding to minimum AMDF value
%
%      INPUTS
%      speech   -   spectrally flatted, inverse filtered speech
%      tau      -   table of lags
%
%      INTERNAL
%      LTAU     -   index of last tau lag (60)
%      tau2     -   table of lags for high-res estimate
%      amdf2    -   amdf function for high-res estimate
%      ltau2    -   used to construct table of lags close to AMDF min
%      minp2    -   high-res estimate min index
%      maxp2    -   high-res estimate max index
%      minamd   -   AMDF minimum
%      ptr      -   "" ""
%      minptr   -   "" ""
%      maxptr   -   used to find maximum within 1/2 octave of minimum
%      i        -   general purpose integer index
%
% ******************************************************************

function [ amdf, minptr, maxptr, mintau ] = tbdm( speech, tau )

% DECLARE GLOBAL VARIABLES
global LTAU tau2;

% DECLARE AND INITIALIZE LOCAL VARIABLES
amdf = zeros( LTAU, 1 );
amdf2 = zeros( 6, 1 );

% COMPUTE FULL AMDF USING LOG SPACED LAGS, FIND COARSE MINIMUM
[ amdf, minptr, maxptr ] = difmag( speech, tau, LTAU, tau(LTAU), amdf );
mintau = tau( minptr );
minamd = fix( amdf( minptr ) );

% BUILD TABLE CONTAINING ALL LAGS WITHIN +/-3 OF THE AMDF MINIMUM
% EXCLUDING ALL THAT HAVE ALREADY BEEN COMPUTED
ltau2 = 0;
ptr = minptr - 2;
i = max( mintau-3, 41 );
while i <= min( mintau+3, tau( LTAU ) )
    while tau( ptr ) < i
        ptr = ptr + 1;
    end
    if tau( ptr ) ~= i
        ltau2 = ltau2 + 1;
        tau2( ltau2 ) = i;
    end
    i = i+1;
end

% COMPUTE AMDF OF THE NEW LAGS, IF THERE ARE ANY, AND CHOOSE ONE IF IT
% IS BETTER THAN THE COARSE MINIMUM
if ltau2 > 0
    [ amdf2, minp2, maxp2 ] = difmag( speech, tau2, ltau2, tau(LTAU), amdf2 );
    if amdf2( minp2 ) < minamd
        mintau = tau2( minp2 );
        minamd = fix( amdf2( minp2 ) );
    end
end

% CHECK ONE OCTAVE UP, IF THERE ARE ANY LAGS NOT YET COMPUTED
if mintau >= 80
    i = fix( mintau * 0.5 );
    if rem( i, 2 ) == 0
        ltau2 = 2;
        tau2(1) = i-1;
        tau2(2) = i+1;
    else
        ltau2 = 1;
        tau2(1) = i;
    end
    [ amdf2, minp2, maxp2 ] = difmag( speech, tau2, ltau2, tau(LTAU), amdf2 );
    if amdf2( minp2 ) < minamd
        mintau = tau2( minp2 );
        minamd = fix( amdf2( minp2 ) );
        minptr = minptr-20;
    end
end

% FORCE MINIMUM OF THE AMDF ARRAY TO THE HIGH RESOLUTION MINIMUM
amdf( minptr ) = minamd;

% FIND MAXIMUM OF AMDF WITHIN 1/2 OCTAVE OF MINIMUM
maxptr = max( minptr-5, 1 );
i = maxptr+1;
while i <= min( minptr+5, LTAU )
    if amdf(i) > amdf(maxptr)
        maxptr = i;
    end
    i = i+1;
end
