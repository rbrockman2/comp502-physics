




minimumGain = 10;
trainSNR = size(signal_train,1)/size(noise_train,1);

gainMatrix = zeros(kohonenSom.height,kohonenSom.width);
for i=1:kohonenSom.height
    for j=1:kohonenSom.width
        cellSNR = signalInputsPerPEMatrix(i,j)/noiseInputsPerPEMatrix(i,j);
        
        gainMatrix(i,j) = cellSNR/trainSNR;
    end
end
       
     
grayscaleSquaresPlot(signalInputsPerPEMatrix,2)
grayscaleSquaresPlot(noiseInputsPerPEMatrix,3)
grayscaleSquaresPlot(gainMatrix,4);

highGainSOMCellMatrix = zeros(kohonenSom.height,kohonenSom.width);
for i=1:kohonenSom.height
    for j=1:kohonenSom.width
        if gainMatrix(i,j) >= minimumGain
            highGainSOMCellMatrix(i,j) = 1;
        end;
    end
end

grayscaleSquaresPlot(highGainSOMCellMatrix,5);
figure(5);
colorbar('off');


cleanSignalTrain = [];
for l = 1:size(signal_train,1)
    winningPE = kohonenSom.findWinner(signal_train(l,:));
    if highSnrSomCells(winningPE(1),winningPE(2)) == 1
        disp(winningPE);
        cleanSignalTrain = [cleanSignalTrain;signal_train(l,:)];
    end
end

cleanNoiseTrain = [];
for l = 1:size(noise_train,1)
    winningPE = kohonenSom.findWinner(noise_train(l,:));
    if highSnrSomCells(winningPE(1),winningPE(2)) == 1
        disp(winningPE);
        cleanNoiseTrain = [cleanNoiseTrain;noise_train(l,:)];
    end
end

gain = (size(cleanSignalTrain,1)/size(cleanNoiseTrain,1))/(size(signal_train,1)/size(noise_train,1));
disp(gain);

sampleLossRatio = (size(cleanNoiseTrain,1)+size(cleanSignalTrain,1))/(size(signal_train,1)+size(noise_train,1));
disp(sampleLossRatio);

approxLBoost = gain * sampleLossRatio^0.5;
disp(approxLBoost);

for i = 1:size(cleanSignalTrain,2)
    figure(i)
    hist(cleanSignalTrain(:,i),10);
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r','EdgeColor','w')
    hold on;
    hist(cleanNoiseTrain(:,i),10);
    hold off;
end
    
    
