function P3(NPEs, numTrS, gamma, epochK, scf)

xVec = rand([1,numTrS])*0.9+0.1;
yVec = 1./xVec;
yVecS = (scf/10).*yVec-(scf/(2-scf/10));
M = [xVec; yVecS];

xTVec = rand([1,100])*0.9+0.1;
yTVec = 1./xTVec;
yTVecS = (scf/10).*yTVec-(scf/(2-scf/10));
T = [xTVec; yTVecS];
numTestPts = length(xTVec);

dataSetSize = size(M,2);
nInputs = 1;
nOutputs = 1;


kW1 = 2.4./24; % The fan-in is 2 for all points in layers layers 1 and 2.
W1 = (ones(NPEs,1)*kW1).*(2*(rand([NPEs 1])-0.5)) % Initialize weights ~ Includes weights for Bias Elements
kW2 = 2.4/24; % The fan-in is 2 for all points in layers layers 1 and 2.
W2 = (ones(NPEs,1)*kW2).*(2*(rand([NPEs 1])-0.5)) % Initialize weights ~ Includes weights for Bias Elements
W = [W1, W2];
kV = 2.4/24;   kb2 = 2.4/24;
V = [(2*(rand(1)-0.5))*kb2, (ones(1,NPEs)*kV).*(2*(rand([1 NPEs])-0.5))]

epsilon = 0.075; % Learning rate, error tolerance

% Specifies the tanh function ~ function name must be a built in function of MATLAB or placed into the current folder
func.funName = 'tanh'; func.funInvName = 'atanh'; func.funDerName = 'tanhder';
func.a = 1; func.b = 1; % Parameters for tanh (or any other function)

recordstep = 1000; 
maxiter = 500000+1; graphstep = floor(maxiter/5);
dataMat = zeros(maxiter,(1+nInputs+nOutputs*2));
errorMat = zeros(maxiter,4);

WMat = zeros(size(W,1), size(W,2), recordstep);
VMat = zeros(size(V,1), size(V,2), recordstep);

DelV = 0; DelW = 0;
TESTM = zeros(ceil(maxiter/recordstep),numTestPts);

ca = flipud(autumn(ceil(maxiter/graphstep)));
cb = flipud(cool(ceil(maxiter/graphstep)));

YYp = sortrows([[xTVec' ; xVec'],[yTVec' ; yVec']]);
plot(YYp(:,1),YYp(:,2),'color','b','linewidth',2)
set(gcf,'color','w');
%hold all

