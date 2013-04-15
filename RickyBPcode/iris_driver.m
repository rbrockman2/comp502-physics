% This function sets parameters for the running of weight_dynamics on
% the iris data to construct a memory cell that holds the information
% contained in the patterns in the data. 
function iris_driver


% GENERAL INITIALIZATION
PE_per_layer = [4;3;3];
W0 = w_init(PE_per_layer);

[training_data,test_data] = iris_data;

X = training_data(:,1:4)';
D = training_data(:,5:7)';

X_test = test_data(:,1:4)';
D_test = test_data(:,5:7)';

D(D==0) = -1;
D_test(D_test==0) = -1;


% ROUND 1 
scalar_params = [.02 0.5 5000 1 5];
[~,W_history] = weight_dynamics(X,D,W0,scalar_params);
history = historian(X_test,D_test,W_history);

figure
% plotting of the error data
plot(1:length(history{1}),history{1})
title('MSE history across all sample training inputs -- first parameter set','interpreter','latex','fontsize',14)
xlabel('iteration x*track','interpreter','latex','fontsize',14)
ylabel('Mean Squared Error','interpreter','latex','fontsize',14)

figure
% plotting of the single test input trajectory:
colors = ['g','r','b'];
for j = 1:3
    plot(1:length(history{2}),history{2}(:,j),colors(j))
    hold on
end
legend('Setosa','Versacolor','Virginica','interpreter','latex')
title('Convergence of a single input signal -- first parameter set','interpreter','latex','fontsize',14)
xlabel('iteration x*track','interpreter','latex','fontsize',14)
ylabel('Returned values from network','interpreter','latex','fontsize',14)

% ROUND 2
% And now we confirm that without momentum, all is well:
scalar_params = [.02 0 5000 1 5];
[~,W_history] = weight_dynamics(X,D,W0,scalar_params);
history = historian(X_test,D_test,W_history);

figure
% plotting of the error data
plot(1:length(history{1}),history{1})
title('MSE history across all sample training inputs -- second parameter set','interpreter','latex','fontsize',14)
xlabel('iteration x*track','interpreter','latex','fontsize',14)
ylabel('Mean Squared Error','interpreter','latex','fontsize',14)

figure
% plotting of the single test input trajectory:
colors = ['g','r','b'];
for j = 1:3
    plot(1:length(history{2}),history{2}(:,j),colors(j))
    hold on
end
legend('Setosa','Versacolor','Virginica','interpreter','latex')
title('Convergence of a single input signal -- second parameter set','interpreter','latex','fontsize',14)
xlabel('iteration x*track','interpreter','latex','fontsize',14)
ylabel('Returned values from network','interpreter','latex','fontsize',14)



return