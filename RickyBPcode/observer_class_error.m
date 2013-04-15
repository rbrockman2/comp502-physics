% This guy is the OBSERVER. He merely observes what is going on. He will
% hand data to the historian. 

% I will begin simply, with a recording of error. 

function class_error = observer_class_error(X_test,D_test,W)

[out,samples] = size(D_test); % or equivalently, D_test

Y_test = zeros(out,samples);

signal = [0.8;0];
noise = [0;0.8];

% recording the index of the output layer (counting from 1)
n = length(W) + 1;

% **** I'm adding in a fudge factor of only checking *some* samples to make
% this code run faster. This fudge factor is the ceil part in between the
% colons that direct how long the for loop runs. 

class_vec = zeros(101,1);

iter = 1;
% In here I refer to the hardcoded signal and noise vectors. All they
% really are are the corresponding signal/noise pieces of D_test. 
for j = 1:ceil(samples/100):samples
     full_signal = signal_gen(X_test(:,j),W);
     Y_test(:,j) = full_signal{n};
     a = Y_test(:,j) - signal;
     b = Y_test(:,j) - noise;
     c = [norm(a) norm(b)];
     [~,d] = min(c);
     if d == 1
         class_vec(iter) = 1;
     else
         class_vec(iter) = 0;
     end   
     iter = iter + 1;
end

% Okay, now we have a vector that has 1's and 0's in it. We need a new
% vector which contains 1's and 0's based on whether or not the
% identification was correct. This means that early 1's should stay 1's
% (because signal was correctly identified), and early 0's should stay 0's,
% (because noise was falsely identified). 

error_vec = class_vec;
for i = 1:101
    if i > 29
        if error_vec(i) == 1
            error_vec(i) = 0;
        elseif error_vec(i) == 0
            error_vec(i) = 1;
        end
    end
end

% error_vec still has 1 for correct and 0 for incorrect. 

class_error = 1 - sum(error_vec)/length(error_vec);

return


