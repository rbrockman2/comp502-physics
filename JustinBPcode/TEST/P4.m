%%function P4(TrainMat, TestMat, NPEs, gamma, epochK)

TrainMat = importdata('iris-train.txt')
TestMat = importdata('iris-test.txt');

TrainMat(TrainMat==0)=-1;
TestMat(TestMat==0)=-1;

TrainMat=TrainMat*0.8;
TestMat=TestMat*0.8;

NPEs = 40;%, 1, 5,  20]; 20
epochK = 2;%, 1, 10, 200, 400, 800]; 1 
gamma = 0.005;%, 0.05, 0.01, 0.005, 0.001]; 0.15

xVec = TrainMat(:,1:4)';
yVec = TrainMat(:,5:7)';
M = [xVec; yVec];

xTVec = TestMat(:,1:4)';
yTVec = TestMat(:,5:7)';
T = [xTVec; yTVec];
numTestPts = length(xTVec);

dataSetSize = size(M,2);
nInputs = 4;
nOutputs = 3;

kW1 = 2.4./12; % The fan-in is 2 for all points in layers layers 1 and 2.
W1 = (ones(NPEs , nInputs)*kW1).*(2*(rand([NPEs nInputs])-0.5)) % Initialize weights ~ Includes weights for Bias Elements
kW2 = 2.4/12; % The fan-in is 2 for all points in layers layers 1 and 2.
W2 = (ones(NPEs , 1)*kW2).*(2*(rand([NPEs 1])-0.5)) % Initialize weights ~ Includes weights for Bias Elements
W = [W1, W2];
kV = 2.4/12;   kb2 = 2.4/12;
V = [(ones(nOutputs , NPEs)*kV).*(2*(rand([nOutputs NPEs])-0.5)), (2*ones(nOutputs,1)*(rand(1)-0.5))*kb2]

epsilon = 0.05; % Learning rate, error tolerance

% Specifies the tanh function ~ function name must be a built in function of MATLAB or placed into the current folder
func.funName = 'tanh'; func.funInvName = 'atanh'; func.funDerName = 'tanhder';
func.a = 1; func.b = 1; % Parameters for tanh (or any other function)

recordstep = 100; 
maxiter = 100000+1; graphstep = 100;
dataMat = zeros(maxiter,(1+nInputs+nOutputs*2));
errorMat = zeros(maxiter,6);

dataMatTEST = zeros((ceil(maxiter/recordstep)-1)*(numTestPts+1),(1+nInputs+nOutputs*2));
errorMatTEST = zeros(maxiter,6);%(ceil(maxiter/recordstep)-1)*(numTestPts+1),6);

WMat = zeros(size(W,1), size(W,2), floor(maxiter/recordstep));
VMat = zeros(size(V,1), size(V,2), floor(maxiter/recordstep));

DelV = 0; DelW = 0;

ca = autumn(ceil(maxiter/graphstep));
cb = cool(ceil(maxiter/graphstep));

winpct = zeros(ceil(maxiter/graphstep),1);
winpctTEST = zeros(ceil(maxiter/graphstep),1);

figure
set(gcf,'color','w');
hold all

