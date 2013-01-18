function bandPass = constrain(bandPass)
[row, col] = size(bandPass);
if row ~= 1 || col ~= 5
    error('size error');
end
constrains = [0 0 0 0 0; 1 0 0 0 0; 1 1 1 0 0; 1 1 1 1 1];

if bandPass(1) < 0.6
    bandPass(1:5) = 0;
else
    bandPass(1) = 1;
    for j = 2:5
        if bandPass(j) > 0.6
            bandPass(j) = 1;
        else
            bandPass(j) = 0;
        end
    end
    if isequal(bandPass(2:5), [0 0 0 1])
        bandPass(2:5) = 0;
    end
end

distance = zeros(4,1);
for j=1:4
    distance(j) = sqrt(sum(((bandPass(1:5)-constrains(j,:))).^2));
end
[value, idx] = min(distance);
bandPass(1:5) = constrains(idx,:);

end