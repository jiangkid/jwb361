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
% SYNTHS
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 4-2-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Synthesizer executive.  Synthesizes a frame of output speech by
% synthesizing up to as many as 11 independent pitch epochs.
%
% DESIGN NOTES
%
% PITSYN is first called to determine the number of pitch epochs to
% be produced, along with the necessary characteristics of each
% epoch.
%
% For each pitch epoch, IRC2PC is called to convert reflection
% coefficients to predictor coefficients.  BSYNZ is called to generate
% each pitch epoch of output speech.  Finally output speech is
% deemphasized using DEEMP.
%
% See Also:  Version 52 release notes
%
% VARIABLES
%
% INPUTS
%   voice    -   Half frame voicing decisions (2)
%   pitch    -   Pitch of present frame
%   rms      -   Energy of present frame
%   rc       -   Reflection coefficients, present frame
%
% OUTPUTS
%   speech   -   Speech output frame buffer
%   k        -   Size of speech output buffer, also buffer index
%
% INTERNAL
%   gprime   -   Excitation modification filter gain
%   ivuv     -   Epoch voicing decisions
%   ipiti    -   Pitch epoch lengths
%   rmsi     -   Pitch epoch energy
%   rci      -   Pitch epoch reflection coefficients
%   nout     -   Number of pitch periods in this frame
%   ratio    -   Previous to present energy ratio
%   pc       -   Pitch epoch predictor coefficients
%   g2pass   -   Sharpening factor for 2-pass synthesis
%   sout     -   Pitch epoch output speech
%   u        -   Epoch length, current epoch
%
% ******************************************************************

function [ speech, k ] = synths( voice, pitch, rms, rc )

% DECLARE GLOBAL VARIABLES
global ivuv ipiti rmsi rci pc sout;

% DEFINE GLOBAL CONSTANTS
global ORDER;

% INITIALIZE LOCAL CONSTANTS
gprime = 0.7;

% CLAMP FRAME PITCH AND RCS
pitch = max([min([pitch,156]),20]);
rc = min([rc';(0.99 .* ones(1,ORDER))]);
rc = max([rc;(-0.99 .* ones(1,ORDER))])';

% DETERMINE NUMBER OF PITCH EPOCHS
k = 1;
[ ivuv, ipiti, rmsi, rci, nout, ratio ] = ...
pitsyn( voice, pitch, rms, rc, ivuv, ipiti, rmsi, rci );

% SYNTHESIZE SPEECH FOR ALL EPOCHS
if nout > 0
    for j = 1:nout
        u = ipiti(j);
        [ pc, g2pass ] = irc2pc( rci, gprime, j );
        [ sout ] = bsynz( pc, u, ivuv(j), rmsi(j), ratio, g2pass, sout );
        sout( 1:u ) = deemp( sout( 1:u ) );
        speech(k:k+u-1) = sout(1:u) .* 0.000244140625;
        k = k + u;
    end
end

% CORRECT LAST K VALUE TO = LENGTH, RATHER THAN POINTER TO NEXT SAMPLE
k = k - 1;

% MAKE SPEECH A COLUMN VECTOR
speech = speech';

