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
% PITSYN
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 4-2-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Determines the number of pitch epochs per frame, in addition to the
% characteristics of each epoch, including voicing, length, energy,
% and RCs.  Ratio of present and previous frame rms energies is
% computed to be used in scaling of plosive doublets within
% unvoiced epochs.
%
% DESIGN NOTES
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
%   ivuv     -   Epoch voicing decisions
%   ipiti    -   Pitch epoch lengths
%   rmsi     -   Pitch epoch energy
%   rci      -   Pitch epoch reflection coefficients
%
% OUTPUTS
%   ivuv     -   Epoch voicing decisions
%   ipiti    -   Pitch epoch lengths
%   rmsi     -   Pitch epoch energy
%   rci      -   Pitch epoch reflection coefficients
%   nout     -   Number of pitch periods in this frame
%   ratio    -   Previous to present energy ratio
%
% INTERNAL
%   uvpit    -   Unvoiced epoch length
%   psFirst  -   Flag to indicate first call to pitsyn
%   gprime   -   Excitation modification filter gain
%   lsamp    -   Last sample position involved in RC and RMS interpolation
%   jsamp    -   Number of samples from end of previous frame not yet
%                assigned to an epoch
%   jused    -   Position of last sample assigned to an epoch
%   slope    -   Pitch slope from previous to present frame
%   ipito    -   Pitch of last epoch from previous frame
%   istart   -   First sample position involved in RC and RMS interpolation
%   ivoico   -   Voicing decision of previous second half frame
%   nl       -   Sample position of end of unvoiced section of transition
%                frame to voiced
%   alro     -   LAR of previous frame RC (LAR = log area ratio)
%   alrn     -   LAR of present frame RC
%   xxy      -   Temp storage during computation of interpolated RC LARs
%   ipito    -   Pitch of last epoch from previous frame
%   rmso     -   Energy of previous frame
%   rco      -   Reflection coefficients of previous frame
%   yarc     -   Temp storage for present frame RCs during voiced section
%                of transition frame to unvoiced
%   vflag    -   Logical variable indicating that voiced epoch processing
%                is occurring for a voiced-to-unvoiced transition frame.
%
% ******************************************************************

function [ ivuv, ipiti, rmsi, rci, nout, ratio ] = ...
	 pitsyn( voice, pitch, rms, rc, ivuv, ipiti, rmsi, rci )

% DECLARE GLOBAL CONSTANTS
global LFRAME

% DECLARE GLOBAL VARIABLES
global ivoico ipito rmso psFirst rco yarc jsamp;

% INITIALIZE LOCAL VARIABLES
nl = 0;
lsamp = 0;
ip = 0;
istart = 0;
ivoice = 0;
jused = 0;
vflag = 0;

% CLAMP RMS LEVEL
if rms < 1
    rms = 1;
end
if rmso < 1
    rmso = 1;
end
uvpit = 0;
ratio = rms / ( rmso + 8 );

% INITIALIZE IMPORTANT VALUES ON FIRST CALL ONLY
if psFirst == 1
    lsamp = 0;
    ivoice = voice(2);
    if ivoice == 0
        pitch = fix( LFRAME * 0.25 );
    end
    nout = fix( LFRAME / pitch );
    jsamp = LFRAME - (nout*pitch);
    for i = 1:nout
        rci(:,i) = rc;
    end
    ivuv(1:nout) = ivoice + zeros(nout,1);
    ipiti(1:nout) = pitch + zeros(nout,1);
    rmsi(1:nout) = rms + zeros(nout,1);
    psFirst = 0;
else
    vflag = 0;
    lsamp = LFRAME + jsamp;
    slope = (pitch-ipito) / lsamp;
    nout = 0;
    jused = 0;
    istart = 1;
    if ( voice(1) == ivoico ) & ( voice(2) == voice(1) )
        if voice(2) == 0
            % SSUV -- 0,0,0
            pitch = fix( LFRAME*0.25 );
            ipito = pitch;
            if ratio > 8
                rmso = rms;
            end
        end
        % SSVC -- 1,1,1
        slope = (pitch-ipito) / lsamp;
        ivoice = voice(2);
    else
        if ivoico ~= 1
            if ivoico == voice(1)
                % UV2VC2 -- 0,0,1
                nl = fix( lsamp - (LFRAME*0.25) );
            else
                % UV2VC1 -- 0,1,1
                nl = fix( lsamp - (3*LFRAME*0.25) );
            end
            ipiti(1) = fix( nl * 0.5 );
            ipiti(2) = nl - ipiti(1);
            ivuv(1) = 0;
            ivuv(2) = 0;
            rmsi(1) = rmso;
            rmsi(2) = rmso;
            rci(:,1) = rco;
            rci(:,2) = rco;
            rco = rc;
            slope = 0;
            nout = 2;
            ipito = pitch;
            jused = nl;
            istart = nl + 1;
            ivoice = 1;
        else
            if ( ivoico ~= voice(1) )
                % VC2UV1 -- 1,0,0
                lsamp = fix( (LFRAME*0.25) + jsamp );
            else
                % VC2UV2 -- 1,1,0
                lsamp = fix( (3*LFRAME*0.25) + jsamp );
            end
            yarc = rc;
            rc = rco;
            ivoice = 1;
            slope = 0.0;
            vflag = 1;
        end
    end
    while 1 == 1
        for i = istart:lsamp
            ip = fix( ipito + (slope*i) + .5 );
            if uvpit ~= 0.0
                ip = fix(uvpit);
            end
            if ip <= i-jused
                nout = nout + 1;
                if nout > 11
                    fprintf( 'PITSYN ERROR: too many epochs\n' );
                    keyboard
                end
                ipiti(nout) = ip;
                pitch = ip;
                ivuv(nout) = ivoice;
                jused = jused + ip;
                prop = ( jused - (ip*0.5) ) / lsamp;
                alro = log( (1+rco) ./ (1-rco) );
                alrn = log( (1+rc) ./ (1-rc) );
                xxy = alro + ( prop .* ( alrn - alro ) );
                xxy = exp(xxy);
                rci(:,nout) = ( xxy - 1 ) ./ ( xxy + 1 );
                rmsi(nout) = log(rmso) + ( prop * ( log(rms) - log(rmso) ) );
                rmsi(nout) = exp( rmsi(nout) );
            end
        end
        if vflag ~= 1
            break;
        end
        vflag = 0;
        istart = jused + 1;
        lsamp = fix( LFRAME + jsamp );
        slope = 0;
        ivoice = 0;
        uvpit = (lsamp-istart) * 0.5;
        if uvpit > 90
            uvpit = uvpit * 0.5;
        end
        rmso = rms;
        rc = yarc;
        rco = yarc;
    end
    jsamp = lsamp - jused;
end
if nout ~=0
    ivoico = voice(2);
    ipito = pitch;
    rmso = rms;
    rco = rc;
end

