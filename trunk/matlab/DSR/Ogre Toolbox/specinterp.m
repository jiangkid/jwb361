function Si = specinterp(S,t,method)

[row,col] = size(S);

if t>col,
    warning('extrapolating');
end
if nargin < 3,
    method = 'linear';
end

for k = 1:row,
    Si(k,:) = interp1([1:col],S(k,:),t,method,'extrap');
end
