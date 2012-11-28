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
% ******************************************************************************
% VOICING
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 3-8-94
%
% ******************************************************************************
%
% DESCRIPTION
%
%   Voicing Detection (VOICIN) makes voicing decisions for each half
%   frame of input speech.
%
% DESIGN NOTES
%
%   Tentative voicing decisions are made two frames
%   in the future (2F) for each half frame.  These decisions are carried
%   through one frame in the future (1F) to the present (P) frame where
%   they are examined and smoothed, resulting in the final voicing
%   decisions for each half frame.
%
%        The voicing parameter (signal measurement) column vector (VALUE)
%   is based on a rectangular window of speech samples determined by the
%   window placement algorithm.  The voicing parameter vector contains the
%   AMDF windowed maximum-to-minimum ratio, the zero crossing rate, energy
%   measures, reflection coefficients, and prediction gains.  The voicing
%   window is placed to avoid contamination of the voicing parameter vector
%   with speech onsets.
%
%        The input signal is then classified as unvoiced (including
%   silence) or voiced.  This decision is made by a linear discriminant
%   function consisting of a dot product of the voicing decision
%   coefficient (VDC) row vector with the measurement column vector
%   (VALUE).  The VDC vector is 2-dimensional, each row vector is optimized
%   for a particular signal-to-noise ratio (SNR).  So, before the dot
%   product is performed, the SNR is estimated to select the appropriate
%   VDC vector.
%
%        The smoothing algorithm is a modified median smoother.  The
%   voicing discriminant function is used by the smoother to determine how
%   strongly voiced or unvoiced a signal is.  The smoothing is further
%   modified if a speech onset and a voicing decision transition occur
%   within one half frame.  In this case, the voicing decision transition
%   is extended to the speech onset.  For transmission purposes, there are
%   constraints on the duration and transition of voicing decisions.  The
%   smoother takes these constraints into account.
%
%        Finally, the energy estimates are updated along with the dither
%   threshold used to calculate the zero crossing rate (ZC).
%
% VARIABLES
%
% INPUTS
%   vwin           - Voicing window limits
%   inbuf          - Input speech buffer
%   lpbuf          - Low-pass filtered speech buffer
%   half           - Present analysis half frame number
%   minamd         - Minimum value of the AMDF
%   maxamd         - Maximum value of the AMDF
%   mintau         - Pointer to the lag of the minimum AMDF value
%   ivrc           - Inverse filter's RC's
%   obound         - Onset boundary descriptions
%
% OUTPUT
%   voibuf         - Buffer of voicing decisions
%
% INTERNAL
%   qs             - Ratio of preemphasized to full-band energies
%   rc1            - First reflection coefficient
%   ar_b           - Product of the causal forward and reverse pitch
%                    prediction gains
%   ar_f           - Product of the noncausal forward and rev. pitch
%                    prediction gains
%   zc             - Zero crossing rate
%   dither         - Zero crossing threshold level
%   maxmin         - AMDF's 1 octave windowed maximum-to-minimum ratio
%   minptr         - Location  of minimum AMDF value
%   nvdc           - Number of elements in each VDC vector
%   nvdcl          - Number of VDC vectors
%   vdcl           - SNR values corresponding to the set of VDC's
%   vdc            - 2-D voicing decision coefficient vector
%   value          - Voicing Parameters
%   voice          - History of LDA results
%   lbe            - Ratio of low-band instantaneous to average energies
%   fbe            - Ratio of full-band instantaneous to average energies
%   lbve           - Low band voiced energy
%   lbue           - Low band unvoiced energy
%   fbve           - Full band voiced energy
%   fbue           - Full band unvoiced energy
%   ofbue          - Previous full-band unvoiced energy
%   olbue          - Previous low-band unvoiced energy
%   ref            - Reference energy for initialization and DITHER
%                    threshold
%   snr            - Estimate of signal-to-noise ratio
%   snr2           - Estimate of low-band signal-to-noise ratio
%   snrl           - SNR level number
%   ot             - Onset transition present
%   vstate         - Decimal interpretation of binary voicing classifications
%
% ******************************************************************************

function voibuf = voicing( vwin, inbuf, lpbuf, half, minamd, maxamd,...
			   mintau, ivrc, obound, voibuf )

% DECLARE GLOBAL VARIABLES
global vstate dither snr maxmin voice vdc;
global lbve lbue fbve fbue ofbue olbue;
global sfbue slbue;
global MAXVDC MXVDCL;
global nvdc nvdcl;
global vdcl;

% DECLARE AND INITIALIZE LOCAL VARIABLES
value = zeros( 9, 1 );
ot = 0;
ref = 3000;