for iter=1:maxiter
    if mod(iter,dataSetSize)==1
        initIter = iter;
        P = randperm(dataSetSize);
    end
    
    x = M(1,P(iter-initIter+1));
    yDes = M(2,P(iter-initIter+1));
    fyDes = feval(func.funName,yDes);
    
    [~,~,y_L1,y_L2] = FeedForward(W,V,x,func);
    [del_L1,del_L2] = FeedBackward(V,fyDes,y_L1,y_L2);
    DelVi = gamma.*del_L2*[1; y_L1]';     DelWi = gamma.*del_L1*[1; x]'; 
    
    DelV = DelV + DelVi;    DelW = DelW + DelWi;
    
    yout = (  feval(func.funInvName,y_L2)  +  (scf/(2-scf/10)))*10/scf;
    dataMat(iter,:) = [iter x' yout yVec(P(iter-initIter+1))];
    errorMat(iter,1:2) = [iter, (yout-yVec(P(iter-initIter+1)))];

    if iter>dataSetSize
        errorMat(iter,3:4) = [mean(abs(errorMat((iter-dataSetSize+1):iter,2))) norm(errorMat((iter-dataSetSize+1):iter,2))]; 
        if errorMat(iter,3)<epsilon 
            disp(['Converged at ' num2str(iter)])
            figure
            plot(YYp(:,1),YYp(:,2),'color','b','linewidth',2);
            hold all
            plot(xTVec,TESTM(ceil(iter/recordstep),:)','o','color',ca(ceil(iter/(graphstep)),:));
            plot(dataMat(iter-dataSetSize+1:iter,2),dataMat(iter-dataSetSize+1:iter,3),'x','color',cb(ceil(iter/(graphstep)),:));   
            break
        end
    else
        errorMat(iter,3:4) = [mean(abs(errorMat(1:iter,2))) norm(errorMat(1:iter,2))];
    end

    if mod(iter,recordstep)==1

        for ii = 1:numTestPts
            [~,~,~,y_L2t] = FeedForward(W,V,T(1,ii),func);
            youtt = (  feval(func.funInvName,y_L2t)   + (scf/(2-scf/10)))*10/scf;
            TESTM(ceil(iter/recordstep),ii) = youtt;
        end
        
        if mod(iter,graphstep)==1
            plot(YYp(:,1),YYp(:,2),'color','b','linewidth',2);
            hold on
            set(gcf,'color','w');
            plot(xTVec,TESTM(ceil(iter/recordstep),:)','o','color',ca(ceil(iter/(graphstep)),:));
            if iter>1
                plot(dataMat(iter-dataSetSize+1:iter,2),dataMat(iter-dataSetSize+1:iter,3),'x','color',cb(ceil(iter/(graphstep)),:));   
            end
        end
        drawnow
        hold off
    end    
    
    if mod(iter,epochK)==0
        [V,W,DelV,DelW] = UpdateWeights(V,W,DelV,DelW);
        
    end
end
dataMat(iter+1:end,:) = []; 
errorMat(iter+1:end,:) = []; 

xlabel('$x$','interpreter','latex','fontsize',16); ylabel('$y$','interpreter','latex','fontsize',16)
title(['Output: NPEs = ' num2str(NPEs) ', $N_{D} =$ ' num2str(numTrS) ', $\gamma =$ ' num2str(gamma) ', $K =$ ' num2str(epochK)],'interpreter','latex','fontsize',16)
set(gcf,'color','w')
 
export_fig(['outfiles/P3Output2_' num2str(NPEs) '_' num2str(numTrS) '_' num2str(gamma) '_' num2str(epsilon) '_' num2str(epochK) '_' num2str(recordstep) '.eps'])
hold off
nTests = ceil(iter/recordstep);
%errorMatTest = zeros(ceil(maxiter/recordstep),1); errorMatTest = sqrt(sum((TESTM-repmat(yTVec,[nTests, 1])).^2,2)); 
errorMatTest = mean(abs(TESTM(1:ceil(iter/recordstep),:)-repmat(yTVec,[nTests, 1])),2); 
figure
plot(1:recordstep:iter,errorMatTest, errorMat(201:200:end,1),errorMat(201:200:end,3))
%plot(errorMat(1:100:end,1),errorMat(1:100:end,2),errorMat(1:100:end,1),errorMat(1:100:end,3),errorMat(201:100:end,1),errorMat(201:100:end,4))

xlabel('Iteration','interpreter','latex','fontsize',16)
ylabel('Error','interpreter','latex','fontsize',16)
title(['Error: NPEs = ' num2str(NPEs) ', $N_{D} =$ ' num2str(numTrS) ', $\gamma =$ ' num2str(gamma) ', $K =$ ' num2str(epochK)],'interpreter','latex','fontsize',16)
set(gcf,'color','w')
 
hl = legend('Test Data Err','Training Data..');
set(hl,'interpreter','latex','fontsize',12)

export_fig(['outfiles/P3Error2_' num2str(NPEs) '_' num2str(numTrS) '_' num2str(gamma) '_' num2str(epochK) '_' num2str(recordstep) '.eps'])

save(['outfiles/P3VW_' num2str(NPEs) '_' num2str(numTrS) '_' num2str(gamma) '_' num2str(epochK) '_' num2str(recordstep) '.mat'],'WMat','VMat')

close all
end