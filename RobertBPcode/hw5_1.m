% Robert Brockman II - S00285133
% COMP 502 Spring 2013
% Homework 5
%
% hw5_1.m - script for problem 1: iris
%

clear classes;
set(gcf,'color','w');

% Load test and training data.
load('iris-train.mat');
load('iris-test.mat');

trainInput = irisTrain(:,1:4);
trainOutput = irisTrain(:,5:7);

testInput = irisTest(:,1:4);
testOutput = irisTest(:,5:7);


% Create perceptron object and initialize with widths of input buffer,
% hidden layers, and output layer.
mp = multiPerp([4;2;3]);


% Set training parameters.
mp.maxEpochs = 50000; % maximum number of input samples (not epochs)
mp.initialLearningRate = 0.07; 
mp.momentum = 0.8;
mp.reportingInterval = 1000; % m = 1000 epochs
mp.epochSize = 1; % Set equal to the number of training samples.

% Save initialized versions of weights.
save('mpinit_5_1.mat','mp');

% Load old weights to make comparisons easier.
%load('mpinit_5_1.mat');


% Map outputs to (-0.9,0.9)
%trainScaledOutput = (trainOutput - 5.5)/(4.5/0.9);
%testScaledOutput = (testOutput - 5.5)/(4.5/0.9);

trainScaledOutput = trainOutput;
testScaledOutput = testOutput;


mp.trainOutput = trainScaledOutput;
mp.trainInput = trainInput;
mp.testOutput = testScaledOutput;
mp.testInput = testInput;

% Train the multilayer perceptron.
mp.train();

mp.report.plotSampleError('hw5_1e.eps','Iris Neural Network');
mp.report.plotClassificationError('hw5_1f.eps','Iris Neural Network');




