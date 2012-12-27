%1000Hz Butterworth lowpass filter
global butt_1000ord;    %order
global butt_1000num;    %numerator coefficient,descend order
global butt_1000den;    %denumerator coefficient,descend order

%five Butterworth bandpass filters 
global butt_bp_ord;     %order
global butt_bp_num;     %numerator coefficient ,descend order
global butt_bp_den;     %denumerator coefficient ,descend order

%smoothing filter
global smooth_ord;      %order
global smooth_num;      %numerator coefficient,descend order
global smooth_den;      %denumerator coefficient,descend order

%direct current remove filter
global dcr_ord;         %order
global dcr_num;         %numerator coefficient,,descend order
global dcr_den;         %denumerator coefficient,,descend order

%5 FIR filters
global fir_ord;         %order
global melp_firs;       %coefficient

%Butterworth lowpass filter
butt_1000ord=6;
butt_1000num=[0.00105165,0.00630988,0.01577470,0.02103294,0.01577470,0.00630988,0.00105165];
butt_1000den=[1.00000000,-2.97852993,4.13608100,-3.25976428,1.51727884,-0.39111723,0.04335699];

%Butterworth bandpass filters
%0~500,500~1000,1000~2000,2000~3000,3000~4000
butt_bp_ord=6;
butt_bp_num=[0.00002883,0.00017296,0.00043239,0.00057652,0.00043239,0.00017296,0.00002883;...
    0.00530041,0.00000000,-0.01590123,0.00000000,0.01590123,0.00000000,-0.00530041;...
    0.03168934,0.00000000,-0.09506803,-0.00000000,0.09506803,-0.00000000,-0.03168934;...
    0.03168934,0.00000000,-0.09506803,0.00000000,0.09506803,0.00000000,-0.03168934;...
    0.00105165,-0.00630988,0.01577470,-0.02103294,0.01577470,-0.00630988,0.00105165];
butt_bp_den=[1.00000000,-4.48456301,8.52900508,-8.77910797,5.14764268,-1.62771478,0.21658286;...
    1.00000000,-4.42459751,8.79771496,-9.95335557,6.75320305,-2.60749972,0.45354593;...
    1.00000000,-1.84699031,2.63060194,-2.21638838,1.57491237,-0.62291281,0.19782519;...
    1.00000000,1.84699031,2.63060194,2.21638838,1.57491237,0.62291281,0.19782519;...
    1.00000000,2.97852993,4.13608100,3.25976428,1.51727884,0.39111723,0.04335699];

%smooth filter for fullwave rectifier
smooth_ord=2;
smooth_num=[1,-1,0];
smooth_den=[1,-1.9266,0.9409];

%DC remove filter
dcr_ord=4;
dcr_num=[0.9269,-3.7056,5.5574,-3.7056,0.9269];
dcr_den=[1.00000000,-3.84610723,5.55209760,-3.56516069,0.85918839];

%This appendix lists the coefficients of the five bandpass filters used in the decoder.
%0 - 500Hz   500 - 1000Hz   1000 - 2000Hz   2000 - 3000Hz   3000 - 4000Hz 0��1000Hz
fir_ord=31;
melp_firs=[...
      -0.00302890,-0.00249420,-0.00231491,0.00231491,0.00554149;...
      -0.00701117,-0.00282091,0.00990113,0.00990113,-0.00981750;...
      -0.01130619,0.00257679,0.02086129,-0.02086129,0.00856805;...
      -0.01494082,0.01451271,-0.00000000,0.00000000,-0.00000000;...
      -0.01672586,0.02868120,-0.03086123,0.03086123,-0.01267517;...
      -0.01544189,0.03621179,-0.02180695,-0.02180695,0.02162277;...
      -0.01006619,0.02784469,0.00769333,-0.00769333,-0.01841647;...
      0.00000000,0.00000000,-0.00000000,-0.00000000,0.00000000;...
      0.01474923,-0.04079870,-0.01127245,0.01127245,0.02698425;...
      0.03347158,-0.07849207,0.04726837,0.04726837,-0.04686914;...
      0.05477206,-0.09392213,0.10106105,-0.10106105,0.04150730;...
      0.07670890,-0.07451087,-0.00000000,0.00000000,-0.00000000;...
      0.09703726,-0.02211575,-0.17904543,0.17904543,-0.07353666;...
      0.11352143,0.04567473,-0.16031428,-0.16031428,0.15896026;...
      0.12426379,0.10232715,0.09497157,-0.09497157,-0.22734513;...
      0.12799355,0.12432599,0.25562154,0.25562154,0.25346255;...
      0.12426379,0.10232715,0.09497157,-0.09497157,-0.22734513;...
      0.11352143,0.04567473,-0.16031428,-0.16031428,0.15896026;...
      0.09703726,-0.02211575,-0.17904543,0.17904543,-0.07353666;...
      0.07670890,-0.07451087,-0.00000000,0.00000000,-0.00000000;...
      0.05477206,-0.09392213,0.10106105,-0.10106105,0.04150730;...
      0.03347158,-0.07849207,0.04726837,0.04726837,-0.04686914;...
      0.01474923,-0.04079870,-0.01127245,0.01127245,0.02698425;...
      0.00000000,-0.00000000,-0.00000000,-0.00000000,0.00000000;...
      -0.01006619,0.02784469,0.00769333,-0.00769333,-0.01841647;...
      -0.01544189,0.03621179,-0.02180695,-0.02180695,0.02162277;...
      -0.01672586,0.02868120,-0.03086123,0.03086123,-0.01267517;...
      -0.01494082,0.01451271,-0.00000000,0.00000000,-0.00000000;...
      -0.01130619,0.00257679,0.02086129,-0.02086129,0.00856805;...
      -0.00701117,-0.00282091,0.00990113,0.00990113,-0.00981750;...
      -0.00302890,-0.00249420,-0.00231491,0.00231491,0.00554149];