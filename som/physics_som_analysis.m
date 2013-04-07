signalTrainOutput = zeros(size(signal_train,1),2);
signalTrainOutput(:,1) = 1;


noiseTrainOutput = zeros(size(noise_train,1),2);
noiseTrainOutput(:,2) = 1;

trainOutput = [noiseTrainOutput; signalTrainOutput];


signalCvOutput = zeros(size(signal_cv,1),2);
signalCvOutput(:,1) = 1;


noiseCvOutput = zeros(size(noise_cv,1),2);
noiseCvOutput(:,2) = 1;

cvOutput = [noiseCvOutput; signalCvOutput];

combineOutput = [trainOutput;cvOutput];

signalClass = [];
for k=1:size(combineOutput,1)
    if combineOutput(k,1)==1
        signalClass = [signalClass; combineInput(k,:)];
    end
end
signalInputsPerPEMatrix = kohonenSom.computeInputsPerPEMatrix(signalClass');

noiseClass = [];
for k=1:size(combineOutput,1)
    if combineOutput(k,2)==1
        noiseClass = [noiseClass; combineInput(k,:)];
    end
end
noiseInputsPerPEMatrix = kohonenSom.computeInputsPerPEMatrix(noiseClass');


highSnrSomCells = zeros(kohonenSom.height,kohonenSom.width);

emptyPENum=0;
figure(2)
plot(1,1,'o');
hold on;
for i=1:kohonenSom.height
    for j=1:kohonenSom.width

        color1 = signalInputsPerPEMatrix(i,j)/max(max(signalInputsPerPEMatrix));
        if color1 > 1
            color1 = 1;
        end
        
        color2 = noiseInputsPerPEMatrix(i,j)/max(max(noiseInputsPerPEMatrix));
        if color2 > 1
            color2 = 1;
        end
                color1 =0;
                color2 =0;
        color3 =  0;
        
        snr = signalInputsPerPEMatrix(i,j)/noiseInputsPerPEMatrix(i,j);
        
        %color3 = snr/5;
        if snr > 3 
            color3=1;
            highSnrSomCells(i,j) = 1;
        end
        if color3 > 1
            color3 = 1;
        end
        
        if [color1 color2 color3] == [0 0 0]
            emptyPENum = emptyPENum +1;
        end
        
        
        rectangle('Position',[i-0.5,j-0.5,1,1],...
            'Curvature',[0,0],...
            'FaceColor',[color1 color2 color3]);
    end
end
axis([0.5 10.5 0.5 10.5]);
xlabel('Coordinate 1');
ylabel('Coordinate 2');

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
    
    
