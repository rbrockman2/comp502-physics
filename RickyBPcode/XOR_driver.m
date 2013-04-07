function XOR_driver

% round 1 checking:

% gamma, alpha, maxiter, epoch, track
scalar_params = [.01 .05 4000 1 5];
PE_per_layer = [2; 2; 1];
W0 = w_init(PE_per_layer);

X = [-1 -1 1 1; -1 1 -1 1];
D = [-1 1 1 -1];
X_test = X;
D_test = D;

[~,W_history] = weight_dynamics(X,D,W0,scalar_params);

history = historian(X_test,D_test,W_history);

plot(1:length(history),history)

return





