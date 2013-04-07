% A bundling of the three subfunctions together to generate weight
% updates. "prop" is for proposed--the weight shift proposed will be 
% stored instead of enacted if we have a nontrivial epoch. 

% x is the selected input, d the corresponding desired output, and
% W is our current matrix. 

% This function bundles the process of finding the proposed weights to
% shift into one simple function. 

function current_shift = prop_weight_shift(x,d,W,gamma)

Y = signal_gen(x,W);
LGD = delta_gen(d,Y,W);
current_shift = weight_shift_gen(Y,LGD,W,gamma);

return



