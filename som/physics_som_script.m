% Robert Brockman II - S00285133
% COMP 502 Spring 2013
% Homework 8
%
% physics_som_script.m: Use self-organizing map code to find clusters in
% stop squark signal / top quark background data.

clear classes;
set(gcf,'color','w');

% Load Iris test and training data.
load('../inputdata/noise_train.mat');
load('../inputdata/noise_cv.mat');
load('../inputdata/noise_test.mat');
load('../inputdata/signal_train.mat');
load('../inputdata/signal_cv.mat');
load('../inputdata/signal_test.mat');

trainInput = [noise_train;signal_train];




%trainOutput = irisTrain(:,5:7);

cvInput = [noise_cv;signal_cv];
%testOutput = irisTest(:,5:7);

% Unified training set for SOM
combineInput = [trainInput;cvInput];
%combineOutput = [trainOutput;testOutput];


kohonenSom = som(10,10,8);

kohonenSom.trainInputs = combineInput';
% Set iterations used for exporting graphs.
kohonenSom.iterList = [0 1000 10000 100000 250000 500000];

kohonenSom.train();

%
% irisClass1 = [];
% for k=1:size(combineOutput,1)
%     if combineOutput(k,1)==1
%         irisClass1 = [irisClass1; combineInput(k,:)];
%     end
% end
% class1InputsPerPEMatrix = kohonenSom.computeInputsPerPEMatrix(irisClass1');
% 
% irisClass2 = [];
% for k=1:size(combineOutput,1)
%     if combineOutput(k,2)==1
%         irisClass2 = [irisClass2; combineInput(k,:)];
%     end
% end
% class2InputsPerPEMatrix = kohonenSom.computeInputsPerPEMatrix(irisClass2');
% 
% irisClass3 = [];
% for k=1:size(combineOutput,1)
%     if combineOutput(k,3)==1
%         irisClass3 = [irisClass3; combineInput(k,:)];
%     end
% end
% class3InputsPerPEMatrix = kohonenSom.computeInputsPerPEMatrix(irisClass3');
% 
% emptyPENum=0;
% figure(2)
% plot(1,1,'o');
% hold on;
% for i=1:kohonenSom.height
%     for j=1:kohonenSom.width
% 
%         color1 = class1InputsPerPEMatrix(i,j)/3;
%         if color1 > 1
%             color1 = 1;
%         end
%         
%         color2 = class2InputsPerPEMatrix(i,j)/3;
%         if color2 > 1
%             color2 = 1;
%         end
%         
%         color3 = class3InputsPerPEMatrix(i,j)/3;
%         if color3 > 1
%             color3 = 1;
%         end
%         
%         if [color1 color2 color3] == [0 0 0]
%             emptyPENum = emptyPENum +1;
%         end
%         
%         
%         rectangle('Position',[i-0.5,j-0.5,1,1],...
%             'Curvature',[0,0],...
%             'FaceColor',[color1 color2 color3]);
%     end
% end
% axis([0.5 10.5 0.5 10.5]);
% xlabel('Coordinate 1');
% ylabel('Coordinate 2');
% set(gcf,'color','w');
% export_fig('hw8_2_color.eps',2);
% 
% hold off;
% 
% disp(emptyPENum);





