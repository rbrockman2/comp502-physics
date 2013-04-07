function channel_driver

close all

% GENERAL INITIALIZATION
PE_per_layer = [1;80;1];

% Initializing W0 at random around 0.1
W0 = w_init(PE_per_layer);
for j = 1:length(W0)
    W0{j} = 0.1*W0{j};
end

sine_inputs = 0:1:20;

% desired values at each discrete n value between 0 and 20
D = 2*sin(2*pi*sine_inputs/20);

% now we get the X values by distorting what was originally the
% correct signal:
X = 1*D + 0.2*D.^2;

% Now we need to scale our desired outputs down:

% **** PROBLEM 1 ****
% I proceed by running 3 rounds to acquire different data each time

% **ROUND 1**
D_scaled = D/2*0.8;

scalar_params = [0.01 0 1000 5 5];

% for simplicity we'll test on inputs:
D_test_scaled = D_scaled;
X_test = X;

[W,W_history] = weight_dynamics(X,D_scaled,W0,scalar_params);
history = historian(X_test,D_test_scaled,W_history);

figure
% plotting of the error data
plot(1:length(history{1}),history{1})
title('MSE history across all sample training inputs -- first parameter set','interpreter','latex','fontsize',14)
xlabel('iteration x*track','interpreter','latex','fontsize',14)
ylabel('Mean Squared Error','interpreter','latex','fontsize',14)

% Now we also want to plot the noisy, desired, and recovered. We'll
% call these X,D, and R. 

figure
R = 0*X;
for i = 1:length(X)
    intermed = signal_gen(X(i),W);
    % the *2 factor is to undo the scaling of 1/2 in D_scaled
    R(i) = intermed{length(intermed)}*(2/0.8);
end

plot(sine_inputs,X,sine_inputs,D,sine_inputs,R)
legend('Noisy signal','Desired signal','Recovered signal','interpreter','latex')
title('Comparison of signals -- first parameter set','interpreter','latex','fontsize',14)
xlabel('Time input','interpreter','latex','fontsize',14)
ylabel('Signal amplitude','interpreter','latex','fontsize',14)


% **ROUND 2**
D_scaled = D/2*0.8;

scalar_params = [0.05 0 1000 5 5];

% for simplicity we'll test on inputs:
D_test_scaled = D_scaled;
X_test = X;

[W,W_history] = weight_dynamics(X,D_scaled,W0,scalar_params);
history = historian(X_test,D_test_scaled,W_history);

figure
% plotting of the error data
plot(1:length(history{1}),history{1})
title('MSE history across all sample training inputs -- second parameter set','interpreter','latex','fontsize',14)
xlabel('iteration x*track','interpreter','latex','fontsize',14)
ylabel('Mean Squared Error','interpreter','latex','fontsize',14)

% Now we also want to plot the noisy, desired, and recovered. We'll
% call these X,D, and R. 

figure
R = 0*X;
for i = 1:length(X)
    intermed = signal_gen(X(i),W);
    % the *2 factor is to undo the scaling of 1/2 in D_scaled
    R(i) = intermed{length(intermed)}*(2/0.8);
end

plot(sine_inputs,X,sine_inputs,D,sine_inputs,R)
legend('Noisy signal','Desired signal','Recovered signal','interpreter','latex')
title('Comparison of signals -- second parameter set','interpreter','latex','fontsize',14)
xlabel('Time input','interpreter','latex','fontsize',14)
ylabel('Signal amplitude','interpreter','latex','fontsize',14)



% **ROUND 3**
D_scaled = D/2*0.8;

scalar_params = [0.01 0 1000 20 20];

% for simplicity we'll test on inputs:
D_test_scaled = D_scaled;
X_test = X;

[W,W_history] = weight_dynamics(X,D_scaled,W0,scalar_params);
history = historian(X_test,D_test_scaled,W_history);

figure
% plotting of the error data
plot(1:length(history{1}),history{1})
title('MSE history across all sample training inputs -- third parameter set','interpreter','latex','fontsize',14)
xlabel('iteration x*track','interpreter','latex','fontsize',14)
ylabel('Mean Squared Error','interpreter','latex','fontsize',14)

% Now we also want to plot the noisy, desired, and recovered. We'll
% call these X,D, and R. 

figure
R = 0*X;
for i = 1:length(X)
    intermed = signal_gen(X(i),W);
    % the *2 factor is to undo the scaling of 1/2 in D_scaled
    R(i) = intermed{length(intermed)}*(2/0.8);
end

plot(sine_inputs,X,sine_inputs,D,sine_inputs,R)
legend('Noisy signal','Desired signal','Recovered signal','interpreter','latex')
title('Comparison of signals -- third parameter set','interpreter','latex','fontsize',14)
xlabel('Time input','interpreter','latex','fontsize',14)
ylabel('Signal amplitude','interpreter','latex','fontsize',14)



% ****PROBLEM 2****
% Here we have a different approach that we will need to use for scaling
% and also we will need to use legitimate test inputs that are actually
% different.

% First we deal with the superposition of sinusoids:

figure
% What follows is the retraining of the network:
sine_inputs = 0:1:20;

% desired values at each discrete n value between 0 and 20
D = 2*sin(2*pi*sine_inputs/20);

% now we get the X values by distorting what was originally the
% correct signal:
X = 1*D + 0.2*D.^2;

% scaling desired inputs down:
D_scaled = D/2*0.8;

% note that we are training against the scaled D value
[W,~] = weight_dynamics(X,D_scaled,W0,scalar_params);


D_test = 0.8*sin(2*pi*sine_inputs/10) + 0.25*cos(2*pi*sine_inputs/25);
X_test = 1*D_test + 0.2*D_test.^2;

R_test = 0*X_test;
for i = 1:length(X)
    intermed = signal_gen(X_test(i),W);
    % the *2 factor is to undo the scaling of 1/2 in D_scaled
    R_test(i) = intermed{length(intermed)}*(2/0.8);
end

plot(sine_inputs,X_test,sine_inputs,D_test,sine_inputs,R_test)
legend('Noisy test signal','Desired test signal','Recovered test signal','interpreter','latex')
title('Comparison of signals -- sinusoidal superposition','interpreter','latex','fontsize',14)
xlabel('Time input','interpreter','latex','fontsize',14)
ylabel('Signal amplitude','interpreter','latex','fontsize',14)



% ****PROBLEM 3****
% Now for the same idea, except now we will use another fresh D_test.
% Also, like in problem 2, the same already generated weight matrix is used

figure

D_test = randn(length(D_test),1);
X_test = 1*D_test + 0.2*D_test.^2;

R_test = 0*X_test;
for i = 1:length(X)
    intermed = signal_gen(X_test(i),W);
    % the *2 factor is to undo the scaling of 1/2 in D_scaled
    R_test(i) = intermed{length(intermed)}*(2/0.8);
end

plot(sine_inputs,X_test,sine_inputs,D_test,sine_inputs,R_test)
legend('Noisy test signal','Desired test signal','Recovered test signal','interpreter','latex')
title('Comparison of signals -- random normal inputs','interpreter','latex','fontsize',14)
xlabel('Time input','interpreter','latex','fontsize',14)
ylabel('Signal amplitude','interpreter','latex','fontsize',14)





return
