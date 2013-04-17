% Inputs
% hLayerVec - Vector that has length of hidden layers, with values of the
%       number of PEs in hidden layer i at hLayerVec(i)
% x - x input data
% yt - y target output data
% xT - x input data from alternate test data set.
% ytT - y target output data from alternate test data set.
% bias - Set to 1 to initialize bias
% gam - Learning Rate
% eps - Convergence Criteria
% 
% Loop Settings
% maxIter - Maximum amount of Learning Steps
% batchSize - Learning Steps per Batch
% recordStep - Number of Learning Steps between each Recorded output set
% Convergence Settings
% - eps - epsilon
% - epsdecpct - decision percentage for convergence
% - maxIter - Maximum Iteration Cutoff


%ImpMat = importdata('iris-train.txt'); x = ImpMat(:,1:4)'; yt = ImpMat(:,5:7)';
n = 1:1:200; 
x = 2*sin(2*pi*n/20);
A = 1;
B = 0.2;
yt = A*x+B*x.^2;


%ImpMatT = importdata('iris-test.txt'); xT = ImpMatT(:,1:4)'; ytT = ImpMatT(:,5:7)';

xT = 0.8*sin(2*pi*n/10)+0.25*cos(2*pi*n/25);
ytT = A*xT+B*xT.^2;

%xT = randn([1 200]);
%ytT = A*xT+B*xT.^2;


hLayerVec = 80;%, 1, 5,  20]; 20
bias = 1;
batchSize = 1;%, 1, 10, 200, 400, 800]; 1

gam = 0.005;%, 0.05, 0.01, 0.005, 0.001]; 0.15
alph = 0.9;
maxIter = 100000;
recordStep = 100;

% Setting up Struct with ConvergenceEval Parameters
CE.eps = 0.0005; CE.epsdecpct = 0.99; CE.maxIter = maxIter;
scc = 0; scR = [-0.8, 0.8];

dimIn = size(x,1); dimOut = size(yt,1);

% Setting Up RecordDataP2 Parameters
% trainSetSize - Number of data points in the training set
% testSetSize - Number of data points in the test set
trainSetSize = size(yt,2);
RD.trainSetSize = trainSetSize;
RD.testSetSize = size(ytT,2);
RD.dimIn = dimIn; RD.dimOut = dimOut;

RD.WCRecIters = 0;
% Calculating Appropriate Scaling Factors
maxyall = max([max(yt,[],2) max(ytT,[],2)],[],2); minyall = min([min(yt,[],2) min(ytT,[],2)],[],2);
SDS.ycenter = (maxyall*(scR(2)-scc)+minyall*(scc-scR(1)))./(scR(2)-scR(1));
SDS.scf = (maxyall-minyall)./(scR(2)-scR(1));
% Finding the Maximum for Decision Testing
[~,RD.ytdec] = max(yt,[],1); [~,RD.ytTdec] = max(ytT,[],1);
RD.yt = yt; RD.ytT = ytT;

% Function Settings for Creating Weights
CWM.mode = 'cell'; CWM.alpha = 1; CWM.biasRange = 1;
[WC,PEVec,GS] = CreateWeightsMat(dimIn,dimOut,hLayerVec,bias,CWM);

% Function Settings for the Transfer Function
TF.funName = 'tanhCUST'; TF.funInvName = 'tanhINV'; TF.funDerName = 'tanhDER';
TF.params.a = 1; TF.params.b = 1; % Transfer Function Parameters

%-%-% Loop Setup
maxRecIter = ceil(maxIter/recordStep)+1;
maxBatchIter = ceil(maxIter/batchSize)+1;
maxSetIter = ceil(maxIter/trainSetSize)+1;

% Loop Size Warnings
if abs(recordStep/batchSize-floor(recordStep/batchSize))>1E-12
    disp('Warning: recordStep not a multiple of batchSize.')
end