% The VOICE array contains the result of the linear discriminant function
% (analog values).  The VOIBUF array contains the hard-limited binary
% voicing decisions.  The VOICE and VOIBUF arrays, according to FORTRAN
% memory allocation, are addressed as:
%
%          (half-frame number, future-frame number)
%
%          |   Past    |  Present  |  Future1  |  Future2  |
%          | 1,0 | 2,0 | 1,1 | 2,1 | 1,2 | 2,2 | 1,3 | 2,3 |  --->  time
%
% Update linear discriminant function history each frame:
if half == 1
    voice(1,1) = voice(1,2);
    voice(2,1) = voice(2,2);
    voice(1,2) = voice(1,3);
    voice(2,2) = voice(2,3);
    maxmin = maxamd / max( [ minamd, 1.0 ] );
end

% CALCULATE VOICING PARAMETERS TWICE PER FRAME
[ dither, zc, lbe, fbe, qs, rc1, ar_b, ar_f ] = ...
vparms( vwin, inbuf, lpbuf, half, dither, mintau );

% ESTIMATE SIGNAL-TO-NOISE RATIO TO SELECT THE APPROPRIATE VDC VECTOR.
% THE SNR IS ESTIMATED AS THE RUNNING AVERAGE OF THE RATIO OF THE
% RUNNING AVERAGE FULL-BAND VOICED ENERGY TO THE RUNNING AVERAGE
% FULL-BAND UNVOICED ENERGY. SNR FILTER HAS GAIN OF 63.
snr = round( 63 * ( snr + ( fbve / ( max ( [ fbue, 1.0 ] ) ) ) ) / 64.0 );
snr2 = ( snr * fbue ) / max( [ lbue, 1 ] );

% QUANTIZE SNR TO SNRL ACCORDING TO VDCL THRESHOLDS.
snrl = 1;
while snrl < nvdcl
    if snr2 > vdcl(snrl)
	break;
    end
    snrl = snrl + 1;
end

% NOTE: SNRL = NVDCL Here
% LINEAR DISCRIMINANT VOICING PARAMETERS
value(1) = maxmin;
value(2) = lbe / max( [ lbve, 1.0 ] );
value(3) = zc;
value(4) = rc1;
value(5) = qs;
value(6) = ivrc(2);
value(7) = ar_b;
value(8) = ar_f;
value(9) = 0.0;

% EVALUATION OF LINEAR DISCRIMINANT FUNCTION
voice(half,3) = vdc(10,snrl) + sum( vdc(1:9,snrl) .* value(1:9) );

% CLASSIFY AS VOICED IF DISCRIMINANT > 0, OTHERWISE UNVOICED
% VOICING DECISION FOR CURRENT HALF-FRAME: 1 = VOICED, 0 = UNVOICED
if voice(half,3) > 0.0
    voibuf(half,4) = 1;
else
    voibuf(half,4) = 0;
end

%   VOICING DECISION SMOOTHING RULES (OVERRIDE OF LINEAR COMBINATION)
%
%   UNVOICED HALF-FRAMES:  AT LEAST TWO IN A ROW.
%       --------------------
%
%       VOICED HALF-FRAMES:    AT LEAST TWO IN A ROW IN ONE FRAME.
%       -------------------    OTHERWISE AT LEAST THREE IN A ROW.
%                              (DUE TO THE WAY TRANSITION FRAMES ARE ENCODED)
%
%       IN MANY CASES, THE DISCRIMINANT FUNCTION DETERMINES HOW TO SMOOTH.
%       IN THE FOLLOWING CHART, THE DECISIONS MARKED WITH A * MAY BE OVERRIDDEN.
%
%   VOICING OVERRIDE OF TRANSITIONS AT ONSETS:
%       IF A V/UV OR UV/V VOICING DECISION TRANSITION OCCURS WITHIN ONE-HALF
%       FRAME OF AN ONSET BOUNDING A VOICING WINDOW, THEN THE TRANSITION IS
%       MOVED TO OCCUR AT THE ONSET.
%
%       P       1F
%       -----   -----
%       0   0   0   0
%       0   0   0*  1   (IF THERE IS AN ONSET THERE)
%       0   0   1*  0*  (BASED ON 2F AND DISCRIMINANT DISTANCE)
%       0   0   1   1
%       0   1*  0   0   (ALWAYS)
%       0   1*  0*  1   (BASED ON DISCRIMINANT DISTANCE)
%       0*  1   1   0*  (BASED ON PAST, 2F, AND DISCRIMINANT DISTANCE)
%       0   1*  1   1   (IF THERE IS AN ONSET THERE)
%       1   0*  0   0   (IF THERE IS AN ONSET THERE)
%       1   0   0   1
%       1   0*  1*  0   (BASED ON DISCRIMINANT DISTANCE)
%       1   0*  1   1   (ALWAYS)
%       1   1   0   0
%       1   1   0*  1*  (BASED ON 2F AND DISCRIMINANT DISTANCE)
%       1   1   1*  0   (IF THERE IS AN ONSET THERE)
%       1   1   1   1
%

