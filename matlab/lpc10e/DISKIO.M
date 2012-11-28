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
%
% ******************************************************************
%
% DISKIO
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 2-14-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Disk read/write interface.
%
% DESIGN NOTES
%
% Manages I/O to and from sampled data (speech) files.
% Uses sequential access, unformatted binary files with
% signed 16 bit samples.
%
% VARIABLES
%
% INPUTS
%   mode            -   READ or WRITE
%   fileptr         -   MATLAB file pointer
%   input           -   Buffer of samples (-1.0 to 1.0) to be written to disk
%   length          -   Number of samples to read or write
%
% OUTPUTS
%   status          -   Returns either EOF or number samples read
%   outbuf          -   Buffer of samples (-1.0 to 1.0) read from disk
%
% INTERNALS
%   samples         -   Number of samples returned by fread
%   minv            -   Vector of minimum allowed value for output clamping
%   maxv            -   Vector of maximum allowed value for output clamping
%   clamp           -   Temp matrix for clamping operations
%
% GLOBALS
%   FrameCnt        -   Current frame number
%
% CONSTANTS
%   EOF             -   End of file status flag
%   READ            -   Read control flag
%   WRITE           -   Write control flag
%   LFRAME          -   Input speech frame size
%
% ******************************************************************

function [ outbuf, status ] = diskio( mode, fileptr, input, length )

% DECLARE GLOBAL FLAGS AND CONSTANTS
global EOF READ WRITE LFRAME;

% READ AN INPUT FRAME
if mode == READ

    % READ A FRAME FROM INPUT FILE, FLAG EOF
    [ outbuf, samples ] = fread( fileptr, length, 'short' );
    if samples ~= length
        status = EOF;
    else
        status = samples;
    end

    % SCALE INPUT DATA TO +/-1
    outbuf = outbuf ./ 32768;

% WRITE AN OUTPUT FRAME
else

    % SCALE OUTPUT DATA IN THE INTEGER RANGE 0x0000 - 0xFFFF, ALSO
    % CLAMP ALL VALUES TO WITHIN THIS RANGE.
    minv = zeros( 1, length );
    maxv = zeros( 1, length );
    minv = minv - 32768;
    maxv = maxv + 32767;
    input = input .* 32768;
    clamp = [ input'; maxv ];
    input = min( clamp )';
    clamp = [ input'; minv ];
    input = max( clamp )';

    % WRITE A FRAME TO OUTPUT FILE, FLAG ERRORS
    samples = fwrite( fileptr, input, 'short');
    if samples ~= length
        error( '**** disk write error ****\n' );
    end
    outbuf = input;
    status=samples;
end
