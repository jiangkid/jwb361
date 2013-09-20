function [ data_idx ] = scalar_quant_v2( data, minValue, maxValue, num )
%scalar_quant scalar quantization
%   Detailed explanation goes here
if(data > maxValue)
    data = maxValue;
elseif(data < minValue)
    data = minValue;
end
data_idx = round(((data-minValue)/(maxValue-minValue))*num);

end
