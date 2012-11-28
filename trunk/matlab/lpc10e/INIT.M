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
% INIT
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 2-14-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Initializes all global and static data objects
%
% DESIGN NOTES
%
% "Statics" were implemented as packed matricies for several functions
% early in the development process.  Although these were preserved,
% the practice was abandoned in favor of using MATLAB globals where
% static behavior was required.
%
% INTERNAL VARIABLES
%   h0 - h15        -   LPF31 lowpass tap weights
%
% GLOBAL VARIABLES BY FUNCTION
%
% LPC10.M
%   SimRunning      -   First or subsequent call flag
%
% HP100.M
%   hp100z1         -   Highpass filter memory, first stage
%   hp100z2         -   Highpass filter memory, second stage
%
% ANALYS.M
%   inbuf           -   Raw speech, scaled to 12-bits + sign
%   pebuf           -   Preemphasized speech
%   lpbuf           -   Lowpass filtered speech buffer
%   awin            -   Analysis window indicies (3 frames)
%   ewin            -   Energy window indicies        "
%   rmsbuf          -   RMS energy                    "
%   rcbuf           -   Reflection coefficients       "
%   ivbuf           -   Inverse filtered speech
%   bias            -   DC bias estimate for input speech
%   tau             -   Table of AMDF pitch lags
%   voibuf          -   Voicing decisions for 3 frames
%
% LPFILT31.M
%   alpf31          -   Lowpass filter H(Z) denominator taps
%   blpf31          -   Lowpass filter H(Z) numerator taps
%   zlpf31          -   Lowpass filter H(Z) memory
%
% PREEMP.M
%   zpre            -   Preemphasis filter memory
%
% IVFILT.M
%   ziv             -   Inverse filter memory
%
% TBDM.M
%   tau2            -   Table of high-resolution lags
%
% VOICE.M
%   nvdcl           -   Number of voicing decision coefficient vectors (VDCs)
%   ref             -   Reference energy for for initialization/dither threshold
%   vstate          -   Decimal interpretation of binary voicing classification
%   dither          -   Zero crossing threshold level
%   sfbue           -   Static copy of full band unvoiced energy
%   slbue           -   Static copy of low band unvoiced energy
%   lbve            -   Low band voiced energy
%   fbve            -   Full band voiced energy
%   fbue            -   Full band unvoiced energy
%   ofbue           -   Previous full band unvoiced energy
%   lbue            -   Low band unvoiced energy
%   olbue           -   Previous low band unvoiced energy
%   snr             -   Estimated SNR
%   vdcl            -   SNR values corresponding to the set of VDCs
%   voice           -   History of linear discriminant analysis results
%   vdc             -   2-D voicing decision coefficient vector
%
% DYPTRK.M
%   ipoint          -   Current frame position pointer
%   alphax          -   Scaled version of alpha
%   s               -   Winner array
%   p               -   Pitch pointer array
%
% PLACEA.M
%   allv            -   True if five most recent half-frame decisions = V
%
% ENCODE.M
%   enctab          -   Table of Hamming 8,4 redundancy bits used for
%                       protection of RC1-RC4 during unvoiced frames.
%   entau           -   Pitch encoding table
%   enadd           -   Table of negative values of the bias of the
%                       probability density functions (pdf) of each of
%                       the last eight RCs.
%   enscl           -   Table of scale factors for each of the last eight
%                       RCs.
%   enbits          -   Table of number of shifts nescessary to properly
%                       scale each of the last 8 RCs to their respective
%                       bit allocations.
%   entab6          -   Log-area-ratio (LAR) table for encoding of RC1 and RC2
%   rmst            -   Energy encoding table
%
% DECODE.M
%   ivtab           -   Table containing all nescessary logical flow
%                       information for this routine.
%   corth           -   Smoothing threshold table, one row per error rate
%                       class (2-D, 4x8).
%   detau           -   Pitch decoding table
%   detab7          -   Table for inverse LAR decoding of RC1, RC2
%   descl           -   Table of scale factors for each of the last 8 RCs
%   deadd           -   Table of pdf biases for the last 8 RCs
%   qb              -   Quantization bias table of the last 8 RCs
%   nbit            -   Number of bits allocated to each of the RCs
%   zrc             -   Zero forcing table for RC5 through RC10
%   drc             -   Matrix of future, present, past, and last frame RCs
%   dpit            -   Vector of future, present, past, and last frame pitch
%   drms            -   Vector of future, present, past, and last frame RMS
%   ivp2h           -   Voicing condition of previous second half frame
%   erate           -   Measured bit error rate
%   iovoic          -   2-bit voicing condition code for present frame
%   first           -   Flag set only for first frame of data
%
% HAM84.M
%   dactab          -   Hamming 8,4 decode table
%
% SYNTHS.M
%   ivuv            -   Epoch voicing decisions
%   ipiti           -   Pitch epoch lengths
%   rmsi            -   Pitch epoch energy
%   rci             -   Pitch epoch reflection coefficients
%   pc              -   Pitch epoch predictor coefficients
%   sout            -   Pitch epoch output speech
%
% PITSYN.M
%   ivoico          -   Voicing decision of previous second half frame
%   ipito           -   Pitch of last epoch from previous frame
%   rmso            -   Energy of previous frame
%   rco             -   Reflection coefficients of previous frame
%   yarc            -   Temp storage for present frame RCs during voiced
%                       section of transition frame to unvoiced.
%   psFirst         -   Flag to indicate first call to PITSYN.M
%   jsamp           -   Number of samples from end of previous frame not
%                       yet assigned to an epoch.
%
% BSYNZ.M
%   kexc            -   Voiced excitation base sequence (predefined)
%   exc             -   Input excitation for LPC synthesis filter I (all zero)
%   exc2            -   Input and output for LPC synthesis filter II (all pole)
%   ipo             -   Pitch epoch length, previous epoch
%   bsRmso          -   Previous epoch energy
%   Zlpf            -   Filter memory, excitation LPF
%   Zhpf            -   Filter memory, excitation HPF
%
% RANDOM.M
%   j               -   Random tap index 1
%   k               -   Random tap index 2
%   y               -   Random generator taps
%
% DEEMPH.M
%   Zdemph          -   Deemphasis filter memory
%
% BUFMAN.M
%   BigBuf          -   Circular matching buffer - bsynz -> 180 samples/frame
%   sPtr            -   Head pointer
%   ePtr            -   Tail pointer
%
% GUI.M
%   guiDisplayMode  -   Frequency or time mode flag
%   guiDisplayType  -   Speech I/O, excitation, or pole plot flag
%   guiState        -   State flag: startup, runtime, or shutdown
%   guiSline        -   Handle to status line graphic object
%   guiSbuf1        -   Buffering allows gui to track LPC-10 buffering
%   guiSbuf2        -         "               "                "
%   guiSin          -   Input signal buffer for plotting
%   guiFrames       -   Number of frames in current input file
%   guiExcit        -   Excitation signal buffer for plotting
%
% "STATICS" - USED GLOBALS IN MOST PLACES RATHER THAN THESE
%   analysState     -   Static variables for analys.m
%   onsetState      -   Static variables for onset.m
%
% CONSTANTS
%   LFRAME          -   Input speech frame size
%   AF              -   Analysis frame index (into 3 frame buffer)
%   READ            -   Read flag to control diskio
%   WRITE           -   Write flag to control diskio
%   EOF             -   Status flag for diskio
%   OSLEN           -   Onset buffer size
%   MAXWIN          -   The maximum length of a window
%   LTAU            -   Number of points (lags) in the AMDF
%   SBUFL           -   The lower index of speech buffers INBUF and PEBUF
%   LBUFL           -   The lower index of speech buffer LPBUF
%   MAXORD          -   Maximum predictor order
%   ORDER           -   Predictor order
%   MIDTAP          -   Random number generator middle tap
%   MAXTAP          -   Random number generator last tap
%   MAXPIT          -   Maximum pitch period
%   DVWINL          -   Default lower index of the voicing window
%   DVWINH          -   Default upper index of the voicing window
%   MXVDCL          -   Voicing detection SNR array size
%   BBUFSIZE        -   Circular matching buffer size
%
% ******************************************************************

