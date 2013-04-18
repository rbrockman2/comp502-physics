% Robert Brockman II, Justin DeVito, and Ricky LeVan
% COMP 502 Spring 2013
% Final Project
%
% physics_bp_script.m: Use backpropagation ANN to separate signal from 
% noise in stop squark signal / top quark background data.

clear classes;
set(gcf,'color','w');

% Option 1 uses 24 dimensional raw data, option 2 uses 8 dimensional raw data,
% Option 3 uses SOM 8-D filtered data.
option = 3;

% True means generate final output using test data.
finalOutput = false;

if option == 1
    % Load physics training, cross-validation, and test data.
    load('../inputdata/DS24/noise_train_24.mat');
    load('../inputdata/DS24/noise_cv_24.mat');
    load('../inputdata/DS24/noise_test_24.mat');
    load('../inputdata/DS24/signal_train_24.mat');
    load('../inputdata/DS24/signal_cv_24.mat');
    load('../inputdata/DS24/signal_test_24.mat');
    bias = 0;
    signalTrainInput = signal_train_24;
    noiseTrainInput = noise_train_24;
    signalCVInput = signal_cv_24;
    noiseCVInput = noise_cv_24;
    signalTestInput = signal_test_24;
    noiseTestInput = noise_test_24;
end

if option == 2
    % Load physics training, cross-validation, and test data.
    load('../inputdata/DS8/noise_train_8.mat');
    load('../inputdata/DS8/noise_cv_8.mat');
    load('../inputdata/DS8/noise_test_8.mat');
    load('../inputdata/DS8/signal_train_8.mat');
    load('../inputdata/DS8/signal_cv_8.mat');
    load('../inputdata/DS8/signal_test_8.mat');
    bias = 0.57;
    signalTrainInput = signal_train_8;
    noiseTrainInput = noise_train_8;
    signalCVInput = signal_cv_8;
    noiseCVInput = noise_cv_8;
    signalTestInput = signal_test_8;
    noiseTestInput = noise_test_8;
end

if option == 3
    % Load physics training, cross-validation, and test data.
    load('../outputdata/filteredNoiseTrain_8_degreeScaled.mat');
    load('../outputdata/filteredNoiseCV_8_degreeScaled.mat');
    load('../outputdata/filteredNoiseTest_8_degreeScaled.mat');
    load('../outputdata/filteredSignalTrain_8_degreeScaled.mat');
    load('../outputdata/filteredSignalCV_8_degreeScaled.mat');
    load('../outputdata/filteredSignalTest_8_degreeScaled.mat');
    bias = 1.1;
    signalTrainInput = filteredSignalTrain;
    noiseTrainInput = filteredNoiseTrain;
    signalCVInput = filteredSignalCV;
    noiseCVInput = filteredNoiseCV;
    signalTestInput = filteredSignalTest;
    noiseTestInput = filteredNoiseTest;
end

trainInput = [noiseTrainInput;signalTrainInput];
CVInput = [noiseCVInput;signalCVInput];
testInput = [noiseTestInput;signalTestInput];

% Rescale BP input parameters to (-0.9, +0.9).

% DON'T ADD ANYTHING HERE!!!!!!!!!!!
bpScaler = rescaler(-0.9,0.9,trainInput);

% Why not assemble trainInput, CVInput, and testInput later? Because we
% needed to calibrate the scaler on the training input data for both signal
% and noise.
trainInput = bpScaler.scaleForward(trainInput);
CVInput = bpScaler.scaleForward(CVInput);
testInput = bpScaler.scaleForward(testInput);
signalTrainInput = bpScaler.scaleForward(signalTrainInput);
noiseTrainInput = bpScaler.scaleForward(noiseTrainInput);
signalCVInput = bpScaler.scaleForward(signalCVInput);
noiseCVInput = bpScaler.scaleForward(noiseCVInput);
signalTestInput = bpScaler.scaleForward(signalTestInput);
noiseTestInput = bpScaler.scaleForward(noiseTestInput);

