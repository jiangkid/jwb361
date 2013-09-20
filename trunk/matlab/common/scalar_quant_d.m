function [ data ] = scalar_quant_d( data_idx, minValue, maxValue, bits )
%SCALAR_QUANT_D scalar quantization decode
if (data_idx < 0) || (data_idx > 2^bits-1)
    error('data_idx error');
end
data = (data_idx+0.5)*(maxValue-minValue)/(2^bits-1) + minValue;

end

