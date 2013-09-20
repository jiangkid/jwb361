function [ data ] = scalar_quant_d_v2( data_idx, minValue, maxValue, num )
%SCALAR_QUANT_D scalar quantization decode
if (data_idx < 0) || (data_idx > num)    
    error('data_idx error: %d',data_idx);
end
data = (data_idx+0.5)*(maxValue-minValue)/num + minValue;

end

