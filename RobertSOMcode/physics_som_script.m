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

% Load physics training, cross-validation, and test data.
load('../inputdata/noise_train.mat');
load('../inputdata/noise_cv.mat');
load('../inputdata/noise_test.mat');
load('../inputdata/signal_train.mat');
load('../inputdata/signal_cv.mat');
load('../inputdata/signal_test.mat');

trainInput = [noise_train;signal_train];

% Load or generate a SOM trained to separate signal from background.
try 
    % Attempt to load pre-trained SOM object
    load('kohonenSom.mat');
catch err
    % Create and train new SOM
    kohonenSom = som(somDim1,somDim2,size(signal_train,2));
    
    kohonenSom.trainInputs = trainInput';
    kohonenSom.maxIter = 2000001;
    % Set iterations used for exporting graphs.
    kohonenSom.iterList = [0 1000 10000 100000 250000 500000 1000000 1500000 2000000];
    
    % Train SOM and export graphs for specified iterations.
    kohonenSom.train();
    
    % Save SOM object for reuse later.
    save('kohonenSom.mat','kohonenSom');
end

% Compute number of signal and noise events for each SOM cell.
signalInputsPerPEMatrix = kohonenSom.computeInputsPerPEMatrix(signal_train');
noiseInputsPerPEMatrix = kohonenSom.computeInputsPerPEMatrix(noise_train');

% Plot distribution of signal and noise events along with normalized
% exemplars for each SOM cell.
exemplarSquaresPlot(signalInputsPerPEMatrix,noiseInputsPerPEMatrix,zeros(kohonenSom.height,kohonenSom.width),kohonenSom,2);

     
grayscaleSquaresPlot(signalInputsPerPEMatrix,3);
grayscaleSquaresPlot(noiseInputsPerPEMatrix,4);


% Compute SNR gain for each SOM cell.
trainSNR = size(signal_train,1)/size(noise_train,1);
gainMatrix = zeros(kohonenSom.height,kohonenSom.width);
for i=1:kohonenSom.height
    for j=1:kohonenSom.width
        cellSNR = signalInputsPerPEMatrix(i,j)/noiseInputsPerPEMatrix(i,j);
        
        gainMatrix(i,j) = cellSNR/trainSNR;
    end
end
       
% Plot SNR gain for each SOM cell.
grayscaleSquaresPlot(gainMatrix,4);

% Determine minimum gain associated with maximum significance on
% cross-validation set.
maxSignificance = 0;
optimalGain = 0;
for k=1:25
    minimumGain = k-1;
    
    mySomFilter = somFilter(gainMatrix,kohonenSom,minimumGain);
    
    filteredSignalCV = mySomFilter.filterEvents(signal_cv);
    filteredNoiseCV = mySomFilter.filterEvents(noise_cv);
     
    significance(k) = computeSignificance(size(signal_cv,1),size(noise_cv,1),size(filteredSignalCV,1),size(filteredNoiseCV,1));
    if significance(k) > maxSignificance
        maxSignificance = significance(k);
        optimalGain = minimumGain;
    end
    disp(significance(k));
    
end

% Export filtered training and cross-validation data using optimal SOM
% filter parameters, yielding highest significance.
mySomFilter = somFilter(gainMatrix,kohonenSom,optimalGain);
filteredSignalCV = mySomFilter.filterEvents(signal_cv);
filteredNoiseCV = mySomFilter.filterEvents(noise_cv);
filteredSignalTrain = mySomFilter.filterEvents(signal_train);
filteredNoiseTrain = mySomFilter.filterEvents(noise_train);
save('../outputdata/SOMfilteredSignalCV.mat','filteredSignalCV');
save('../outputdata/SOMfilteredNoiseCV.mat','filteredNoiseCV');
save('../outputdata/SOMfilteredSignalTrain.mat','filteredSignalTrain');
save('../outputdata/SOMfilteredNoiseTrain.mat','filteredNoiseTrain');



figure(6)
plot(0:24,significance);
xlabel('Minimum SOM Cell Gain');
ylabel('Significance (\sigma)');
title('Signal Significance vs. Minimum SOM Filter Gain');

disp(['Best Significance: ' num2str(significance(optimalGain+1))]);
disp(['Optimal SOM Filter Gain: ' num2str(optimalGain)]);



