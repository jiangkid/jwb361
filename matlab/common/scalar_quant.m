function [ data_idx ] = scalar_quant( data, minValue, maxValue, bits )
%scalar_quant scalar quantization
%   Detailed explanation goes here
if(data > maxValue)
    data = maxValue;
elseif(data < minValue)
    data = minValue;
end
data_idx = round(((data-minValue)/(maxValue-minValue))*(2^bits-1));

end

