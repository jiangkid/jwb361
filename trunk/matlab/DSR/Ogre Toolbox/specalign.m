function Si = specalign(S,X)

t = linspace(1,size(S,2),size(X,2));
Si = specinterp(S,t);