% Precalculation of scaling the target output and test output to be within the T.F. Range
fytS = feval(TF.funName,ScaleDataSet(yt,SDS),TF.params);
fytTS = feval(TF.funName,ScaleDataSet(ytT,SDS),TF.params);

%-%-%

% The Results Matrix, containing the Error at each recorded learning step,
% the full data matrix at each recorded learning step, and the weights at
% selected learning steps

Res.Train.dataMat = zeros(dimOut,trainSetSize,maxRecIter); Res.Test.dataMat = zeros(dimOut,RD.testSetSize,maxRecIter);
Res.Train.errorMat = zeros(maxRecIter,2); Res.Test.errorMat = zeros(maxRecIter,2);
Res.WCREC = cell(length(RD.WCRecIters),1);

% Starting the Loop / Starting with Recording the initial output

[errVecAll,Res.Train.dataMat(:,:,1),Res.Test.dataMat(:,:,1)] = RecordDataP2(1,0,WC,x,xT,bias,TF,SDS,RD);
            %plot(errVecAll(1,1),errVecAll(1,end))
            %hold on
Res.Train.errorMat(1,:) = errVecAll(1,:);
Res.Test.errorMat(1,:) = errVecAll(2,:);
%errVecAllOLD=errVecAll;

DelWOld = cell(length(WC),1);
for ii = 1:length(WC)
    DelWOld{ii} = 0;
end

DelW=0;
if batchSize==1
    for iter=1:maxIter
        if mod(iter,trainSetSize)==1
            initIter = iter;
            P = randperm(trainSetSize);
        end
        Pind = iter-initIter+1;
        
        [yC,~] = FeedForward(WC,x(:,P(Pind)),bias,TF);
        delC = FeedBackward(WC,yC,fytS(:,P(Pind)),TF);
        DelW = ChangeWeightDelta(DelW,DelWOld,gam,alph,delC,x(:,P(Pind)),yC);
        [WC, DelW, DelWOld] = UpdateWeights(WC,DelW);
        
        % Data Recording, Test Monitoring, and Convergence Testing
        if mod(iter,recordStep)==0
            recIter = floor(iter/recordStep)+1;
            [errVecAll,Res.Train.dataMat(:,:,recIter),Res.Test.dataMat(:,:,recIter)] = RecordDataP2(recIter,iter,WC,x,xT,bias,TF,SDS,RD);
            Res.Train.errorMat(recIter,:) = errVecAll(1,:);
            Res.Test.errorMat(recIter,:) = errVecAll(2,:);
            if ConvergenceEvalP2(errVecAll,CE)
                break
            end
            % plot([errVecAllOLD(1,1); errVecAll(1,1)],[errVecAllOLD(1,2:end); errVecAll(1,2:end)],'-',[errVecAllOLD(2,1); errVecAll(2,1)],[errVecAllOLD(2,2:end); errVecAll(2,2:end)],'-')
            % errVecAllOLD = errVecAll;
            % drawnow
        end
    end
elseif batchSize>=trainSetSize
    setsPerBatch = floor(batchSize/trainSetSize);
    for iB = 1:maxBatchIter
        for iD = 1:setsPerBatch
            P = randperm(trainSetSize);
            
            [yC,~] = FeedForward(WC,x(:,P),bias,TF);
            delC = FeedBackward(WC,yC,fytS(:,P),TF);
            DelW = ChangeWeightDelta(DelW,DelWOld,gam,alph,delC,x(:,P(Pind)),yC);
        end
        
        [WC, DelW, DelWOld] = UpdateWeights(WC,DelW);
        
        iter = (iD*trainSetSize+iB*batchSize);
        if mod(iter,recordStep)==0
            recIter = floor(iter/recordStep)+1;
            errVecAll = RecordDataP2(recIter,iter,WC,x,xT,bias,TF,SDS,RD);
            if ConvergenceEvalP2(errVecAll,CE)
                break
            end
        end
    end
