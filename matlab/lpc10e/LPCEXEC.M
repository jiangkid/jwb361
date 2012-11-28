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
% ******************************************************************
% LPCEXEC
%
% NSA LPC-10 VOICE CODER EXECUTIVE LOOP
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 4-13-94
%
% ******************************************************************
%
% DESCRIPTION
%
% LPC-10 simulation executive, or main loop. LPCEXEC drives analysis,
% transmission, synthesis, and graphical user interface (GUI).
%
% DESIGN NOTES
%
% Due to the incorporation of a graphical user interface and MATLAB ui
% control objects with their associated callback structures, the executive
% loop structure is slightly different here than in the LPC-55 C code.
% Depending upon the type of session selected by a user, lpcexec.m will
% run either of two ways:
%
% METHOD 1 : Status Output Only - No plotting or user interaction
%            If the user selects status output only, lpcexec.m will
%            only be called once, at simulation startup. It will run in an
%            infinite while loop until input file EOF forces a break
%            and drops control to the termination else clause.
%
% METHOD 2 : Interactive Graphical And Status Output
%            lpcexec.m will be called once per frame, via the callback
%            action associated with the NEXT frame button in the gui
%            output window.  Because this method generates a call for
%            every frame, the infinite while loop is broken out of after
%            each execution.  A call to gui causes the cycle to repeat
%            by creating a new NEXT button.
%
% Among the many variables in this simulation, those associated with gui
% functions are distinguished by the prefix 'gui', e.g., guiVoicing and
% guiState.  gui variables are all global since the gui program is
% often invoked via callback, where many variables are not in scope.
%
% VARIABLES
%
% INTERNALS
%   speech           -   Input and output speech buffer
%   status           -   Input file status
%   fpi, fpo         -   Input and output file pointers
%   voic             -   Voicing decisions, current frame (2)
%   pitch            -   Pitch, current frame
%   rms              -   RMS, current frame
%   rc               -   Reflection coefficients, current frame
%   analysState      -   Static data for analys.m
%   onsetState       -   Static data for onset.m
%   len              -   Length of current output speech frame
%
% GLOBALS
%   FrameCnt         -   Current frame number
%
% CONSTANTS
%    LFRAME          -   Frame size
%    EOF             -   End of file flag
%
% ******************************************************************

% DECLARE GLOBAL CONSTANTS
global EOF LFRAME;

% DECLARE GLOBAL VARIABLES
global FrameCnt

% GET INPUT AND OUTPUT FILE NAMES
[ fpi, fpo ] = setup;

% INITIALIZE STATUS WINDOW
guiinit(1);
speech=[];
dLen=0;

% DO MAIN LOOP FOREVER, UNTIL EOF OR GUI CALL BREAKS OUT
while 1 == 1

    % READ AN INPUT FRAME
    [ speech, status ] = diskio( 0, fpi, speech, LFRAME );

    % CASE 1 : NOT YET EOF, CONTINUE PROCESSING NEW FRAMES
    if ( status ~= EOF )

        % INCREMENT FRAME COUNT AND UPDATE SCREEN STATUS FOR STATUS MODE
        FrameCnt = FrameCnt + 1;
        guistat;

        % RUN HIGHPASS FILTER TO ELIMINATE HUM AND LF NOISE
        speech = hp100( speech );

        % DO LPC ANALYSIS TO EXTRACT VOICING, PITCH, ENERGY, AND RCs
        [ voic, pitch, rms, rc, analysState, onsetState ] = ...
            analys( speech, analysState, onsetState );

        % SIMULATE QUANTIZATION AND TRANSMISSION OF LPC PARAMETERS
        [ voic, pitch, rms, rc ] = trans( voic, pitch, rms, rc );

        % SYNTHESIZE LPC SPEECH AND SAVE RESULTS FOR GUI OUTPUT
        [ speech, len ] = synths( voic, pitch, rms, rc );

        % MATCH SYNTHESIZER OUTPUT FRAME SIZE TO LFRAME VIA BUFFERING
        % THIS WAS USED TO MATCH TO DOD REFERENCE IMPLEMENTATION ONLY
        %speech = bufman( speech, len );

        % WRITE AN OUTPUT FRAME
        %[ speech, eof ] = diskio( 1, fpo, speech, LFRAME );
        [ speech, eof ] = diskio( 1, fpo, speech, length(speech) );
        dLen=dLen+(2*length(speech));
        
    % CASE 2 : AT EOF, CLOSE FILES AND TERMINATE SIMULATION
    else
       
        % UPDATE .WAV LENGTH FIELDS
        % dLen 
        fseek(fpo,40,'bof');
        fwrite(fpo,dLen,'long');
        
        % rLen
        fseek(fpo,4,'bof');
        fwrite(fpo,dLen+36,'long');
        
        % CLOSE FILES
        fclose( 'all' );

        % DISPLAY TERMINATION WINDOW
        guiinit( 2 );

        % EXIT EXECUTIVE LOOP
        break;
    end
end





