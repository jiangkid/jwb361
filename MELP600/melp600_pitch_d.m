function pitch = melp600_pitch_d(pitchQ,mode)
%
global MODE1 MODE2 MODE3 MODE4 MODE5 MODE6;
global  pitchCB_6b pitchCB_8b;

switch mode
    case MODE1
        pitch = [0; 0; 0; 0];
    case MODE2
        pitch = MSVQ_d(pitchCB_6b,pitchQ);
        pitch = pitch';
    case {MODE3, MODE4, MODE5, MODE6}
        pitch = MSVQ_d(pitchCB_8b,pitchQ);
        pitch = pitch';
end
pitch = 10.^pitch;
end