else
    batchesPerSet = floor(trainSetSize/batchSize);
    for iD=1:maxSetIter
        P = randperm(trainSetSize);
        for iB = 1:batchesPerSet
            Pind = (iB-1)*batchSize+1:1:iB*batchSize;
            [yC,~] = FeedForward(WC,x(:,P(Pind)),bias,TF);
            delC = FeedBackward(WC,yC,fytS(:,P(Pind)),TF);
            DelW = ChangeWeightDelta(DelW,DelWOld,gam,alph,delC,x(:,P(Pind)),yC);
            
            [WC, DelW, DelWOld] = UpdateWeights(WC,DelW);
            
            iter = (iD*trainSetSize+iB*batchSize);
            if mod(iter,recordStep)==0
                recIter = floor(iter/recordStep)+1;
                errVecAll = RecordDataP2(recIter,iter,WC,x,xT,bias,TF,SDS,RD);
                if ConvergenceEvalP2(errVecAll,CE)
                    break
                end
            end
        end
    end
end
% Removing Zero Values
Res.Train.dataMat(:,:,recIter+1:end) = [];
Res.Test.dataMat(:,:,recIter+1:end) = [];
Res.Train.errorMat(recIter+1:end,:) = [];
Res.Test.errorMat(recIter+1:end,:) = [];

C = clock;

% % Error Plot: Training Data
% close all

% figure
% semilogy(Res.Train.errorMat(:,1),Res.Train.errorMat(:,2:end))
% title(['Error: NPEs = ' num2str(hLayerVec(1)) ' , $\gamma =$ , ' num2str(gam) ', $K =$ ' num2str(batchSize)],'interpreter','latex','fontsize',16)
% set(gcf,'color','w')
% xlabel('Learning Step','interpreter','latex','fontsize',16);
% ylabel('Mean Squared Error','interpreter','latex','fontsize',16);
% %hl = legend('Avg. Mean Err., Training', 'Avg. RMSE, Training', 'Total RMSE, Training',  'Pct. Correct, Training', 'Avg. Mean Err., Test Data', 'Avg. RMSE, Test Data', 'Total RMSE, Test Data', 'Pct. Correct, Test');
% hl = legend('Avg. MSE on Training Data');
% set(hl,'fontsize',11,'location','best')

% export_fig(['H5-2-Err_' num2str([hLayerVec(1) CE.eps batchSize],'gam-%d_eps-%d_K-%d') '_' num2str(C(2:5),'%i-%i-%i-%i') '.eps'])

% % Input/Output Plot

% figure
% plot(x,yt,'go'); hold on;
% plot(x,Res.Train.dataMat(1,:,end),'bx'); hold off;
% title(['Output: NPEs = ' num2str(hLayerVec(1)) ' , $\gamma =$ , ' num2str(gam) ', $K =$ ' num2str(batchSize)],'interpreter','latex','fontsize',16)
% set(gcf,'color','w')
% xlabel('Input','interpreter','latex','fontsize',16);
% ylabel('Output','interpreter','latex','fontsize',16);
% hl = legend('Training Data Desired Output','Training Data Actual Output');
% set(hl, 'interpreter','latex','fontsize',11,'location','best')

% export_fig(['H5-2-InOut_' num2str([hLayerVec(1) CE.eps batchSize],'gam-%d_eps-%d_K-%d') '_' num2str(C(2:5),'%i-%i-%i-%i') '.eps'])

% % Desired/Actual Plot

% figure
% plot(yt,Res.Train.dataMat(1,:,end),'kx'); hold on;
% plot([-1.5 3],[-1.5 3],'k')
% title(['Output: NPEs = ' num2str(hLayerVec(1)) ' , $\gamma =$ , ' num2str(gam) ', $K =$ ' num2str(batchSize)],'interpreter','latex','fontsize',16)
% set(gcf,'color','w')
% xlabel('Desired Output','interpreter','latex','fontsize',16);
% ylabel('Actual Output','interpreter','latex','fontsize',16);
% hl = legend('Training Data','y=x');
% set(hl, 'interpreter','latex','fontsize',11,'location','best')

