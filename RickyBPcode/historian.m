% historian. This function looks through the weight history to gather 
% relevant data we want for an understanding of the network convergence
% history. 

% history will be a changing entity that covers everything we think we
% would like to output. 

function history = historian(X_test,D_test,W_history)

% INITIALIZATION PHASE

% please bear the historical analogy
num_dates = length(W_history);
% recording the index of the output layer (counting from 1)
n = length(W_history{1}) + 1; 
% initializing Y_test and getting the number of test samples for a loop
[out_length,samples] = size(D_test);
Y_test = zeros(out_length,samples);


% GATHERING ALL HISTORIES
total_error_history = zeros(num_dates,1);
input_one_history = zeros(num_dates,3);

for i = 1:num_dates
    
    % making a total error history
    for j = 1:samples
        full_signal = signal_gen(X_test(:,j),W_history{i});
        Y_test(:,j) = full_signal{n};
    end
    total_error_history(i) = sum(sum((Y_test - D_test).^2))/(out_length*samples);
    
    intermed = signal_gen(X_test(:,1),W_history{i});
    input_one_history(i,:) = intermed{length(intermed)};
    
    
    
    
end
        
% SYNTHESIS:
history = cell(2,1);
history{1} = total_error_history;
history{2} = input_one_history;



    