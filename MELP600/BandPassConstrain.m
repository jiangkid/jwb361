function bandPass = BandPassConstrain(dataIn)
%BandPassConstrain 
superSize = size(dataIn, 1);
if superSize ~= 4
    error('bandPass size ~= 4');
end
constrains = [0 0 0 0 0; 1 0 0 0 0; 1 1 1 0 0; 1 1 1 1 1];
for i=1:superSize
    if dataIn(i,1) < 0.6
        dataIn(i,:) = 0;
    else
        dataIn(i,1) = 1;
        for j = 2:5
            if dataIn(i, j) > 0.6
                dataIn(i, j) = 1;
            else
                dataIn(i, j) = 0;
            end
        end        
        if isequal(dataIn(i, 2:5), [0 0 0 1])
            dataIn(i, 2:5) = 0;
        end
    end
end
bandPass = zeros(superSize, 5);
for i=1:superSize
    distance = zeros(4,1);
    for j=1:4
        distance(j) = sqrt(sum(((dataIn(i,:)-constrains(j,:))).^2));
    end
    [value, idx] = min(distance);
    bandPass(i,:) = constrains(idx,:);
end

end