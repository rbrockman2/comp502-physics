% Robert Brockman II - S00285133
% COMP 502 Spring 2013
% Homework 5
%
% hw5_2.m - script for problem 2: adaptive filter
%

clear classes;
set(gcf,'color','w');

n = [1:1:300]';
trainOutput = 2*sin(2*pi*n/20);
trainInput = trainOutput+trainOutput.*trainOutput*0.2;

testOutput = 0.8*sin(2*pi*n/10) + 0.25*cos(2*pi*n/25);
testInput = testOutput+testOutput.*testOutput*0.2;

testOutput2 = randn(300,1);
testInput2 = testOutput2+testOutput.*testOutput*0.2;

% 1 inputs, 80 hidden units, 1 output unit
mp = multiPerp([1;80;1]);


% Set training parameters.
mp.maxEpochs = 80000; % maximum number of input samples (not epochs)
mp.initialLearningRate = 0.01; 
mp.momentum = 0.9;
mp.reportingInterval = 100; % m = 100 epochs
mp.epochSize = 1; % Set equal to the number of training samples.
mp.errorThreshold = 0.0015;


%mp.debug=1;
% Save initialized versions of weights.
save('mpinit_5_2.mat','mp');

% Load old weights to make comparisons easier.
%load('mpinit_5_2.mat');


% Rescale inputs and outputs to avoid clipping problems.
trainScaledOutput = trainOutput/3;
trainScaledInput = trainInput/3;

testScaledOutput = testOutput/3;
testScaledInput = testInput/3;

testScaledOutput2 = testOutput2/3;
testScaledInput2 = testInput2/3;


mp.trainOutput = trainScaledOutput;
mp.trainInput = trainScaledInput;
mp.testOutput = testScaledOutput;
mp.testInput = testScaledInput;

% Train the multilayer perceptron.
mp.train();

mp.report.plotSampleError('hw5_2a.eps','s(n)=2sin(2\pi n/20) Network');

% Not a classification problem
%mp.report.plotClassificationError('hw5_2.eps');

figure(2);
for i=1:size(n,1)
    actualOutput(i) = mp.mpOutput(trainScaledInput(i));
end
plot(n(1:50),actualOutput(1:50),'-ok',n(1:50),trainScaledOutput(1:50),'-or');
xlabel('Sample Number n');
%axis([obj.reportingInterval,obj.recordNumber*obj.reportingInterval,0,1]);
ylabel('s(n)');
legend('Actual Output','Ideal Output','Location','SouthWest');
title('Comparison of Ideal and Actual Output of Equalizer ANN for Training Signal');
set(gcf,'color','w');
export_fig('hw5_2b.eps',2);


figure(3);
for i=1:size(n,1)
    actualOutput(i) = mp.mpOutput(testScaledInput(i));
end
plot(n(1:50),actualOutput(1:50),'-ok',n(1:50),testScaledOutput(1:50),'-or');
xlabel('Sample Number n');
%axis([obj.reportingInterval,obj.recordNumber*obj.reportingInterval,0,1]);
ylabel('s(n)');
legend('Actual Output','Ideal Output','Location','SouthWest');
title('Comparison of Ideal and Actual Output of Equalizer ANN for Sinusoidal Test Signal');
set(gcf,'color','w');
export_fig('hw5_2e.eps',3);


figure(4);
for i=1:size(n,1)
    actualOutput2(i) = mp.mpOutput(testScaledInput2(i));
end
plot(n(1:50),actualOutput2(1:50),'-ok',n(1:50),testScaledOutput2(1:50),'-or');
xlabel('Sample Number n');
%axis([obj.reportingInterval,obj.recordNumber*obj.reportingInterval,0,1]);
ylabel('s(n)');
legend('Actual Output','Ideal Output','Location','SouthWest');
title('Comparison of Ideal and Actual Output of Equalizer ANN for Random Test Signal');
set(gcf,'color','w');
export_fig('hw5_2f.eps',4);




