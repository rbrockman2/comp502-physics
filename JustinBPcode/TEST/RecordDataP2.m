function [errVecAll,TrainOutputRI,TestOutputRI] = RecordDataP2(recIter,iter,WC,x,xT,bias,TF,SDS,RD,imfact)
%RECORDDATA Summary of this function goes here
%   Detailed explanation goes here

[~,fyStmp] = FeedForward(WC,x,bias,TF);
[~,fyTStmp] = FeedForward(WC,xT,bias,TF);

outyStmp = feval([TF.funInvName],fyStmp,TF.params);
outyTStmp = feval([TF.funInvName],fyTStmp,TF.params);

TrainOutputRI = UnscaleDataSet(outyStmp,SDS)*imfact;
TestOutputRI = UnscaleDataSet(outyTStmp,SDS)*imfact;

%AvAbsErr = mean(sum(abs(RD.yt - TrainOutputRI),1)/RD.dimOut);
%AvMSE = mean((sum((RD.yt - TrainOutputRI).^2,1)/RD.dimOut));
RMRMSD = sqrt(sum(sqrt(sum((RD.yt - TrainOutputRI./imfact).^2,1)/RD.dimOut))/RD.trainSetSize);
%[~,ydec] = max(TrainOutputRI,[],1);

%AvAbsErrT = mean(sum(abs(RD.ytT - TestOutputRI),1)/RD.dimOut);
%AvMSET = mean((sum((RD.ytT*imfact - TestOutputRI).^2,1)/RD.dimOut));
RMRMSDT = sqrt(sum(sqrt(sum((RD.ytT - TestOutputRI./imfact).^2,1)/RD.dimOut))/RD.testSetSize);
%[~,yTdec] = max(TestOutputRI,[],1);

%frC = sum(RD.ytdec==ydec)/RD.trainSetSize;
%frCT = sum(RD.ytTdec==yTdec)/RD.testSetSize;

errVecAll = [iter, RMRMSD;
    iter, RMRMSDT];

%Res.Train.errorMat(recIter,:) = errVecAll(1,:);
%Res.Test.errorMat(recIter,:) = errVecAll(2,:);

for ind = 1:length(RD.WCRecIters)
    if iter==RD.WCRecIters(ind)
        Res.WCREC{recIter} = WC;
    end
end

end