% export_fig(['H5-2-DesAct_' num2str([hLayerVec(1) CE.eps batchSize],'gam-%d_eps-%d_K-%d') '_' num2str(C(2:5),'%i-%i-%i-%i') '.eps'])


% Error Plot: Test Data
% close all

figure
semilogy(Res.Train.errorMat(:,1),Res.Train.errorMat(:,2:end),'b-'); hold on;
semilogy(Res.Test.errorMat(:,1),Res.Test.errorMat(:,2:end),'r-'); hold off;
title(['Error: NPEs = ' num2str(hLayerVec(1)) ' , $\gamma =$ , ' num2str(gam) ', $K =$ ' num2str(batchSize)],'interpreter','latex','fontsize',16)
set(gcf,'color','w')
xlabel('Learning Step','interpreter','latex','fontsize',16);
ylabel('Mean Squared Error','interpreter','latex','fontsize',16);
%hl = legend('Avg. Mean Err., Training', 'Avg. RMSE, Training', 'Total RMSE, Training',  'Pct. Correct, Training', 'Avg. Mean Err., Test Data', 'Avg. RMSE, Test Data', 'Total RMSE, Test Data', 'Pct. Correct, Test');
hl = legend('Avg. MSE, Train Data','Avg. MSE, Test Data');
set(hl,'fontsize',11,'location','SouthEast')

export_fig(['H5-2.2-Err_' num2str([hLayerVec(1) CE.eps batchSize],'gam-%d_eps-%d_K-%d') '_' num2str(C(2:5),'%i-%i-%i-%i') '.eps'])



% Input/Output Plot

figure
plot(x,yt,'kx'); hold on;
plot(xT,ytT,'ko');
plot(x,Res.Train.dataMat(1,:,end),'bx');
plot(xT,Res.Test.dataMat(1,:,end),'ro'); hold off;
% plot(yt,Res.Train.dataMat(:,:,end)','bo',ytT',Res.Test.dataMat(:,:,end)','r.','markersize',2)
title(['Output: NPEs = ' num2str(hLayerVec(1)) ' , $\gamma =$ , ' num2str(gam) ', $K =$ ' num2str(batchSize)],'interpreter','latex','fontsize',16)
set(gcf,'color','w')
xlabel('Input','interpreter','latex','fontsize',16);
ylabel('Output','interpreter','latex','fontsize',16);
hl = legend('Train Data Desired Output','Test Data Desired Output','Train Data Actual Output','Test Data Actual Output');
set(hl, 'interpreter','latex','fontsize',11,'location','best')

export_fig(['H5-2.2-InOut_' num2str([hLayerVec(1) CE.eps batchSize],'gam-%d_eps-%d_K-%d') '_' num2str(C(2:5),'%i-%i-%i-%i') '.eps'])

% Desired/Actual Plot

figure
plot(yt,Res.Train.dataMat(1,:,end),'bx'); hold on;
plot(ytT,Res.Test.dataMat(1,:,end),'ro'); 
plot([-1.5 3],[-1.5 3],'k'); hold off;
title(['Output: NPEs = ' num2str(hLayerVec(1)) ' , $\gamma =$ , ' num2str(gam) ', $K =$ ' num2str(batchSize)],'interpreter','latex','fontsize',16)
set(gcf,'color','w')
xlabel('Desired Output','interpreter','latex','fontsize',16);
ylabel('Actual Output','interpreter','latex','fontsize',16);
hl = legend('Train Data','Test Data','y=x');
set(hl, 'interpreter','latex','fontsize',11,'location','best')

export_fig(['H5-2.2-DesAct_' num2str([hLayerVec(1) CE.eps batchSize],'gam-%d_eps-%d_K-%d') '_' num2str(C(2:5),'%i-%i-%i-%i') '.eps'])
