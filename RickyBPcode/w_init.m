% function to initialize the weight structure. This structure includes
% the biases

% n is a vector where n(i) is the # of elements in layer i (where we 
% index from 1 because we are in MATLAB)

function W0 = w_init(PE_per_layer,scaledown)

n = length(PE_per_layer);

W0 = cell(n-1,1);

for i = 1:n-1
    W0{i} = randn(PE_per_layer(i+1),PE_per_layer(i)+1)/scaledown;
end

return

