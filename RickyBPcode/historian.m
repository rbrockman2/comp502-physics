% This code is the historian. It will look at W_history to make conclusions
% about how the data has changed over time. A first plot to make is simply
% the decay of the error in time, to see if we get any network convergence.
% From there we can move to more sophisticated metrics. 

function historian(Xcv,Dcv,W_history)

class_error_vec = zeros(length(W_history),1);

for i = 1:length(W_history)
    class_error_vec(i) = observer_class_error(Xcv,Dcv,W_history{i});
end

plot(1:length(class_error_vec), class_error_vec)

return


    