% Robert Brockman II, Justin DeVito, and Ricky LeVan
% COMP 502 Spring 2013
% Final Project
%
% som.m - Class definition for a self-organizing map.
%
classdef som < handle % Objects are passed by reference.  
    properties
        weightMatrix
    
    
        height
        width             
        numInputs % Input Dimensionality
        
        % Training Parameters
        maxIter = 500001;
        sigma;
        learningRate=0.3;
        
        reportingInterval = 100; % number of iterations per reporting interval

        trainingInfoPath = '';
        
        iterList;
        trainInputs;
    end
    
    methods
        function obj=som(height,width,numInputs)          
            obj.weightMatrix=zeros(height,width,numInputs);
            
            obj.height= height;
            obj.width= width;
            obj.numInputs = numInputs;
            
            obj.sigma = (obj.width+obj.height)/4;
            
            for n=1:height              
            % Small initial values are (-0.1,+0.1)
                obj.weightMatrix(n,:,:) = (rand(1,width,numInputs) -0.5)/5;
               
            end
     
        end
        
        function plotMappingInputSpace(obj,iter) % Only works for 2-D input
            figure(1);
            for i = 1:obj.height
                for j = 1:obj.width
                    if i<obj.height
                        plot([obj.weightMatrix(i,j,1) obj.weightMatrix(i+1,j,1)],...
                        [obj.weightMatrix(i,j,2) obj.weightMatrix(i+1,j,2)]);
                        hold on;
                    end
                    if j<obj.width
                        plot([obj.weightMatrix(i,j,1) obj.weightMatrix(i,j+1,1)],...
                        [obj.weightMatrix(i,j,2) obj.weightMatrix(i,j+1,2)]);
                        hold on;
                    end
                end
            end
            hold off;
            title(['Iteration=' int2str(iter) ' Sigma = ' num2str(obj.sigma,8) ' Eta=' num2str(obj.learningRate,8)]);
            ylabel('Coordinate 1');
            xlabel('Coordinate 2');      
        end             
        
        function [inputsPerPEMatrix] = computeInputsPerPEMatrix(obj, inputs)
            inputsPerPEMatrix = zeros(obj.height,obj.width);
            for l=1:size(inputs,2)
                correctPE = obj.findWinner(inputs(:,l));
                inputsPerPEMatrix(correctPE(1),correctPE(2)) = ...
                  inputsPerPEMatrix(correctPE(1),correctPE(2)) +1;
                
            end
        end
        
        function plotMappingSOMGrid(obj,iter)
           inputsPerPEMatrix = obj.computeInputsPerPEMatrix(obj.trainInputs);
           
            hold on
            for i=1:obj.height
               for j=1:obj.width
                 
                       color = inputsPerPEMatrix(i,j)/max(max(inputsPerPEMatrix));
                       if color > 1
                           color = 1;
                       end
                       rectangle('Position',[i-0.5,j-0.5,1,1],...
                                 'Curvature',[0,0],...
                                 'FaceColor',color*[1 1 1]);
               end
           end
           axis([0.5 obj.height+0.5 0.5 obj.width+0.5]);   
           xlabel('Coordinate 1');
           ylabel('Coordinate 2');
           title(['Sigma: ' num2str(obj.sigma) ' Eta: ' num2str(obj.learningRate) ' Iter: ' int2str(iter)]);     
           hold off
        end
      

               
        function [minDistanceCoordinates] = findWinner(obj,inputVector)
            coordinateDistanceMatrix = obj.weightMatrix;
            for k=1:obj.numInputs
                coordinateDistanceMatrix(:,:,k)=coordinateDistanceMatrix(:,:,k)-inputVector(k);
            end
            pythagoreanDistanceSquared = zeros(obj.height,obj.width);
            
            for k=1:obj.numInputs
                pythagoreanDistanceSquared = pythagoreanDistanceSquared + ...
                    coordinateDistanceMatrix(:,:,k).*coordinateDistanceMatrix(:,:,k);
            end
            
            minDistanceCoordinates = [1 1];
            minDistanceValue = pythagoreanDistanceSquared(1,1);
            for i=1:obj.height
                for j=1:obj.width
                    if pythagoreanDistanceSquared(i,j) < minDistanceValue
                        minDistanceValue = pythagoreanDistanceSquared(i,j);
                        minDistanceCoordinates = [i j];
                    end
                end
            end           
        end
        
        function [h] = neighborhoodFunction(obj,winnerCoordinates)
           h=zeros(obj.height,obj.width);
           for i=1:obj.height
               for j=1:obj.width
                   rowDistance = winnerCoordinates(1)-i;
                   colDistance = winnerCoordinates(2)-j;
                   distSquared = rowDistance^2+colDistance^2;
                   h(i,j)=exp(-distSquared/(2*obj.sigma^2));
               end
           end           
           %disp(h);        
        end
        
        function updateWeights(obj,inputVector)
            winnerCoordinates = obj.findWinner(inputVector);
            %disp(winnerCoordinates);
            h = obj.neighborhoodFunction(winnerCoordinates);
            weightChange =zeros(obj.height,obj.width,obj.numInputs);
            for k=1:obj.numInputs
                weightChange(:,:,k)=obj.learningRate*(-obj.weightMatrix(:,:,k)+inputVector(k)).*h;
               
            end
           obj.weightMatrix = obj.weightMatrix + weightChange;
           %disp(weightChange);        
        end
        
        function [iterBool] = inList(obj,iter)
            iterBool = 0;
            for i=1:size(obj.iterList,2)
                if iter == obj.iterList(i)
                    iterBool = 1;
                end
            end
        end       
        
        function somLearn(obj,totalIter)                    
            iter = 0;
            while (iter < totalIter)
                
                    iter = iter + 1; % Every training data point is an iteration.
                    currentInput = obj.trainInputs(:,randi(size(obj.trainInputs,2)));
                    obj.updateWeights(currentInput);
                                   
                    % Shrink sigma and learning rate with time.
                    obj.sigma = (obj.sigma-1.5) * (1- 0.00001) +1.5;
                    obj.learningRate= obj.learningRate * (1-0.00001);                                                                    
            end             
        end      
        
        % High level function for training the som on a
        % given training data set.
        function train(obj)                   
            iter = 0;
            
            while(iter<obj.maxIter)       
                figure(1)
                plot(1,1,'o','MarkerSize',1);
                obj.plotMappingSOMGrid(iter);
                
                if obj.inList(iter) == 1
                  %  pause;
                    set(gcf,'color','w');       
                    export_fig([obj.trainingInfoPath 'som_train_' int2str(iter) '.eps'],1);
                end
                
                obj.somLearn(obj.reportingInterval);
                iter = iter + obj.reportingInterval;
            end
        end
        
    end 
end

