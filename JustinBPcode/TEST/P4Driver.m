

TrainMat = importdata('iris-train.txt')
TestMat = importdata('iris-test.txt');

NPEs = 1;%, 1, 5,  20];
epochKV = 1;%, 1, 10, 200, 400, 800];
gammaBase = 0.001;%, 0.05, 0.01, 0.005, 0.001];

P4(TrainMat, TestMat, NPEs, gammaBase, epochKV)
% for i=1:length(NPEs)
% 	for j = 1:length(gammaBase)
% 		for k = 1:length(epochKV)
% 			P4(TrainMat, TestMat, NPEs(i), gammaBase(j), epochKV(k))
% 		end
% 	end
% end

