clear;
TRANS = [.9 .1; .05 .95;];

EMIS = [1/6, 1/6, 1/6, 1/6, 1/6, 1/6;...
7/12, 1/12, 1/12, 1/12, 1/12, 1/12];
[seq,states] = hmmgenerate(1000,TRANS,EMIS);

%Estimating the State Sequence
likelystates = hmmviterbi(seq, TRANS, EMIS);

% Estimating Transition and Emission Matrices
[TRANS_EST, EMIS_EST] = hmmestimate(seq, states);

TRANS_GUESS = [.85 .15; .1 .9];
EMIS_GUESS = [.17 .16 .17 .16 .17 .17;.6 .08 .08 .08 .08 08];
[TRANS_EST2, EMIS_EST2] = hmmtrain(seq, TRANS_GUESS, EMIS_GUESS);

% Estimating Posterior State Probabilities
PSTATES = hmmdecode(seq,TRANS,EMIS);
fprintf('end\n');