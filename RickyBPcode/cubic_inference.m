% testing the ability to infer based on noise over a cubic function. 

function cubic_inference

close all

% generating random points on the real line to simulate different
% observations made, without the ability to pick which input we're going
% to observe

num_inputs = 200;

X = zeros(1,num_inputs);
for i = 1:num_inputs
    X(i) = rand*12 - 6;
end
X = sort(X);

% generating the cubic values with some additional extra randomness
D = zeros(1,num_inputs);
T = zeros(1,num_inputs);
for i = 1:num_inputs
    % dummy intermediate step
    a = X(i);
    T(i) = a*(a-2)*(a+2);
    D(i) = T(i) + randn*15;
end


% Now we've generated our noisy data. The next goal is to feed this into a 
% neural network. For that, we need to set some default learning
% parameters. 

scalar_params = [.005 0.5 20000 5 20];
W0 = w_init([1 20 1]);

% before we train, we need to compress and shift the desired outputs
% (remember, desired is in the sense of what has been empirically observed!
% All of this NN training is based on empirical data). I'll call these two
% pieces a dilate and a kick. 

b = 0.8;
a = -0.8;
d = max(D);
c = min(D);

dilate = (b-a)/(d-c);

kick = a - dilate*c;

scale_fun = @(x) dilate*x + kick;

Dsc = scale_fun(D);


[W,~] = weight_dynamics(X,Dsc,W0,scalar_params);

outsc = zeros(1,num_inputs);

for i = 1:num_inputs
    Y = signal_gen(X(i),W);
    outsc(i) = Y{3};
end

% Now I will do something similar for the test data. 
Q = linspace(-6,6,200);
outsc2 = zeros(1,length(Q));
for i = 1:length(Q)
    Z = signal_gen(Q(i),W);
    outsc2(i) = Z{3};
end
    
    
inv_scale_fun = @(x) (x - kick)/dilate;
out = inv_scale_fun(outsc);
out2 = inv_scale_fun(outsc2);




%plot(X,out,'b','LineWidth',3)

plot(X,D,'r*','markersize',10)
hold on
plot(Q,out2,'b','Linewidth',3)
hold on 
plot(X,T,'g','Linewidth',3)
hold on




return

% Whoa, Ricky, you could animate a network evolving in time. You could have
% different perspectives on the weight space evolution. All is number. So
% what is amazing is creating amazing visualizations. Well, that is
% amazing, as are so many different things. 

% But remember that neural networks are dynamic, statistical tools. They,
% at least in their current form with out current theories of mind, are
% very simple things indeed. 


    