% SKIP VOICING DECISION SMOOTHING IN FIRST HALF-FRAME
if half ~= 1

    % DETERMINE IF THERE IS AN ONSET TRANSITION BETWEEN P AND 1F.
    % OT (ONSET TRANSITION) IS TRUE IF THERE IS AN ONSET BETWEEN
    % P AND 1F BUT NOT AFTER 1F.
    if ( (rem(fix(obound(1)/2),2) ~= 0) | (obound(2) == 1) ) & (rem(obound(3),2) == 0)
	ot = 1;
    else
	ot = 0;
    end

    % MULTI-WAY DISPATCH ON VOICING DECISION HISTORY
    vstate = voibuf(1,2)*8 + voibuf(2,2)*4 + voibuf(1,3)*2 + voibuf(2,3);
    vs = vstate + 1;
    if vs == 1
	% DO NOTHING
    elseif vs == 2
	if ot & (voibuf(1,4)==1)
	    voibuf(1,3) = 1;
	end
    elseif vs == 3
	if (voibuf(1,4)==0) | (voice(1,2) < -voice(2,2))
	    voibuf(1,3) = 0;
	else
	    voibuf(2,3) = 1;
	end
    elseif vs == 4
	% DO NOTHING
    elseif vs == 5
	voibuf(2,2) = 0;
    elseif vs == 6
	if voice(2,1) < -voice(1,2)
	    voibuf(2,2) = 0;
	else
	    voibuf(1,3) = 1;
	end
    elseif vs == 7
	if (voibuf(1,1)==1) | (voibuf(1,4)==1) | (voice(2,2)>voice(1,1))
	    voibuf(2,3) = 1;
	else
	    voibuf(1,2) = 1;
	end
    elseif vs == 8
	if ot
	    voibuf(2,2) = 0;
	end
    elseif vs == 9
	if ot
	    voibuf(2,2) = 1;
	end
    elseif vs == 10
	% DO NOTHING
    elseif vs == 11
	if voice(1,2) < -voice(2,1)
	    voibuf(1,3) = 0;
	else
	    voibuf(2,2) = 1;
	end
    elseif vs == 12
	voibuf(2,2) = 1;
    elseif vs == 13
	% DO NOTHING
    elseif vs == 14
	if (voibuf(1,4)==0) & (voice(2,2) < -voice(1,2))
	    voibuf(2,3) = 0;
	else
	    voibuf(1,3) = 1;
	end
    elseif vs == 15
	if ot & (voibuf(1,4)==0)
	    voibuf(1,3) = 0;
	end
    else
	% DO NOTHING
    end
end

% NOW UPDATE PARAMETERS
% ---------------------
% DURING UNVOICED HALF-FRAMES, UPDATE THE LOW BAND AND FULL BAND UNVOICED
% ENERGY ESTIMATES (LBUE AND FBUE) AND ALSO THE ZERO CROSSING
% THRESHOLD (DITHER).  (THE INPUT TO THE UNVOICED ENERGY FILTERS IS
% RESTRICTED TO BE LESS THAN 10DB ABOVE THE PREVIOUS INPUTS OF THE
% FILTERS.)
% DURING VOICED HALF-FRAMES, UPDATE THE LOW-PASS (LBVE) AND ALL-PASS
% (FBVE) VOICED ENERGY ESTIMATES.                                       */
if voibuf(half,4) == 0
    sfbue = round( ((63*sfbue)+(8*min([fbe,3*ofbue]))) / 64.0 );
    fbue  = fix(sfbue/8);
    ofbue = fbe;
    slbue = round( ((63*slbue)+(8*min([lbe,3*olbue]))) / 64.0 );
    lbue  = fix(slbue/8);
    olbue = lbe;
else
    lbve = round( ((63*lbve)+lbe) / 64.0 );
    fbve = round( ((63*fbve)+fbe) / 64.0 );
end

% SET DITHER THRESHOLD TO YIELD PROPER ZERO CROSSING RATES IN THE
% PRESENCE OF LOW FREQUENCY NOISE AND LOW LEVEL SIGNAL INPUT.
% NOTE: THE DIVISOR IS A FUNCTION OF REF, THE EXPECTED ENERGIES.
dither = min( [ max([((64*sqrt(lbue*lbve))/ref),1.0]), 20.0 ] );