for iter=1:maxiter
    if mod(iter,dataSetSize)==1
        initIter = iter;
        P = randperm(dataSetSize);
    end

    x = M(1:4,P(iter-initIter+1));
    yDes = M(5:7,P(iter-initIter+1));
    fyDes = feval(func.funName,yDes);

    [~,~,y_L1,y_L2] = FeedForward(W,V,x,func);
    [del_L1,del_L2] = FeedBackward(V,fyDes,y_L1,y_L2);
    DelVi = gamma.*del_L2*[1; y_L1]';     DelWi = gamma.*del_L1*[1; x]';
    
    DelV = DelV + DelVi;    DelW = DelW + DelWi;
    
    yout = feval(func.funInvName,y_L2);
    dataMat(iter,:) = [iter x' yout' yVec(:,P(iter-initIter+1))'];
    errorMat(iter,1:4) = [iter, (yout-yVec(:,P(iter-initIter+1)))'];

    if iter>dataSetSize
        RMS = sqrt(norm(errorMat(iter,2:4))^2/3);
        errorMat(iter,5:6) = [mean(abs(errorMat(iter,2:4))) RMS];
        if errorMat(iter,5)<epsilon
            if hits >= dataSetSize
                disp(['Converged at ' num2str(iter)])
                break;
            else
                hits = hits+1;
            end
        else 
            hits = 0;
        end
    else
        RMS = sqrt( (norm(errorMat(1:iter,2))^2+norm(errorMat(1:iter,3))^2+norm(errorMat(1:iter,4))^2) ./3 )./sqrt(iter);
        errorMat(iter,5:6) = [mean(mean(abs(errorMat(1:iter,2:4)))) RMS];
    end

    if mod(iter,recordstep)==1

        for ii = 1:numTestPts
            [~,~,~,y_L2t] = FeedForward(W,V,T(1:4,ii),func);
            youtt = feval(func.funInvName,y_L2t);
            dataMatTEST((ceil(iter/recordstep)-1)*numTestPts+ii,:) = [iter T(1:4,ii)' youtt' yTVec(:,ii)'];
            errorMatTEST((ceil(iter/recordstep)-1)*numTestPts+ii,1:4) = [iter, (youtt-yTVec(:,ii))'];
            RMS = norm(errorMatTEST((ceil(iter/recordstep)-1)*numTestPts+ii,2:4))/sqrt(3);
            errorMatTEST((ceil(iter/recordstep)-1)*numTestPts+ii,5:6) = [mean(abs(errorMatTEST((ceil(iter/recordstep)-1)*numTestPts+ii,2:4))) RMS];
        end
        avgmeanerroroverdatasetTEST = mean(errorMatTEST((ceil(iter/recordstep)-1)*numTestPts+1:ceil(iter/recordstep)*numTestPts,5));
        avgrmserroroverdatasetTEST = mean(errorMatTEST((ceil(iter/recordstep)-1)*numTestPts+1:ceil(iter/recordstep)*numTestPts,6));
        if mod(iter,graphstep)==1
            if iter>graphstep+1
                avgmeanerroroverdataset = mean(errorMat(iter-dataSetSize+1:iter,5));
                avgrmserroroverdataset = mean(errorMat(iter-dataSetSize+1:iter,6));
                %plot(errorMat(iter-graphstep+1:iter,1),errorMat(iter-graphstep+1:iter,5),'color',ca(ceil(iter/(graphstep)),:))
                %plot(errorMat(iter-graphstep+1:iter,1),errorMat(iter-graphstep+1:iter,6),'color',cb(ceil(iter/(graphstep)),:))
                plot(errorMat(iter,1),avgmeanerroroverdataset,'bo',errorMat(iter,1),avgmeanerroroverdatasetTEST,'k.')%,'color',ca(ceil(iter/(graphstep)),:))
                plot(errorMat(iter,1),avgrmserroroverdataset,'bx',errorMat(iter,1),avgrmserroroverdatasetTEST,'c.')%,'color',cb(ceil(iter/(graphstep)),:))
                
                tmp1 = dataMat(iter-graphstep+1:iter,6:8);
                tmp2 = dataMat(iter-graphstep+1:iter,9:11);

                for i=1:graphstep
                    I1 = find(tmp1(i,:) == max(tmp1(i,:)));    I2 = find(tmp2(i,:) == max(tmp2(i,:))); 
                    if I1==I2
                        winpct(ceil(iter/graphstep))=winpct(ceil(iter/graphstep))+1;
                    end
                end
                
                tmp11 = dataMatTEST((ceil(iter/recordstep)-1)*numTestPts+1:ceil(iter/recordstep)*numTestPts,6:8);
                tmp22 = dataMatTEST((ceil(iter/recordstep)-1)*numTestPts+1:ceil(iter/recordstep)*numTestPts,9:11);
                
                for j=1:numTestPts
                    I1 = find(tmp11(j,:) == max(tmp11(j,:)));
                    I2 = find(tmp22(j,:) == max(tmp22(j,:)));
                    if I1==I2
                        winpctTEST(ceil(iter/graphstep))=winpctTEST(ceil(iter/graphstep))+1;
                    end
                end
                
                winpct(ceil(iter/graphstep)) = winpct(ceil(iter/graphstep))/graphstep;
                winpctTEST(ceil(iter/graphstep)) = winpctTEST(ceil(iter/graphstep))/numTestPts;


                disp(winpct(ceil(iter/graphstep))); disp(winpctTEST(ceil(iter/graphstep)));
                plot(errorMat(iter,1), winpct(ceil(iter/graphstep)),'b.',errorMat(iter,1), winpctTEST(ceil(iter/graphstep)),'r.')
            end
            drawnow

            %winpct = zeros(ceil(maxiter/graphstep),1);
            %winpctTEST = zeros(ceil(maxiter/recordstep,1);

            %plot(xTVec,TESTM(ceil(iter/recordstep),:)','o','color',ca(ceil(iter/(graphstep)),:));
            %if iter>1
                %plot(dataMat(iter-dataSetSize+1:iter,2),dataMat(iter-dataSetSize+1:iter,3),'x','color',cb(ceil(iter/(graphstep)),:))   
            %end
        end
    end    

    if mod(iter,epochK)==0
        [V,W] = UpdateWeights(V,W,DelV,DelW);
        DelV = 0; DelW = 0;
    end
end
dataMat(iter+1:end,:) = []; 
errorMat(iter+1:end,:) = []; 


hl = legend('Avg. Mean Err, Training', 'Avg. Mean Err, Test Data','Avg. RMS Err, Training', 'Avg. Mean Err, Test Data','Pct. Correct, Training', 'Pct. Correct, Test');
set(hl, 'interpreter','latex','fontsize',11)

xlabel('Iteration','interpreter','latex','fontsize',16); ylabel('Error/Accuracy','interpreter','latex','fontsize',16);
title(['P4: NPEs = ' num2str(NPEs) ' , $\gamma =$ , ' num2str(gamma) ', $K =$ ' num2str(epochK)],'interpreter','latex','fontsize',16)
set(gcf,'color','w')
 
export_fig(['outfiles/P3Output1_' num2str(NPEs) '_' num2str(gamma) '_' num2str(epsilon) '_' num2str(epochK) '_' num2str(recordstep) '.eps'])

% nTests = ceil(iter/recordstep);
% %errorMatTest = zeros(ceil(maxiter/recordstep),1); errorMatTest = sqrt(sum((TESTM-repmat(yTVec,[nTests, 1])).^2,2)); 
% %errorMatTest = mean(abs(TESTM(1:ceil(iter/recordstep),:)-repmat(yTVec,[nTests, 1])),2); 
% figure
% %plot(1:recordstep:iter,errorMatTest, 
%     plot(errorMat(201:200:end,1),errorMat(201:200:end,3))
% %plot(errorMat(1:100:end,1),errorMat(1:100:end,2),errorMat(1:100:end,1),errorMat(1:100:end,3),errorMat(201:100:end,1),errorMat(201:100:end,4))

% xlabel('Iteration','interpreter','latex','fontsize',16)
% ylabel('Error','interpreter','latex','fontsize',16)
% title(['Error: NPEs = ' num2str(NPEs) ', $\gamma =$ ' num2str(gamma) ', $K =$ ' num2str(epochK)],'interpreter','latex','fontsize',16)
% set(gcf,'color','w')
 
% hl = legend('Test Data Err','Training Data..');
% set(hl,'interpreter','latex','fontsize',12)

% export_fig(['outfiles/P4Error1_' num2str(NPEs) '_' num2str(gamma) '_' num2str(epochK) '_' num2str(recordstep) '.eps'])

save(['outfiles/P4VW_' num2str(NPEs) '_' num2str(gamma) '_' num2str(epochK) '_' num2str(recordstep) '.mat'],'WMat','VMat')

%%end
%}