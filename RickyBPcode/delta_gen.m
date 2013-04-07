% delta_gen works in the reverse direction as signal_gen. It 
% backpropagates a form of the error term. 


function LGD = delta_gen(d,Y,W)

n = length(Y);
LGD = cell(n,1);

% This time I will initialize the *entries*
% of LGD, so MATLAB knows what I mean by my indexing. 
% These zeros, when they matter, will be overwritten. 
for j = 1:n
    LGD{j} = zeros(length(Y{j}),1);
end

LGD{n} = (d - Y{n}).*(1-(Y{n}).^2);

for j = n-1:-1:2
    for i = 1:length(Y{j})
        % The key backpropagation step. It involves the derivative of
        % the tanh transfer, then the inner product of the relevant
        % weight terms and delta terms connecting to the j+1th layer
        LGD{j}(i) = (1-(Y{j}(i)).^2)*((LGD{j+1})'*(W{j}(:,i)));
    end
end

return