% CLEAR MEMORY
clear global
clear
clear all
clc

% DECLARE ALL GLOBAL CONSTANTS
global LFRAME AF OSLEN SBUFL LBUFL MAXORD MIDTAP MAXTAP MAXPIT;
global EOF READ WRITE MAXWIN LTAU ORDER;

% DEFINE GLOBAL CONSTANTS
READ        = 0;
WRITE       = 1;
EOF         = -99;
LFRAME      = 180;
AF          = 3;
OSLEN       = 10;
MAXWIN      = 156;
LTAU        = 60;
SBUFL       = 181;
LBUFL       = 25;
MAXORD      = 10;
ORDER       = 10;
MIDTAP      = 2;
MAXTAP      = 5;
MAXPIT      = 156;

% DECLARE ALL LOCAL CONSTANTS
DVWINL      = 307;
DVWINH      = 462;

% GLOBAL VARIABLES ARE DECLARED ADJACENT TO THEIR DEFINITIONS

% LPC10.M
global LPC10path
LPC10path = cd;

% LPCEXEC.M
global FrameCnt
FrameCnt = 0;

% HP100.M
global hp100z1 hp100z2;
hp100z1 = zeros( 2, 1 );
hp100z2 = zeros( 2, 1 );

% ANALYS.M
global inbuf pebuf lpbuf ivbuf bias zpre tau voibuf awin ewin rmsbuf rcbuf;
inbuf = zeros( LFRAME * AF, 1 );
pebuf = zeros( LFRAME * AF, 1 );
lpbuf = zeros( 696, 1 );
awin = zeros( 2, AF );
awin(1,AF) = DVWINL;
awin(2,AF) = DVWINH;
ewin = zeros( 2, AF );
rmsbuf = zeros( AF, 1 );
rcbuf = zeros( MAXORD, AF );
ivbuf = zeros( 312, 1 );
bias = 0.00;
zpre = zeros( 2, 1 );
tau = [ ...
	20,21,22,23,24,25,26,27,28,29,30,31,32,33,34, ...
	35,36,37,38,39,40,42,44,46,48,50,52,54,56,58,60,62,64,66, ...
	68,70,72,74,76,78,80,84,88,92,96,100,104,108,112,116,120, ...
	124,128,132,136,140,144,148,152,156 ...
      ];
