function [ data_idx ] = vector_quant( data, codebook )
%VECTOR_QUANT vector quantization
[data_row, data_col] = size(data);
[cb_row, cb_col] = size(codebook);
if data_col ~= cb_col
    error('col error');
end
distance = pdist2(data, codebook);
[value, data_idx] = min(distance);

end

