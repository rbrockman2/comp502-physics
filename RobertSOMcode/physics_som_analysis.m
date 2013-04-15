






cleanSignalTrain = [];
for l = 1:size(signal_train,1)
    winningPE = kohonenSom.findWinner(signal_train(l,:));
    if highGainSOMCellMatrix(winningPE(1),winningPE(2)) == 1
        disp(winningPE);
        cleanSignalTrain = [cleanSignalTrain;signal_train(l,:)];
    end
end

cleanNoiseTrain = [];
for l = 1:size(noise_train,1)
    winningPE = kohonenSom.findWinner(noise_train(l,:));
    if highGainSOMCellMatrix(winningPE(1),winningPE(2)) == 1
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

% for i = 1:size(cleanSignalTrain,2)
%     figure(i+10)
%     hist(cleanSignalTrain(:,i),10);
%     h = findobj(gca,'Type','patch');
%     set(h,'FaceColor','r','EdgeColor','w')
%     hold on;
%     hist(cleanNoiseTrain(:,i),10);
%     h = findobj(gca,'Type','patch');
%     set(h,'facealpha',0.75)
%     hold off;
% end
%     


    