tau = tau';
voibuf = zeros( 2, AF+1 );

% LPFILT31.M
global alpf31 blpf31 zlpf31;

% FILTER TAP WEIGHTS
h0          = -0.0097201988;
h1          = -0.0105179986;
h2          = -0.0083479648;
h3          =  0.0005860774;
h4          =  0.0130892089;
h5          =  0.0217052232;
h6          =  0.0184161253;
h7          =  0.0003397230;
h8          = -0.0260797087;
h9          = -0.0455563702;
h10         = -0.0403068550;
h11         =  0.0005029835;
h12         =  0.0729262903;
h13         =  0.1572008878;
h14         =  0.2247288674;
h15         =  0.2505359650;
blpf31      =  [ h0,  h1,  h2,  h3,  h4,  h5,  h6,  h7,...
		 h8,  h9,  h10, h11, h12, h13, h14, h15...
		 h14, h13, h12, h11, h10, h9,  h8,  h7,...
		 h6,  h5,  h4,  h3,  h2,  h1,  h0 ];
alpf31      =  zeros( 1, 31 );
zlpf31      =  zeros( 30, 1 );
alpf31(1,1) =  1.0;

% IVFILT.M
global ziv;

% INVERSE FILTER MEMORY
ziv = zeros( 8, 1 );

% TBDM.M
global tau2;
tau2 = zeros( 6, 1 );

% VOICE.M
global vstate dither snr maxmin voice vdc;
global lbve lbue fbve fbue ofbue olbue;
global sfbue slbue;
global MAXVDC MXVDCL;
global nvdc nvdcl;
global vdcl;

