% Another idea:

% You shold simply scaled *all* the D values into a new matrix, D_scaled. 
% This way you don't have to fuss around with it in more sensitive 
% areas of the code. 

% Or I could even have D_scaled_down (i.e., to -1 to 1 interval) and,
% in the end, Y_scaled_up, meaning a correction of the output values
% which were trained in accordance with the downscaled D values. 

% Notice that training and error is only *really* recognized at the 
% output layer. Only here do we realize something is wrong and 
% accordingly do something about it. Everything else is in response
% to the supreme ERROR, which entirely depends on the norm squared of the
% actual and desired outputs. 

% Perhaps we could be more clever with our error in the future, more
% subtle. 


% And now for testing theory... How exactly can we set up our testing
% functions in the greatest generality? We should definitely have 
% little testing subfunctions in such a way that the general main code
% only requires a simple one line step and bundles everything together
% in one simple output. 

% Finally, there will be an optional "driver" that can call the whole
% shebang, where the inner main function will return all data sufficient
% to make any plotting system we desire. 



% I could have a historian who records things on each loop, a history
% administrator who bundles these things together throughout the loop,
% and then a history consolidator who bundles it all together in one
% cell for the purpose of output. 