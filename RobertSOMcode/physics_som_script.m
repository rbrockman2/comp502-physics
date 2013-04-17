% Robert Brockman II, Justin DeVito, and Ricky LeVan
% COMP 502 Spring 2013
% Final Project
%
% physics_som_script.m: Use self-organizing map code to find clusters in
% stop squark signal / top quark background data.

clear classes;
set(gcf,'color','w');

% Set SOM dimensions.
somDim1 = 10;
somDim2 = 10;

trainingInfoPath = '../traininginfo/';
inputDataPath = '../inputdata/';
outputDataPath = '../outputdata/';

% Scaling = 0 has no scaling.  Scaling = 1 scales up angles to degrees.
% Scaling = 2 centers parameter mean on zero with stddev 1.
scaling = 1;

% Option 1 uses 24 dimensional raw data, option 2 uses 8 dimensional raw data,
% Option 3 uses backpropagation data.
option = 2;

% True means generate final output using test data.
finalOutput = false;

if option == 1
    % Load physics training, cross-validation, and test data.
    load([inputDataPath 'DS24/noise_train_24.mat']);
    load([inputDataPath 'DS24/noise_cv_24.mat']);
    load([inputDataPath 'DS24/noise_test_24.mat']);
    load([inputDataPath 'DS24/signal_train_24.mat']);
    load([inputDataPath 'DS24/signal_cv_24.mat']);
    load([inputDataPath 'DS24/signal_test_24.mat']);
    signalTrain = signal_train_24;
    noiseTrain = noise_train_24;
    signalCV = signal_cv_24;
    noiseCV = noise_cv_24;
    signalTest = signal_test_24;
    noiseTest = noise_test_24;
end

if option == 2
    % Load physics training, cross-validation, and test data.
    load([inputDataPath 'DS8/noise_train_8.mat']);
    load([inputDataPath 'DS8/noise_cv_8.mat']);
    load([inputDataPath 'DS8/noise_test_8.mat']);
    load([inputDataPath 'DS8/signal_train_8.mat']);
    load([inputDataPath 'DS8/signal_cv_8.mat']);
    load([inputDataPath 'DS8/signal_test_8.mat']);
    signalTrain = signal_train_8;
    noiseTrain = noise_train_8;
    signalCV = signal_cv_8;
    noiseCV = noise_cv_8;
    signalTest = signal_test_8;
    noiseTest = noise_test_8;
end

% DONT INSERT ANYTHING HERE!

% Rescaling
if scaling == 1    
    % Rescale angles from 0-pi to 0-360.
    signalTrain(:,5:7)  = signalTrain(:,5:7) * 360 / pi;
    noiseTrain(:,5:7)  = noiseTrain(:,5:7) * 360 / pi;
    signalCV(:,5:7)  = signalCV(:,5:7) * 360 / pi;
    signalTrain(:,5:7)  = signalTrain(:,5:7) * 360 / pi;
    noiseCV(:,5:7)  = noiseCV(:,5:7) * 360 / pi;
    signalTest(:,5:7)  = signalTest(:,5:7) * 360 / pi;
    noiseTest(:,5:7)  = noiseTest(:,5:7) * 360 / pi;
end

if scaling == 2
    % Rescale everything to mean zero, stddev 1.
    somStdScaler = stdScaler(signalTrain);
    signalTrain = somStdScaler.scaleForward(signalTrain);
    noiseTrain = somStdScaler.scaleForward(noiseTrain);
    signalCV = somStdScaler.scaleForward(signalCV);
    noiseCV = somStdScaler.scaleForward(noiseCV);
    signalTest = somStdScaler.scaleForward(signalTest);
    noiseTest = somStdScaler.scaleForward(noiseTest);
end

trainInput = [noiseTrain;signalTrain];

% Load or generate a SOM trained to separate signal from background.
try 
    % Attempt to load pre-trained SOM object
    load('kohonenSom.mat');
catch err
    % Create and train new SOM
    kohonenSom = som(somDim1,somDim2,size(signalTrain,2));
    
    kohonenSom.trainInputs = trainInput';
    kohonenSom.maxIter = 2000001;
    % Set iterations used for exporting graphs.
    kohonenSom.iterList = [0 1000 10000 100000 250000 500000 1000000 1500000 2000000];
    
    kohonenSom.trainingInfoPath = trainingInfoPath;
    
    % Train SOM and export graphs for specified iterations.
    kohonenSom.train();
    
    % Save SOM object for reuse later.
    save('kohonenSom.mat','kohonenSom');
end

