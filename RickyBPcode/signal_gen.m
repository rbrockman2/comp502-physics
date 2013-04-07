% Signal_gen takes an input vector and a weight structure and returns
% the output y values at each node in the network. e.g. in a 3-2-3
% network, Y will be a cell with three entries, each respectively a 
% vector of length 3, 2, and 3. 

% Biases do not hold space in the Y cell (although they impact how it is
% created). Because of MATLAB conventions, layer 1 is the input later
% (and also, Y{1} == x). 

% In summary, the y values are nothing more than the signal outputted
% by each node in the network.

function Y = signal_gen(x,W)

n = length(W) + 1;
Y = cell(n,1);
Y{1} = x;

for i = 2:n
    Y{i} = tanh(W{i-1}*(cat(1,Y{i-1},1)));
end

return




