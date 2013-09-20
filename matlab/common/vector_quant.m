function [ data_idx ] = vector_quant( data, codebook )
%VECTOR_QUANT vector quantization
[data_row, data_col] = size(data);
[cb_row, cb_col] = size(codebook);
if data_col ~= cb_col
    error('col error');
end
if data_row == 1
    distance = pdist2(data, codebook);
    [value, data_idx] = min(distance);
else
    data_idx = zeros(data_row,1);
    for idx = 1:data_row
        data_item = data(idx,:);        
        distance = pdist2(data_item, codebook);
        [value, data_idx(idx)] = min(distance);
    end
end

end