% Create output labels for data.
signalTrainOutput = zeros(size(signalTrainInput,1),2);
signalTrainOutput(:,1) = 1;
signalTrainOutput(:,2) = 0;
noiseTrainOutput = zeros(size(noiseTrainInput,1),2);
noiseTrainOutput(:,1) = 0;
noiseTrainOutput(:,2) = 1;
signalCVOutput = zeros(size(signalCVInput,1),2);
signalCVOutput(:,1) = 1;
signalCVOutput(:,2) = 0;
noiseCVOutput = zeros(size(noiseCVInput,1),2);
noiseCVOutput(:,1) = 0;
noiseCVOutput(:,2) = 1;
signalTestOutput = zeros(size(signalTestInput,1),2);
signalTestOutput(:,1) = 1;
signalTestOutput(:,2) = 0;
noiseTestOutput = zeros(size(noiseTestInput,1),2);
noiseTestOutput(:,1) = 0;
noiseTestOutput(:,2) = 1;

trainOutput = [noiseTrainOutput;signalTrainOutput];
CVOutput = [noiseCVOutput;signalCVOutput];
testOutput = [noiseTestOutput;signalTestOutput];

% DON'T ADD ANYTHING HERE!!!!!!!!!!!

% Map outputs to (-0.9,0.9)
bpOutScaler = rescaler(-0.9,0.9,trainOutput);

trainOutput = bpOutScaler.scaleForward(trainOutput);
CVOutput = bpOutScaler.scaleForward(CVOutput);
testOutput = bpOutScaler.scaleForward(testOutput);

% Load or generate a BP network trained to separate signal from background.
try 
    % Attempt to load pre-trained BP object
    load('mp.mat');
catch err
    % Create perceptron object and initialize with widths of input buffer,
    % hidden layers, and output layer.
    mp = multiPerp([8;30;2]);
    
    
    % Set training parameters.
    mp.maxEpochs = 100000; % maximum number of input samples (not epochs)
    mp.initialLearningRate = 0.01;
    mp.momentum = 0.3;
    mp.reportingInterval = 1000; % m = 1000 epochs
    mp.epochSize = 1; % Set equal to the number of training samples.
    
    mp.trainOutput = trainOutput;
    mp.trainInput = trainInput;
    mp.testOutput = CVOutput;
    mp.testInput = CVInput;
    
    mp.classifierTargets = [-0.9 +0.9; +0.9 -0.9];
    
    mp.signalTrainInput = signalTrainInput;
    mp.noiseTrainInput = noiseTrainInput;
    mp.signalCVInput = signalCVInput;
    mp.noiseCVInput = noiseCVInput;
    
    mp.bias = bias;
  
    % Train the multilayer perceptron.
    mp.train();
    
    % Save SOM object for reuse later.
    save('mp.mat','mp');
end

mp.report.plotSampleError('bp_training.eps','Data filtered by SOM');
mp.report.plotClassificationError('bp_classification.eps','Data filtered by SOM');

optimalBias = 0;
maxSignificance = 0;
for k=1:200
    bias = 0.01 * (k-1);
    
    [truePositive,~] = signal_counter(mp,signalCVInput,bias);
    [falsePositive,~] = signal_counter(mp,noiseCVInput,bias);

    [significance(k) sigCount noiseCount ] = computeSignificance(truePositive,falsePositive);
    
    if significance(k) > maxSignificance && significance(k) ~= Inf
        optimalBias = bias;
        maxSignificance = significance(k);
        bestSigCount = sigCount;
        bestNoiseCount = noiseCount;
    end
end
figure(3)
plot((0:199)./100,significance);
xlabel('Bias');
ylabel('Significance');

disp(['Maximum significance: ' num2str(maxSignificance)]);
disp(['Optimal bias: ' num2str(optimalBias)]);
disp(['Corresponding signal count: ' num2str(bestSigCount)]);
disp(['Corresponding noise count: ' num2str(bestNoiseCount)]);

[truePositive,bpSignalOutput] = signal_counter(mp,signalCVInput,optimalBias);
[falsePositive,bpNoiseOutput] = signal_counter(mp,noiseCVInput,optimalBias);

figure(4);
plot(bpSignalOutput(:,1),bpSignalOutput(:,2),'xk',...
    bpNoiseOutput(:,1),bpNoiseOutput(:,2),'xr');
axis([0 1 0 1]);

if finalOutput == 1
    [truePositive,~] = signal_counter(mp,signalTestInput,optimalBias);
    [falsePositive,~] = signal_counter(mp,noiseTestInput,optimalBias);

    [bestSignificance sigCount noiseCount ] = computeSignificance(truePositive,falsePositive);

    disp(['Best significance on Test Set: ' num2str(bestSignificance)]);
    disp(['Corresponding signal count: ' num2str(sigCount)]);
    disp(['Corresponding noise count: ' num2str(noiseCount)]);
end