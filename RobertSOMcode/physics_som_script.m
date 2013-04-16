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
cvInput = [noise_cv;signal_cv];

% Create output labels for training data.
signalTrainOutput = zeros(size(signal_train,1),2);
signalTrainOutput(:,1) = 1;
noiseTrainOutput = zeros(size(noise_train,1),2);
noiseTrainOutput(:,2) = 1;
signalCvOutput = zeros(size(signal_cv,1),2);
signalCvOutput(:,1) = 1;
noiseCvOutput = zeros(size(noise_cv,1),2);
noiseCvOutput(:,2) = 1;

trainOutput = [noiseTrainOutput; signalTrainOutput];
cvOutput = [noiseCvOutput; signalCvOutput];


% Unified training set for SOM
combineInput = [trainInput;cvInput];
combineOutput = [trainOutput;cvOutput];

% Load or generate a SOM trained to separate signal from background.
try 
    % Attempt to load pre-trained SOM object
    load('kohonenSom.mat');
catch err
    % Create and train new SOM
    kohonenSom = som(somDim1,somDim2,size(signal_train,2));
    
    kohonenSom.trainInputs = combineInput';
    % Set iterations used for exporting graphs.
    kohonenSom.iterList = [0 1000 10000 100000 250000 500000];
    
    % Train SOM and export graphs for specified iterations.
    kohonenSom.train();
    
    % Save SOM object for reuse later.
    save('kohonenSom.mat','kohonenSom');
end

% Compute number of signal and noise events for each SOM cell.
signalInputsPerPEMatrix = kohonenSom.computeInputsPerPEMatrix([signal_train; signal_cv]');
noiseInputsPerPEMatrix = kohonenSom.computeInputsPerPEMatrix([noise_train; noise_cv]');

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




for k=1:25
    minimumGain = k-1;
    
    highGainSOMCellMatrix = zeros(kohonenSom.height,kohonenSom.width);
    for i=1:kohonenSom.height
        for j=1:kohonenSom.width
            if gainMatrix(i,j) >= minimumGain
                highGainSOMCellMatrix(i,j) = 1;
            end;
        end
    end
    
    
    cleanSignalTrain = somFilter(minimumGain,gainMatrix,signal_train,kohonenSom);
    cleanNoiseTrain = somFilter(minimumGain,gainMatrix,noise_train,kohonenSom);
  %  cleanSignalTrain = [];
   % for l = 1:size(signal_train,1)
   %     winningPE = kohonenSom.findWinner(signal_train(l,:));
   %     if highGainSOMCellMatrix(winningPE(1),winningPE(2)) == 1
   %        % disp(winningPE);
   %         cleanSignalTrain = [cleanSignalTrain;signal_train(l,:)];
   %     end
   % end
    
   % cleanNoiseTrain = [];
   % for l = 1:size(noise_train,1)
   %     winningPE = kohonenSom.findWinner(noise_train(l,:));
   %     if highGainSOMCellMatrix(winningPE(1),winningPE(2)) == 1
   %       %  disp(winningPE);
   %         cleanNoiseTrain = [cleanNoiseTrain;noise_train(l,:)];
   %     end
   % end
    
    
    trainGain = (size(cleanSignalTrain,1)/size(cleanNoiseTrain,1))/(size(signal_train,1)/size(noise_train,1));
    %disp(trainGain);
    
    sampleLossRatio = (size(cleanNoiseTrain,1)+size(cleanSignalTrain,1))/(size(signal_train,1)+size(noise_train,1));
    %disp(sampleLossRatio);
    
    approxLBoost = trainGain * sampleLossRatio^0.5;
    %disp(approxLBoost);
    
    grayscaleSquaresPlot(highGainSOMCellMatrix,5);
    figure(5);
    colorbar('off');
    %pause;
    
    initialSignalCrossSection = 5.55;
    initialNoiseCrossSection = 192;
    cvNoiseNum = size(noise_cv,1);
    cvSignalNum = size(signal_cv,1);
    
    cleanSignalCV = [];
    for l = 1:cvSignalNum
        winningPE = kohonenSom.findWinner(signal_cv(l,:));
        if highGainSOMCellMatrix(winningPE(1),winningPE(2)) == 1
            % disp(winningPE);
            cleanSignalCV = [cleanSignalCV;signal_cv(l,:)];
        end
    end
    
    cleanNoiseCV = [];
    for l = 1:cvNoiseNum
        winningPE = kohonenSom.findWinner(noise_cv(l,:));
        if highGainSOMCellMatrix(winningPE(1),winningPE(2)) == 1
            %  disp(winningPE);
            cleanNoiseCV = [cleanNoiseCV;noise_cv(l,:)];
        end
    end
    
    significance(k) = computeSignificance(cvSignalNum,cvNoiseNum,size(cleanSignalCV,1),size(cleanNoiseCV,1));
    disp(significance(k));
    
end

figure(6)
plot(significance);