% INIT GENERAL VOICING DETECTION PARAMETERS
MAXVDC = 10;
MXVDCL = 10;
nvdcl = 5;
ref = 3000;
vstate = 0;
dither = 20;
sfbue = 0;
slbue = 0;
lbve = ref;
fbve = ref;
fbue = fix( ref/16 );
ofbue = fix( ref/16 );
lbue = fix( ref/32 );
olbue = fix( ref/32 );
snr = 64.0 * ( fbve/fbue );
vdcl = zeros( MXVDCL, 1 );
vdcl(1) = 600;
vdcl(2) = 450;
vdcl(3) = 300;
vdcl(4) = 200;
vdcl(5) = 0;
voice = zeros( 2,3 );


% INIT VOICING COEFFICIENT AND LINEAR DISCRIMINANT ANALYSIS VARIABLES
% VOICING DECISION PARAMETER VECTOR (* DENOTES ZERO COEFFICIENT)
%
%       * MAXMIN
%         LBE/LBVE
%         ZC
%         RC1
%         QS
%         IVRC2
%         aR_B
%         aR_F
%       * LOG(LBE/LBVE)

% Define 2-D voicing decision coefficient vector according to the voicing
% parameter order above.  Each row (VDC vector) is optimized for a specific
% SNR.  The last element of the vector is the constant.

%           E      ZC     RC1            Qs       IVRC2  aRb aRf  c

vdc = ...
    [ ...
	 0.,     0.,     0.,      0.,      0., 0., 0., 0., 0., 0.;...
      1714.,   874.,   510.,    500.,    500., 0., 0., 0., 0., 0.;...
     - 110.,   -97.,   -70.,    -10.,      0., 0., 0., 0., 0., 0.;...
       334.,   300.,   250.,    200.,      0., 0., 0., 0., 0., 0.;...
     -4096., -4096., -4096.,  -4096.,  -4096., 0., 0., 0., 0., 0.;...
      -654., -1021., -1270.,  -1300.,  -1300., 0., 0., 0., 0., 0.;...
      3752.,  2451.,  2194.,   2000.,   2000., 0., 0., 0., 0., 0.;...
      3769.,  2527.,  2491.,   2000.,   2000., 0., 0., 0., 0., 0.;...
	 0.,     0.,     0.,      0.,      0., 0., 0., 0., 0., 0.;...
      1181.,  -500., -1500.,  -2000.,  -2500., 0., 0., 0., 0., 0. ...
    ];

% DYPTRK.M
global ipoint alphax s p

% INIT DYNAMIC PROGRAMMING CONSTANTS
ipoint = 0;
alphax = 0;
p = zeros( 60, 2 );
s = zeros( 60, 1 );

% PLACEA.M
global allv

% INIT ANALYSIS WINDOW PLACEMENT FLAG
allv = 0;

% ENCODE.M
global enctab entau enadd enscl enbits entab6 rmst;

% LPC PARAMETER ENCODING TABLES
enctab = [ 0, 7, 11, 12, 13, 10, 6, 1, 14, 9, 5, 2, 3, 4, 8, 15 ]';

entau = [ ...
	19, 11, 27, 25, 29, 21, 23, 22, 30, 14, 15, 7, 39, ...
	38, 46, 42, 43, 41, 45, 37, 53, 49, 51, 50, 54, 52, ...
	60, 56, 58, 26, 90, 88, 92, 84, 86, 82, 83, 81, 85, ...
	69, 77, 73, 75, 74, 78, 70, 71, 67, 99, 97, 113, 112, ...
	114, 98, 106, 104, 108, 100, 101, 76 ...
	]';

enadd = [ 1920, -768, 2432, 1280, 3584, 1536, 2816, -1152]';

enscl = [ .0204, .0167, .0145, .0147, .0143, .0135, .0125, .0112 ]';

enbits = [ 6, 5, 4, 4, 4, 4, 3, 3 ]';

entab6 = [ ...
	 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, ...
	 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, ...
	 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 8, 8, 8, 8, ...
	 9, 9, 9, 10, 10, 11, 11, 12, 13, 14, 15 ...
	 ]';

