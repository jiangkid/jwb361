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
% IVFILT
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 2-28-94
%
% ******************************************************************
%
% DESCRIPTION
%
% 2ND ORDER INVERSE FILTER, SPEECH IS DECIMATED 4:1.
% LOWPASS (800 Hz) SPEECH IS ANALYZED TO OBTAIN PREDICTOR COEFS FOR
% A 2ND ORDER LINEAR PREDICTION FILTER.  WHEREAS THESE COEFFICIENTS
% MIGHT BE USED DURING SPECTRAL ANALYSIS TO ESTIMATE THE SPECTRAL
% SIGNAL CHARACTERISTICS, HERE THEY ARE USED TO CREATE AN INVERSE
% OR WHITENING FILTER.  SPECTRALLY FLATTENED SPEECH IS BETTER SUITED
% TO AMDF PITCH EXTRACTION.
%
% DESIGN NOTES
%
% AUTOCORRELATIONS ARE USED TO DERIVE THE PREDICTOR COEFFICIENTS.
% INVERSE FILTERING INCORPORATES 4:1 DECIMATION BY ONLY PROCESSING
% EVERY 4TH SAMPLE FROM THE INPUT BUFFER.
%
% VARIABLES
%
%      lpbuf   -   lowpass filtered speech (800 Hz cutoff), 12-bit + sign
%      ivbuf   -   inverse filter output, 12-bit + sign
%      acMask  -   autocorrelation mask - only every 2nd sample is used
%      acProd  -   autocorrelation intermediate product vector
%      r0 - r2 -   autocorrelation lags
%      pc1,2   -   predictor coefficients (FIR taps)
%      ivrc    -   inverse filter reflection coefficients
%
% ******************************************************************

function [ ivbuf, ivrc ] = ivfilt( lpbuf )

% DECLARE GLOBAL VARIABLES
global ziv;

% COMPUTE AUTOCORRELATIONS
acProd = lpbuf(340:2:516) .* lpbuf(340:2:516);
r0 = sum( acProd );
acProd = lpbuf(344:2:516) .* lpbuf(340:2:512);
r1 = sum( acProd );
acProd = lpbuf(348:2:516) .* lpbuf(340:2:508);
r2 = sum( acProd );

% CALCULATE PREDICTOR COEFFICIENTS
pc1 = 0.00;
pc2 = 0.00;
ivrc(1) = 0.00;
ivrc(2) = 0.00;
if r0 > 0.000001
    ivrc(1) = r1 / r0;
    ivrc(2) = ( r2 - ( ivrc(1) * r1 ) ) / ( r0 - ( ivrc(1) * r1 ) );
    pc1 = ivrc(1) - ( ivrc(1) * ivrc(2) );
    pc2 = ivrc(2);
end

% INVERSE FILTER LPBUF INTO IVBUF
ivbuf = lpbuf( 337:516 ) + ( -pc1 .* lpbuf( 333:512 ) ) + ( -pc2 .* lpbuf( 329:508 ) );

% [ j1,j2 ] = diskio( 1, 4, ivbuf, 180 );


% THIS METHOD DOESN'T QUITE WORK -- MUST BE BUFFER OFFSET BETWEEN FRAMES?
% biv = [ 1.0, 0.0, 0.0, 0.0, -pc1, 0.0, 0.0, 0.0, -pc2 ];
% aiv = [ 1.0, 0.0, 0.0, 0.0,  0.0, 0.0, 0.0, 0.0,  0.0 ];
% [ ivbuf, ziv ] = filter( biv, aiv, lpbuf( 337:516 ), ziv );
