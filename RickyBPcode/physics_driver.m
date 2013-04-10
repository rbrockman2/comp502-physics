% This will be the driver for the multilayer perceptron training through 
% BP to recognize patterns in the derived 8 physics variables. 

datapath = '../inputdata/';

% The initial training data. We include amounts of both signal and noise
signal_train = load([datapath 'signal_train.mat']);
noise_train = load([datapath 'noise_train.mat']);
% The cross-validation data. We do not even want to touch the test data for
% quite a while
signal_cv = load([datapath 'signal_cv.mat']);
noise_cv = load([datapath 'noise_cv.mat']);

% Now I just need to take the data and put it into matrix form, instead of
% having it in the cell form as before. 
signal_train = cell2mat(struct2cell(signal_train));
noise_train = cell2mat(struct2cell(noise_train));
signal_cv = cell2mat(struct2cell(signal_cv));
noise_cv = cell2mat(struct2cell(noise_cv));


% Now we need to assemble this data into a form that can be fed into our
% BP network. 

Xraw = cat(1,signal_train,noise_train);
Xraw = Xraw';

% Normalization of the derived variables to be between 0 and 1. 
[p,q] = size(Xraw);
X = zeros(p,q);

for i = 1:8
    X(i,:) = Xraw(i,:)/max(Xraw(i,:));
end

% Now we need to construct the desired outputs, into an array named D. I
% use 0.8 because the tanh transfer only runs up to 1. It's good practice
% to have the system seek a slightly lower value. 
signal_tag = [0.8;0]; noise_tag = [0; 0.8];

% I need to consider how many of the entries in X are signal. 

[signum,~] = size(signal_train);

D = zeros(2,q);
for i = 1:signum
    D(:,i) = signal_tag;
end

for i = signum+1:q
    D(:,i) = noise_tag;
end

% Now for the initial weight structure... 8, 20, and 2 are the number of
% neurons on layers 0, 1, and 2.
W0 = w_init([8 30 2]);

% Finally, I have scalar params, of gamma, alpha, maxiter, epoch, and
% track. These are the learning rate, momentum, obvious, look in your
% course notes, and how often we record the history. 

scalar_params = [0.00005 0.3 25000 2 20];

[W,W_history] = weight_dynamics(X,D,W0,scalar_params);


historian(X,D,W_history)
























