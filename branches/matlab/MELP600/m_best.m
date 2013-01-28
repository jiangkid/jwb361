function dataOut = m_best(dataIn, codebook, w, m)
%m_best 在codebook中搜索最佳匹配的数据
[row_data, col_data] = size(dataIn);
[row_CB, col_CB] = size(codebook);
if nargin ~= 4
    error('input error');
end

JUDGE = 100000000;
%d(m,1:col_CB) is the minus of the vector and the codeword
%d(m,2:col_CB+1) is the judgement.
%d(m,col_CB+2) is the codeword.
d(1:m,1:col_CB+2)=JUDGE;
for row=1:row_data
    for s=1:row_CB
        delta=dataIn(row,1:col_CB)-codebook(s,:);
        temp=w*(delta.^2)';
        for i = 1:m
            if temp<d(i,col_CB+1)
                d(i+1:m+1,:)=d(i:m,:);%数据下移
                d(i,1:col_CB)=delta;%
                d(i,col_CB+1)=temp;
                if row_data == 1
                    d(i,col_CB+2)=s;
                else
                    d(i,col_CB+2:col_data)=dataIn(row,col_CB+2:col_data);
                    d(i,col_data+1)=s;
                end
                break;
            end
        end
    end
end
dataOut = d;
end