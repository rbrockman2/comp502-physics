% This function describes the weight shift that will occur or be stored
% (based on epoch). It creates a cell of equal dimension (including
% internal elements) to the W cell. 

function del_W = weight_shift_gen(Y,LGD,W,gamma)

% initializing del_W as a cell filled with matrices all set as zeros. 
del_W = cell(length(W),1);
for j = 1:length(W)
    del_W{j} = 0*W{j};
end

% Now I am going to concatenate the Y's with 1's for the biases. This is
% because the biases connect to weights that also need to be updated. 

Ycat = Y;
% -1 because we don't want a bias on the output layer. 
for i = 1:length(Y) - 1
    Ycat{i} = cat(1,Y{i},1);
end

% Now we need a triple loop to deal with select a weight submatrix
% in the weight cell and then also to select the row and the column

for k = 1:length(W)
    [rownum,colnum] = size(W{k});
    for i = 1:rownum
        for j = 1:colnum
            % we use Ycat to include the biases, which is also 
            % needed for the dimensions to match up (because the W 
            % submatrices have the bias built into their dimensions). 
            del_W{k}(i,j) = gamma*LGD{k+1}(i)*Ycat{k}(j);
        end
    end
end

return




