clear;
addpath(genpath('F:\matlab\HMMall'));
stateNum = 3;
observeNum = 4;
TRANS = [0.4 0.6 0;0 0.3 0.7;0 0 1];
EMIS = mk_stochastic(rand(stateNum,observeNum));

[seq,states] = hmmgenerate(1000,TRANS,EMIS);

TRANS_GUESS = [0.5 0.5 0;0 0.5 0.5;0 0 1];
EMIS_GUESS = ones(stateNum,observeNum)/observeNum;
[TRANS_EST, EMIS_EST] = hmmtrain(seq, TRANS_GUESS, EMIS_GUESS);

% Estimating Posterior State Probabilities
[PSTATES,logpseq] = hmmdecode(seq,TRANS,EMIS);
[PSTATES2,logpseq2] = hmmdecode(seq,TRANS_EST,EMIS_EST);

fprintf('end\n');