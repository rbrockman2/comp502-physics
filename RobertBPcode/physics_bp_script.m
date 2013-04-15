% Robert Brockman II, Justin DeVito, and Ricky LeVan
% COMP 502 Spring 2013
% Final Project
%
% physics_bp_script.m: Use backpropagation ANN to separate signal from 
% noise in stop squark signal / top quark background data.

clear classes;
set(gcf,'color','w');

% Path to SOM data
somDataPath = '../RobertSOMcode/';

% Path to data processed by Onkur's script
onkurDataPath = '../inputdata/';


% Load physics training, cross-validation, and test data.
load('../inputdata/noise_train.mat');
load('../inputdata/noise_cv.mat');
load('../inputdata/noise_test.mat');
load('../inputdata/signal_train.mat');
load('../inputdata/signal_cv.mat');
load('../inputdata/signal_test.mat');


% Load SOM training data.
load([somDataPath 'cleanSignalTrain.mat']);
load([somDataPath 'cleanNoiseTrain.mat']);
signalTrainInput = cleanSignalTrain;
noiseTrainInput = cleanNoiseTrain;

% Load Onkur training data.
%load([onkurDataPath 'signal_train.mat']);
%load([onkurDataPath 'noise_train.mat']);
%signalTrainInput = signal_train;
%noiseTrainInput = noise_train;



trainInput = [noiseTrainInput;signalTrainInput];

% Create output labels for training data.
signalTrainOutput = zeros(size(signalTrainInput,1),2);
signalTrainOutput(:,1) = 1;
noiseTrainOutput = zeros(size(noiseTrainInput,1),2);
noiseTrainOutput(:,2) = 1;

trainOutput = [noiseTrainOutput;signalTrainOutput];


%testInput = irisTest(:,1:4);
%testOutput = irisTest(:,5:7);


% Map outputs to (-0.9,0.9)
%trainScaledOutput = (trainOutput - 5.5)/(4.5/0.9);
%testScaledOutput = (testOutput - 5.5)/(4.5/0.9);

bpScaler = rescaler(-0.9,0.9,trainInput);

trainScaledInput = bpScaler.scaleForward(trainInput);
trainScaledOutput = trainOutput;% scaler(0,0.9,trainOutput);

%testScaledOutput = testOutput;



% Load or generate a SOM trained to separate signal from background.
try 
    % Attempt to load pre-trained SOM object
    load('mp.mat');
catch err
    % Create perceptron object and initialize with widths of input buffer,
    % hidden layers, and output layer.
    mp = multiPerp([8;30;2]);
    
    
    % Set training parameters.
    mp.maxEpochs = 500000; % maximum number of input samples (not epochs)
    mp.initialLearningRate = 0.001;
    mp.momentum = 0.2;
    mp.reportingInterval = 1000; % m = 1000 epochs
    mp.epochSize = 1; % Set equal to the number of training samples.
    
    mp.trainOutput = trainScaledOutput;
    mp.trainInput = trainScaledInput;
    %  mp.testOutput = testScaledOutput;
    %  mp.testInput = testInput;
    
    % Train the multilayer perceptron.
    mp.train();
    
    % Save SOM object for reuse later.
    save('mp.mat','mp');
end

mp.report.plotSampleError('bp_training.eps','Data filtered by SOM');
mp.report.plotClassificationError('bp_classification.eps','Data filtered by SOM');

% FIXME:  WRONG
cvNoiseNum = size(noise_train,1);
cvSignalNum = size(signal_train,1);

trainSignalScaledInput = bpScaler.scaleForward(signalTrainInput);

trainNoiseScaledInput = bpScaler.scaleForward(noiseTrainInput);

for k=1:100
    bias = 0.01 * k;
    
    truePositive =0;
    
    for i=1:size(trainSignalScaledInput,1)
        bpOutput = mp.mpOutput(trainSignalScaledInput(i,:)');
        if bpOutput(1) > bpOutput(2) + bias
            truePositive = truePositive +1;
        end
    end
    
    falsePositive =0;
    for i=1:size(trainNoiseScaledInput,1)
        bpOutput = mp.mpOutput(trainNoiseScaledInput(i,:)');
        if bpOutput(1) > bpOutput(2) + bias
            falsePositive = falsePositive +1;
        end
    end
    disp(truePositive);
    disp(falsePositive);
    significance(k) = computeSignificance(cvSignalNum,cvNoiseNum,truePositive,falsePositive);
    
end
