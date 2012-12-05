
tStart = tic;%start a timer
for i = 1 : 10000
    pdist2(rand(100), rand(100));
end
toc(tStart)