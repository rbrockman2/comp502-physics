% Robert Brockman II, Justin DeVito, and Ricky LeVan
% COMP 502 Spring 2013
% Final Project
%
% layer.m - Class definition for one layer of a multilayer perceptron.
%
classdef layer < handle % Objects are passed by reference.  
    properties
        % Weights used to transform the biased input to the layer
        % into the NET for this layer.  Dimension is output rows 
        % by biased input cols
        weightMatrix 
        
        % Accumulated change in the weights over the course of an epoch.
        % Reset to zero after being added to the weights at the end of
        % an epoch.
        weightMatrixChange 
        
        % Last epoch's weight matrix change.  Multiplied by momentum to be
        % used as the starting point for the current epoch's weight matrix
        % change.
        oldWeightMatrixChange
        
        % Sensitivity of the output error to changes in the weights for
        % the PEs in this layer.
        delta
        
        % The input vector including a bias input of 1 in the first
        % element.
        biasedInput

        % The weighted sum of the inputs for each PE.
        net
        
        % The outputs for each PE.  (No bias node included.)
        output
    end
    
    methods
        % Constructor initializes weights.
        function obj=layer(numOutputs,numInputs)
            layerInit(obj,numOutputs,numInputs);
        end
       
        % Initialize the weight matrix as well as the matrix for keeping 
        % track of changes in weights during an epoch to be applied at the
        % end of the epoch.
        function layerInit(obj,numOutputs,numInputs)
            % TODO make function. 
            for n=1:numOutputs 
                % Small initial values are from Colin Fyfe 4.5.3
                % Extra column is bias vector
               
                %obj.weightMatrix(n,:) = (rand(1,numInputs+1) -0.5) * 4.8 / (numInputs+1);
                
                % Small initial values are (-0.1,+0.1)
                obj.weightMatrix(n,:) = (rand(1,numInputs+1) -0.5)/5;
            end
             
            disp('Initial Weights:')
            disp(obj.weightMatrix)
            
            obj.weightMatrixChange = zeros(size(obj.weightMatrix));
            obj.oldWeightMatrixChange = zeros(size(obj.weightMatrix));
        end

        % Compute an output of a layer from the unbiased input.
        function [output] = layerOutput(obj,input)
            obj.biasedInput = [1;input];% Add bias input
            
            % Compute weighted sum of inputs.
            obj.net = obj.weightMatrix*obj.biasedInput; 
           
            % Apply transfer function f
            obj.output = tanh(obj.net);
            
            % return output
            output=obj.output;
        end
        
        % Compute delta and compute weight changes for this layer.
        % Return the 'diff' to be used for computing the delta for the 
        % previous layer.
        %
        % Requires the diff from the next layer and the learning rate.
        function [newDiff] = layerDelta(obj,diff,learningRate)
            % Compute derivative of transfer function at the output.
            % tanh(NET) derivative is 1-output^2
            fPrime = obj.output.*obj.output.*-1+1;
            
            % Delta is the diff from the previous layer 
            % (weight matrix transposed * prior delta with bias element dropped)
            % multiplied elementwise by the unbiased output of this layer.
            obj.delta = fPrime .* diff;
           
            % Compute desired change in weights.
            obj.weightMatrixChange = obj.weightMatrixChange + learningRate * obj.delta*obj.biasedInput';
            %obj.biasVectorChange = obj.biasVectorChange + learningRate * obj.delta;
            
            % diff is weight matrix transposed * delta.
            % Will get multiplied by previous layer's output (without bias)
            %  to generate the diff for the previous layer.
            newDiff = obj.weightMatrix' * obj.delta;
            newDiff = newDiff(2:end); % Remove bias entry.
        end
        
        % Update this layer's weights the accumulated weight change.
        % Performed at the end of an epoch.
        function layerWeightUpdate(obj,momentum)
            obj.weightMatrix = obj.weightMatrix + obj.weightMatrixChange;
          %  obj.weightMatrixChange = zeros(size(obj.weightMatrix));
            obj.weightMatrixChange = momentum * obj.weightMatrixChange;
        end
    end 
end


