% Robert Brockman II, Justin DeVito, and Ricky LeVan
% COMP 502 Spring 2013
% Final Project
%
% multiPerp.m - Class definition for a multilayer perceptron.
%
classdef multiPerp < handle % Objects are passed by reference.  
    properties
        layers % Array of layers.
        report % Report object.
        
        % Training Parameters
        maxEpochs = 1000; % maximum number of epochs
        initialLearningRate = 0.001;
        momentum = 0;
        
        reportingInterval = 10; % number of epochs per reporting interval
        epochSize = 1; % number of training samples per epoch        
        
        trainInput; % training set inputs
        trainOutput; % training set outputs
        trainOffset=0; % position in training set
        trainOrder; % Randomly ordered training set
        
        testInput; % test set inputs
        testOutput; % test set outputs
        
        classifierTargets; % prototype output values for each class
        
        errorThreshold = 0.05; % Training stops once the error reaches this level.
        
        
        signalTrainInput;
        noiseTrainInput;
        signalCVInput;
        noiseCVInput;
        bias = 1.1;
        
        
        debug = 0;
    end
    
    methods
        % Constructor initializes the layers of the perceptron.
        % Requires a column vector of the number of PEs in each layer,
        % starting with the input buffer layer.
        function obj=multiPerp(layerWidths)          
            % Add layers to the perceptron with the proper number of PEs.
            for i=1:size(layerWidths,1)-1
                obj.layers = [obj.layers;layer(layerWidths(i+1),layerWidths(i))];
            end
            
        end
       
        % Compute the final output of the multilayer perceptron from the
        % inputs using forward propagation.
        function [output] = mpOutput(obj,input)
            temp = input;
            for i=1:size(obj.layers,1)
                temp = obj.layers(i).layerOutput(temp);
            end
            output = temp;
        end
        
        
        function backProp(obj,target,input)
            output = mpOutput(obj,input);
            diff = target-output;
           
            % Calculate diffs and weight changes.
            for i=size(obj.layers,1):-1:1
                diff = obj.layers(i).layerDelta(diff,obj.initialLearningRate);
            end        
        end
        
        % Update all of the weight matrices at the end of an epoch by 
        % applying the accumulated weight changes. Momentum is used to
        % carry over some of the accumulated weight changes to the next
        % epoch.
        function updateWeights(obj)
            for i=1:size(obj.layers,1)
                obj.layers(i).layerWeightUpdate(obj.momentum);
            end
        end
        
        % Compute RMSE.
        function [rmsError] = computeRmsError(obj,outputSet, inputSet)
            squaredErrorAccum = zeros(size(outputSet,2),1);
                
            for i=1:size(outputSet,1)

                output = mpOutput(obj,inputSet(i,:)');
                target = outputSet(i,:)';
                
                squaredErrorAccum = squaredErrorAccum + (target-output).*(target-output);
            end
            if obj.debug == 1
                disp(squaredErrorAccum);
            end
            
            % Add up all RMSE associated with each output.
           rmsError = norm((squaredErrorAccum/size(outputSet,1)).^0.5,1);
            
        end
        
        %TODO DocumentMe
        % Compute classification error.
        function [acc] = computeClassificationAccuracy(obj,targetOutput, inputSet)           
            sampleNumber = size(targetOutput,1);
            hits = 0;
            
            actualOutput = zeros(size(targetOutput,1),size(targetOutput,2));
            correctClass = zeros(size(targetOutput,1),1);
            closestClass = zeros(size(targetOutput,1),1);
            
            for i=1:size(targetOutput,1)             
               
                correctClass(i) = 1;
                correctClassDistance = Inf;
                for k = 1:size(obj.classifierTargets,1);
                    outputPrototypeDistance = norm(targetOutput(i,:)-obj.classifierTargets(k,:));
                    
                    if outputPrototypeDistance < correctClassDistance; 
                        correctClassDistance = outputPrototypeDistance;
                        correctClass(i) = k;
                    end
                end
                
                actualOutput(i,:) = mpOutput(obj,inputSet(i,:)');
                closestClass(i) = 1;
                closestClassDistance = Inf;
                for k = 1:size(obj.classifierTargets,1);
                    outputDistance = norm(actualOutput(i,:)-obj.classifierTargets(k,:));
                                       
                    if outputDistance < closestClassDistance; 
                        closestClassDistance = outputDistance;
                        closestClass(i) = k;
                    end
                end
                
                if closestClass(i) == correctClass(i)
                    hits = hits +1;
                end
               
            end      
           acc = hits/sampleNumber;
        end
        
        
        % High level function for training the multilayer perceptron on a
        % given training data set, including generating a report object
        % containing a record of the speed of training.
        function train(obj)        
            % Use a new report object.  Preallocate records for speed.
            obj.report = annReport(obj.maxEpochs,obj.reportingInterval,obj.epochSize);
            
            epoch = 0;
            
            while(epoch<obj.maxEpochs)
                
                obj.bpLearn(obj.reportingInterval);
                epoch = epoch + obj.reportingInterval;
                
                % Adds to the training statistics after each reporting
                % interval.
                error = obj.bpRecall();
                
                % Apply stopping criterion.
                if error < obj.errorThreshold                           
                     return
                end
                                         
            end
        end
        
        % Performs a number of training epochs equal to totalEpochs. The
        % training data set is used, with the sample order randomized again
        % after every time the entire data set has been used.
        function bpLearn(obj,totalEpochs)
            epoch = 0;
            
            while (epoch < totalEpochs)
                epoch = epoch +1;
                iter = 0;
                
                % Process one epoch.
                while (iter < obj.epochSize)
                    iter = iter + 1; % Every training data point is an iteration.
                    obj.initialLearningRate = obj.initialLearningRate * (1 - 0.0001);
                    
                    % Check for training set wraparound.
                    obj.trainOffset = mod(obj.trainOffset,size(obj.trainOutput,1));
                    if obj.trainOffset == 0
                        % randomize training set order
                        obj.trainOrder=randperm(size(obj.trainOutput,1));
                    end
                    
                    obj.trainOffset = obj.trainOffset +1;
                    
                    % Train samples in a random order.
                    obj.backProp(obj.trainOutput(obj.trainOrder(obj.trainOffset),:)', ...
                        obj.trainInput(obj.trainOrder(obj.trainOffset),:)');                               
                end  
                % Update weights at the end of an epoch.
                obj.updateWeights();          
            end           
        end
        
        % Computes the errors on the training and test data sets with the
        % weights frozen.  Errors are stored as a record in the report
        % object.
        function [error] = bpRecall(obj)
            trainError = obj.computeRmsError(obj.trainOutput, obj.trainInput); 
            testError = obj.computeRmsError(obj.testOutput, obj.testInput);                        
           % trainAccuracy = obj.computeClassificationAccuracy(obj.trainOutput, obj.trainInput);                        
           % testAccuracy = obj.computeClassificationAccuracy(obj.testOutput, obj.testInput);
           
            
            tp = signal_counter(obj,obj.signalTrainInput,obj.bias);
            fp = signal_counter(obj,obj.noiseTrainInput,obj.bias);         
            trainAccuracy = computeSignificance(tp,fp);
            disp(fp);
            disp(obj.initialLearningRate);
            
            tp = signal_counter(obj,obj.signalCVInput,obj.bias);
            fp = signal_counter(obj,obj.noiseCVInput,obj.bias);         
            testAccuracy = computeSignificance(tp,fp);
            
            
            obj.report.addRecord(trainError,testError,trainAccuracy,testAccuracy);  
            
            % Training error usable as stopping criterion.
            error = trainError; 
        end
                
    end 
end