rmst = [ ...
	1024, 936, 856, 784, 718, 656, 600, 550, ...
	502, 460, 420, 384, 352, 328, 294, 270, ...
	246, 226, 206, 188, 172, 158, 144, 132, ...
	120, 110, 102, 92, 84, 78, 70, 64, ...
	60, 54, 50, 46, 42, 38, 34, 32, ...
	30, 26, 24, 22, 20, 18, 17, 16, ...
	15, 14, 13, 12, 11, 10, 9, 8, ...
	7, 6, 5, 4, 3, 2, 1, 0 ...
       ]';

% DECODE.M
global ivtab corth detau detab7 descl deadd qb nbit zrc abit;
global drc dpit drms ivp2h erate iovoic first;

% LPC PARAMETER DECODING TABLES
ivtab = [ ...
	  24960, 24960, 24960, 24960, 25480, 25480, 25483, 25480, ...
	  16640,  1560,  1560,  1560, 16640,  1816,  1563,        ...
	   1560, 24960, 24960, 24859, 24856, 26001,               ...
	  25881, 25915, 25913, 1560,   1560,  7800,               ...
	   3640,  1561,  1561, 3643,   3641                       ...
	]';

corth = [ ...
	  32767., 32767., 32., 32.,  32.,  32., 16., 16.;  ...
	     10.,     8., 6.4, 6.4, 11.2, 11.2, 5.6, 5.6;  ...
	      5.,     4., 3.2, 3.2,  6.4,  6.4, 3.2, 3.2;  ...
	      0.,     0.,  0.,  0.,   0.,   0.,  0., 0.    ...
	];

detau = [ ...
	  0,     0,   0,   3,   0,   3,   3,  31,   0,  3,   3, 21,   3,  3, 29, 30, ...
	  0,     3,   3,  20,   3,  25,  27,  26,   3, 23,  58, 22,   3, 24, 28,  3, ...
	  0,     3,   3,   3,   3,  39,  33,  32,   3, 37,  35, 36,   3, 38, 34,  3, ...
	  3,    42,  46,  44,  50,  40,  48,   3,  54,  3,  56,  3,  52,  3,  3,  1, ...
	  0,     3,   3, 108,   3,  78, 100, 104,   3, 84,  92, 88, 156, 80, 96,  3, ...
	  3,    74,  70,  72,  66,  76,  68,   3,  62,  3,  60,  3,  64,  3,  3,  1, ...
	  3,   116, 132, 112, 148, 152,   3,   3, 140,  3, 136,  3, 144,  3,  3,  1, ...
	  124, 120, 128,   3,   3,   3,   3,   1,   3,  3,   3,  1,   3,  1,  1,  1  ...
	]';

detab7 = [ ...
	     4,  11,  18,  25,  32,  39,  46,  53, ...
	    60,  66,  72,  77,  82,  87,  92,  96, ...
	   101, 104, 108, 111, 114, 115, 117, 119, ...
	   121, 122, 123, 124, 125, 126, 127, 127  ...
	 ]';

descl = [ .6953, .6250, .5781, .5469, .5312, .5391, .4688, .3828 ]';
deadd = [ 1152, -2816, -1536, -3584, -1280, -2432, 768, -1920 ]';
qb    = [ 511, 511, 1023, 1023, 1023, 1023, 2047, 4095 ]';
nbit  = [ 8, 8, 5, 5, 4, 4, 4, 4, 3, 2 ]';
zrc   = [ 0, 0, 0, 0, 0, 3, 0, 2, 0, 0 ]';
abit  = [ 2, 4, 8, 16, 32 ]';

% INIT DECODING VARIABLES
drc = zeros( 3, MAXORD );
dpit = zeros( 3 );
drms = zeros( 3 );
ivp2h = 0;
erate = 0;
iovoic = 0;
first = 1;

% HAM84.M
global dactab;

