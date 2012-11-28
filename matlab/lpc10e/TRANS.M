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
% TRANS
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 3-28-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Quantize and encode LPC parameters, form serial bitstream, simulate
% transmission errors, and reconstruct parameters from received
% bitstream.
%
% DESIGN NOTES
%
% This routine simulates the effect of quantization and channel errors
% on the transmission of LPC parameters.  It calls encode(), chanl(),
% and decode() in sequence for each frame.  encode() quantizes the LPC
% parameters and optionally performs error correction coding during
% unvoiced and transition frames.  chanl() extracts the bits from the
% quantized parameters, inserts them into a serial array of bits,
% optionally introduces errors into the bitstream, and reconstructs
% the quantized parameters from the bit array.  decode() performs error
% correction on the protected parameters, optionally measures the channel
% error rate, performs error rate dependent smoothing on the received
% parameters, and expands the quantized parameters to their original
% range.
%
% See Also:  Version 52 release notes
%
% VARIABLES
%
% INPUTS
%   voice    -   Half frame voicing decisions (2)
%   pitch    -   Pitch index
%   rms      -   RMS energy
%   rc       -   Reflection coefficients
%
% OUTPUTS
%   voice    -   Half frame voicing decisions (2)
%   pitch    -   Pitch index
%   rms      -   RMS energy
%   rc       -   Reflection coefficients
%
% INTERNAL
%   ipitv    -   Quantized pitch index
%   irms     -   Quantized energy
%   irc      -   Quantized reflection coefficients (10)
%   ibits    -   Serial bitstream (54/frame)
%
% ******************************************************************

function [ voice, pitch, rms, rc ] = trans( voice, pitch, rms, rc )

% QUANTIZE TO 2400 BPS
[ ipitv, irms, irc ] = lpcencode( voice, pitch, rms, rc );

% TRANSMIT THROUGH 2400 BPS CHANNEL
irc = chanl( irc );

% DECODE PARAMETERS FROM BITSTREAM
[ voice, pitch, rms, rc ] = lpcdecode( ipitv, irms, irc, pitch );