% Compute number of signal and noise events for each SOM cell.
signalInputsPerPEMatrix = kohonenSom.computeInputsPerPEMatrix(signalTrain');
noiseInputsPerPEMatrix = kohonenSom.computeInputsPerPEMatrix(noiseTrain');

% Plot distribution of signal and noise events along with normalized
% exemplars for each SOM cell.
exemplarSquaresPlot(signalInputsPerPEMatrix,noiseInputsPerPEMatrix,zeros(kohonenSom.height,kohonenSom.width),kohonenSom,2);

     
grayscaleSquaresPlot(signalInputsPerPEMatrix,3);
grayscaleSquaresPlot(noiseInputsPerPEMatrix,4);


% Compute SNR gain for each SOM cell.
trainSNR = size(signalTrain,1)/size(noiseTrain,1);
gainMatrix = zeros(kohonenSom.height,kohonenSom.width);
for i=1:kohonenSom.height
    for j=1:kohonenSom.width
        cellSNR = signalInputsPerPEMatrix(i,j)/noiseInputsPerPEMatrix(i,j);
        
        gainMatrix(i,j) = cellSNR/trainSNR;
    end
end
       
% Plot SNR gain for each SOM cell.
grayscaleSquaresPlot(gainMatrix,5);

% Determine minimum gain associated with maximum significance on
% cross-validation set.
maxSignificance = 0;
optimalGain = 0;
for k=1:25
    minimumGain = k-1;
    
    mySomFilter = somFilter(gainMatrix,kohonenSom,minimumGain);
    
    filteredSignalCV = mySomFilter.filterEvents(signalCV);
    filteredNoiseCV = mySomFilter.filterEvents(noiseCV);
     
    significance(k) = computeSignificance(size(filteredSignalCV,1),size(filteredNoiseCV,1));
    if significance(k) > maxSignificance
        maxSignificance = significance(k);
        optimalGain = minimumGain;
    end
  %  disp(significance(k));
    
end

% Export filtered training and cross-validation data using optimal SOM
% filter parameters, yielding highest significance.  Note still scaled!
mySomFilter = somFilter(gainMatrix,kohonenSom,optimalGain);
filteredSignalCV = mySomFilter.filterEvents(signalCV);
filteredNoiseCV = mySomFilter.filterEvents(noiseCV);
filteredSignalTrain = mySomFilter.filterEvents(signalTrain);
filteredNoiseTrain = mySomFilter.filterEvents(noiseTrain);
filteredSignalTest = mySomFilter.filterEvents(signalTest);
filteredNoiseTest = mySomFilter.filterEvents(noiseTest);

% Scale back to original input scale before saving filtered samples.
if scaling == 1
    signalTrain(:,5:7)  = signalTrain(:,5:7) * pi/ 360;
    noiseTrain(:,5:7)  = noiseTrain(:,5:7) * pi/ 360;
    signalCV(:,5:7)  = signalCV(:,5:7) * pi/ 360;
    signalTrain(:,5:7)  = signalTrain(:,5:7) * pi/ 360;
    noiseCV(:,5:7)  = noiseCV(:,5:7) * pi/ 360;
    signalTest(:,5:7)  = signalTest(:,5:7) * pi/ 360;
    noiseTest(:,5:7)  = noiseTest(:,5:7) * pi/ 360;
end

if scaling == 2
    signalTrain = somStdScaler.scaleBackward(signalTrain);
    noiseTrain = somStdScaler.scaleBackward(noiseTrain);
    signalCV = somStdScaler.scaleBackward(signalCV);
    noiseCV = somStdScaler.scaleBackward(noiseCV);
    signalTest = somStdScaler.scaleBackward(signalTest);
    noiseTest = somStdScaler.scaleBackward(noiseTest);
end

save('../outputdata/filteredSignalCV.mat','filteredSignalCV');
save('../outputdata/filteredNoiseCV.mat','filteredNoiseCV');
save('../outputdata/filteredSignalTrain.mat','filteredSignalTrain');
save('../outputdata/filteredNoiseTrain.mat','filteredNoiseTrain');
save('../outputdata/filteredSignalTest.mat','filteredSignalTest');
save('../outputdata/filteredNoiseTest.mat','filteredNoiseTest');

figure(6)
plot(0:24,significance);
xlabel('Minimum SOM Cell Gain');
ylabel('Significance (\sigma)');
title('Signal Significance vs. Minimum SOM Filter Gain');

disp(['Best Significance: ' num2str(significance(optimalGain+1))]);
disp(['Optimal SOM Filter Gain: ' num2str(optimalGain)]);

if finalOutput == true

    finalSignificance = computeSignificance(size(filteredSignalTest,1),size(filteredNoiseTest,1));
    disp(['Test Set Significance: ' num2str(finalSignificance)]);
end

    
    