% INIT HAMMING 8,4 DECODING TABLE
dactab = [ ...
	   16,  0,  0,  3,  0,  5, 14,  7,  0,  9, 14, 11,           ...
	   14, 13, 30, 14,  0,  9,  2,  7,  4,  7,  7, 23,  9,       ...
	   25, 10,  9, 12,  9, 14,  7,  0,  5,  2, 11,  5, 21,       ...
	    6,  5,  8, 11, 11, 27, 12,  5, 14, 11,  2,  1, 18,       ...
	    2, 12,  5,  2,  7, 12,  9,  2, 11, 28, 12, 12, 15,       ...
	    0,  3,  3, 19,  4, 13,  6,  3,  8, 13, 10,  3, 13, 29,   ...
	   14, 13,  4,  1, 10,  3, 20,  4,  4,  7, 10,  9, 26,       ...
	   10,  4, 13, 10, 15,  8,  1,  6,  3,  6,  5, 22,  6, 24,   ...
	    8,  8, 11,  8, 13,  6, 15,  1, 17,  2,  1,  4,  1,  6,   ...
	   15,  8,  1, 10, 15, 12, 15, 15, 31                        ...
	 ]';

% SYNTHS.M
global ivuv ipiti rmsi rci pc sout;

% INITIALIZE SYNTHS PITCH EPOCH VARIABLES
ivuv = zeros(11,1);
ipiti = zeros(11,1);
rmsi = zeros(11,1);
rci = zeros(MAXORD,11);
pc = zeros(MAXORD,1);
sout = zeros(LFRAME,1);

% PITSYN.M
global ivoico ipito rmso psFirst rco yarc jsamp;

% INITIALIZE PITSYN INTERNALS
ivoico = 0;
ipito = 0;
rmso = 0;
psFirst = 1;
rco = zeros(MAXORD,1);
yarc = zeros(MAXORD,1);
jsamp = 0;

% BSYNZ.M
global kexc exc exc2 ipo bsRmso Zhpf Zlpf

% INITIALIZE SYNTHESIS VARIABLES
kexc = [                                                        ...
	   8, -16,   26,  -48,  86, -162, 294, -502, 718, -728, ...
	 184, 672, -610, -672, 184,  728, 718,  502, 294,  162, ...
	  86,  48,   26,   16,   8                              ...
       ]';
exc = zeros( MAXPIT+MAXORD, 1 );
exc2 = zeros( MAXPIT+MAXORD, 1 );
ipo = 0;
bsRmso = 0;
Zlpf = zeros(2,1);
Zhpf = zeros(2,1);

% RANDOM.M
global j k y;

% INITIALIZE RANDOM NUMBER GENERATOR
y = [ -21161, -8478, 30892, -10216, 16950 ]';
j = MIDTAP;
k = MAXTAP;

% DEEMPH.M
global Zdemph;

% INITIALIZE DEEMPHASIS FILTER TAPS
Zdemph = zeros(4,1);

% BUFMAN.M
global BigBuf sPtr ePtr BBUFSIZE;

% INITIALIZE BUFFER MANAGEMENT CONSTANTS
sPtr = 1;
ePtr = 361;
BBUFSIZE = 600;
BigBuf = zeros( BBUFSIZE,1 );

% GUI.M
global guiSbuf1 guiSbuf2 guiSin guiDisplayMode guiState guiSline guiDisplayType;
global guiExcit guiFrames;

% INIT GRAPHICAL USER INTERFACE (GUI)
close;
guiDisplayMode = 0;
guiDisplayType = 0;
guiSline = 0;
guiSbuf1 = zeros( LFRAME, 1 );
guiSbuf2 = zeros( LFRAME, 1 );
guiSin = zeros( LFRAME, 1 );
guiFrames = 0;
guiExcit = [];

% INITIALIZE FUNCTION STATIC VARIABLES
analysState = zeros( 10, 6 );     % 1=osbuf,2=osptr,3:5=vwin,6=obound
analysState( 1, 5 ) = DVWINL;     % vwin(1,AF)=DVWINH
analysState( 2, 5 ) = DVWINH;     % vwin( 2, AF ) = DVWINH
onsetState = zeros( 15, 6 );
onsetState( 1, 4 ) = 63.0/64.0;   % zd = 63./64. same as d=1. in C code.

% START GUI
guiinit(0);
