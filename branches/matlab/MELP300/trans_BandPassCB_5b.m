weight = [1.0 1.0 0.7 0.4 0.1];
BandPassCons = [0 0 0 0 0; 1 0 0 0 0; 1 1 1 0 0; 1 1 1 1 1];
for i=1:32
    [value, index] = GetMatch(BandPassCB_5b(i,1:5), BandPassCons, weight);
    BandPassCB_5b(i,1:5) = BandPassCons(index,:);
    [value, index] = GetMatch(BandPassCB_5b(i,6:10), BandPassCons, weight);
    BandPassCB_5b(i,6:10) = BandPassCons(index,:);
    [value, index] = GetMatch(BandPassCB_5b(i,11:15), BandPassCons, weight);
    BandPassCB_5b(i,11:15) = BandPassCons(index,:);
    [value, index] = GetMatch(BandPassCB_5b(i,16:20), BandPassCons, weight);
    BandPassCB_5b(i,16:20) = BandPassCons(index,:);    
end
save('BandPassCB_5b.mat','BandPassCB_5b');