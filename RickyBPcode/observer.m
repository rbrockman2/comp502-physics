% This guy is the OBSERVER. He merely observes what is going on. He will
% hand data to the historian. 

% I will begin simply, with a recording of error. 

function test_error = observer(X_test,D_test,W)

[out,samples] = size(D_test); % or equivalently, D_test

Y_test = zeros(out,samples);

% recording the index of the output layer (counting from 1)
n = length(W) + 1;

for j = 1:samples
     full_signal = signal_gen(X_test(:,j),W);
     Y_test(:,j) = full_signal{n};
end

% now for the E_test, squaring difference between what we desired and 
% what we got, in a matrix form:

E_test = (Y_test - D_test).^2;

% I am measuring error by the sum of the sum of the squared differences 
% across each input vector across all input vectors.
test_error = sum(sum(E_test));

return


