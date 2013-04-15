% weight_dynamics is specifically the system that traings the neural 
% network, doing nothing more than giving us the desired W cell 
% and its history at the track points

% X: a matrix of training inputs--each column is an input vector
% D: a matrix of desired training outputs--each column is an output vector
% X_test, D_test the same but for the test values
% W0: a cell containing matrices of the initial weight set-up
% PE_per_layer: a vector of the # of PE's on each layer

% scalar_params is a vector of the following scalar inputs:
% gamma: a scalar learning rate parameter
% alpha: a scalar momentum parameter
% maxiter: a scalar representing the maximum number of iterations
% epoch: a scalar representing epoch
% track: a scalar representing iterations between progress recording

% outputs:
% W: resulting cell of weight matrices after training
% W_history: a cell of cells containing weight matrices throughout the
% history of the computation, at each track point
% These two don't necessarily coincide, though we should expect 
% W_history{n} to be very close to W if the network is converging

%% FUNCTION BEGINS

function [W,W_history] = weight_dynamics(X,D,W0,scalar_params)

%% INITIALIZATION STAGE

gamma = scalar_params(1);
alpha = scalar_params(2);
maxiter = scalar_params(3);
epoch = scalar_params(4);
track = scalar_params(5);

% initializing weight matrix according to input:
W = W0;

% initializing del_W, and keeping the init form for resetting in main loop
del_W_init = cell(length(W0),1);
for i = 1:length(W0)
    del_W_init{i} = 0*W0{i};
end
del_W = del_W_init;

% initializing past_shift to also be a cell of all zero matrices. 
past_shift = del_W_init;

% initializing how many times we will track, plus relevant parameters for 
% our historian:
max_track = floor(maxiter/track);
W_history = cell(max_track,1);
track_count = 0;


%% GRAND LOOP STAGE

% iter is the supreme counter over the whole system
for iter = 1:maxiter
    
    %% this section selects values for x and d:
    
    [x,d] = selector(X,D);
    
    %% This loop section deals with the accumulation of del_W until...
    
    % getting the current shift desired 
    current_shift = prop_weight_shift(x,d,W,gamma);
    % del_W holds our proposed shifts to the weights. These will pour
    % into the existing weight structure under epoch conditions.
    
    
    % Making this extra loop because of the difficulty of updating cells:
    for j = 1:length(del_W)
        del_W{j} = current_shift{j} + alpha*past_shift{j} + del_W{j};
    end
    
    % after the updating, we now declare what was current_shift to be 
    % past_shift:
    past_shift = current_shift;
    
    %% the dam bursts, and we have the release of del_W into W proper.
    
    if mod(iter,epoch) == 0
        % again, because of the cell updating fussiness I must make another
        % loop:
        for j = 1:length(W)
            W{j} = W{j} + del_W{j};
        end
        
        del_W = del_W_init;
    end
    
    %% finally, we want to record information on this whole process
    
    if mod(iter,track) == 0
        % we now have officially tracked once, upon execution of the
        % following line!
        track_count = track_count + 1;
        W_history{track_count} = W;
        
    end
          
end


return


    
    
    
    
    


