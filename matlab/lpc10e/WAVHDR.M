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
% WAVHDR
% 1-18-95
% ******************************************************************
%
% DESCRIPTION
%
% Create .WAV file header
%
% DESIGN NOTES
%
% Creates wave file header for 16-bit, 8 kHz, mono .WAV file
%
% VARIABLES
%
% INPUTS
%   fpo             -   Output file pointer
%   frames          -   Number of output frames
%   frameSize       -   Output frame size (samples per frame)
%   fmt             -   Data for format specific field (LPC, CELP, etc.)
%
% OUTPUTS
%   status          -   Success or failure
%
% INTERNALS
%   c               -   Condition codes
%
% ******************************************************************

% IMPORTANT BUG FIX NOTE, 4-14-98
% BY TED PAINTER
%
% rLen and dLen were being improperly calculated based on the
% assumption that all synthesis frames contained 180 samples.
% This is NOT the case because of pitch synchronous synthesis.
% Some frames are shorter and some frames are longer.
% The result was the this section computing values for rLen and
% dLen based on uniform frame lengths.  The values worked out
% for some files but not for others and some .WAV readers
% were more sensitive than others to data chunk length errors.
% 
% The fix was to track actual number of samples written per 
% synthesis frame and then go back at the end of the simulation
% and write the actual data segment lengths into rLen and
% dLen.  For these type of speech files, rLen=dLen+36, so
% this is hard-wired in.  
% 
% The fix is located in the file lpcexec.m, after the 
% EOF has been detected.

function status = wavhdr( fpo, frames, frameSize, fmt )

% INIT CONSTANTS
WAVHDRSIZE = 44;

% CREATE WAVE FILE HEADER
c = zeros(14,1);
dLen = frames * frameSize * 2;
rLen = dLen + WAVHDRSIZE - 8;
c(1) = fwrite( fpo, 'RIFF', 'char' );             % rId
c(2) = fwrite( fpo, rLen, 'long' );               % rLen
c(3) = fwrite( fpo, 'WAVE', 'char');              % wId
c(4) = fwrite( fpo, 'fmt ', 'char');              % fId
%c(5) = fwrite( fpo, 16+length(fmt), 'long');      % fLen - 14 + fmtSpecific field
c(5) = fwrite( fpo, 16, 'long');                  % fLen - 14 + fmtSpecific field
c(6) = fwrite( fpo, 1, 'short');                  % wfmtTag (1=PCM)
c(7) = fwrite( fpo, 1, 'short');                  % nchan
c(8) = fwrite( fpo, 8000, 'long');                % nSampSec
c(9) = fwrite( fpo, 16000, 'long');               % nAvgBytesSec
c(10) = fwrite( fpo, 2, 'short');                 % nBlkAlign
c(11) = fwrite( fpo, 16, 'short');                % fmtSpecific field - bits/sample
%c(12) = fwrite( fpo, fmt, 'char');                % fmtSpecific field - custom
c(13) = fwrite( fpo, 'data', 'char' );            % dId
c(14) = fwrite( fpo, dLen, 'long' );              % dLen

% CHECK CONDITION CODES
if sum(c) ~= 25 + length(fmt)
    status = 0;
else
    status = 1;
end
