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
% SETUP
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 2-14-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Open input and output speech files.
%
% DESIGN NOTES
%
% Uses MATLAB ui file opening dialog boxes to obtain filenames from
% user.  Computes total number of frames in the input file by seeking
% to file end, then rewinding.
%
% VARIABLES
%
% INPUTS
%   none
%
% OUTPUTS
%   fpi             -   Input file pointer
%   fpo             -   Output file pointer
%
% INTERNALS
%   path            -   Path to input or output file
%   file            -   Input or output filename
%   emsg            -   Error message returned by fopen
%
% GLOBALS
%   guiIfile        -   Input filename for gui display
%   guiOfile        -   Output filename for gui display
%   guiFrames       -   Total number of frames in input file for gui display
%
% CONSTANTS
%   LFRAME          -   Input speech frame size
%
% ******************************************************************

function [ fpi, fpo ] = setup

% DECLARE GLOBAL VARIABLES FOR USER INTERFACE
global guiIfile guiOfile guiFrames infile outfile inpath outpath LPC10path

% DECLARE GLOBAL CONSTANTS
global LFRAME;

% DEFINE FILE CONSTANTS
WAVHDRSIZE = 44;                   % .WAV FILE HEADER SIZE (IN BYTES)
LPChdr = '';

% DISPLAY FILE SELECTION DIALOG
[ file, path ] = uigetfile( '*.wav', 'Select An Input Speech File' );

% OPEN FILE AND COMPUTE INPUT SPEECH FRAMES (TRAP CANCEL EXCEPTION)
if file ~= 0

    % UPDATE SEARCH PATH FOR INPUT FILES
    [ fpi, emsg ] = fopen( [path,file], 'r' );
    fHdrOffset = WAVHDRSIZE;
    guiIfile = file;

    % READ WAVE FILE HEADER
    rID = fread( fpi, 4, 'char' );
    rLen = fread( fpi, 1, 'long' );
    wId = fread( fpi, 4, 'char' );
    ChunkID = fread( fpi, 4, 'char' );
    fLen = fread( fpi, 1, 'long' );
    wFormatTag = fread( fpi, 1, 'short' );
    nChannels = fread( fpi, 1, 'short' );
    nSamplesPerSec = fread( fpi, 1, 'long' );
    nAvgBytesPerSec = fread( fpi, 1, 'long' );
    nBlockAlign = fread( fpi, 1, 'short' );
    FormatSpecific = fread( fpi, fLen-14, 'char' );
    dId = fread( fpi, 4, 'char' );
    dLen = fread( fpi, 1, 'long' );

    % VERIFY VALID .WAV FILE HAS BEEN SELECTED
    WORDSIZE = nBlockAlign;
    FSAMP = nSamplesPerSec;
    c = zeros( 9, 1 );
    c(1) = strcmp( setstr( rID )', 'RIFF' );
    c(2) = strcmp( setstr( wId )', 'WAVE' );
    c(3) = strcmp( setstr( ChunkID )', 'fmt ' );
    c(4) = strcmp( setstr( dId )', 'data' );
    c(5) = (wFormatTag == 1);
    c(6) = (nChannels == 1);
    c(7) = (nAvgBytesPerSec == (FSAMP * WORDSIZE));
    c(8) = WORDSIZE == 2;
    c(9) = FSAMP == 8000;
    if sum(c) ~= length(c)
        if ~c(1) | ~c(2) | ~c(3) | ~c(4) | ~c(7)
            error( 'Invalid .WAV file: File header corrupted!' );
        elseif ~c(5)
            error( 'Invalid .WAV file: Non-PCM data not supported!' );
        elseif ~c(6)
            error( 'Invalid .WAV file: Stereo not supported!' );
        elseif ~c(8)
            bs = str2num(fprintf('%d',8*WORDSIZE/nChannels));
            error( ['Invalid .WAV file: LPC-10e requires 16-bits per sample. Found', bs, '.' ] );
        elseif ~c(9)
            sr = str2num(fprintf('%d',FSAMP));
            error( ['Invalid .WAV file: LPC-10e requires 8 kHz sample rate. Found ', sr, '.'] );
        end
    end
else
    error( 'LPC-10e Simulation aborted!' );
end

% TRAP FILE OPEN EXCEPTIONS
if fpi == -1
    fclose( 'all' );
    error( emsg );
else

    % DETERMINE FRAME COUNT
    fseek( fpi, 0, 'eof' );
    guiFrames = fix( ( ftell(fpi) - fHdrOffset ) / (WORDSIZE*LFRAME) );
    fseek( fpi, fHdrOffset, 'bof' );
end

% OPEN OUTPUT FILE; TRAP EXCEPTIONS
[ file, path ] = uiputfile( '*.wav', 'Select An Output Speech File' );
cd(LPC10path);

% OPEN FILE AND GENERATE .WAV HEADER (TRAP CANCEL EXCEPTION)
if file ~= 0

    % UPDATE SEARCH PATH FOR INPUT FILES
    [ fpo, emsg ] = fopen( [path,file], 'w' );
    fHdrOffset = WAVHDRSIZE;
    guiOfile = file;

    % CREATE WAVE FILE HEADER
    if ~wavhdr(fpo, guiFrames, LFRAME, LPChdr)
        error( 'Unable to create output .WAV file!' );
    end
else
    error( 'LPC-10e Simulation aborted!' );
end

% TRAP FILE OPEN EXCEPTIONS
if fpo == -1
    fclose( 'all' );
    error( emsg );
end