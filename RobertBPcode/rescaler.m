classdef rescaler < handle % Objects are passed by reference. 
    
    properties
        minScaledVal;
        maxScaledVal;
        maxDataVal;
        minDataVal;
        
    end
    
    methods
        
        function obj=rescaler(minScaledVal, maxScaledVal,  dataPoints )
            obj.minScaledVal = minScaledVal;
            obj.maxScaledVal = maxScaledVal;
                      
            obj.maxDataVal = zeros(size(dataPoints,2),1);
           
            for j = 1:size(dataPoints,2)
                obj.maxDataVal(j) = max(dataPoints(:,j));
                obj.minDataVal(j) = min(dataPoints(:,j));          
            end

        end
        
        function [scaledDataPoints] = scaleForward(obj, dataPoints)
            scaledDataPoints = zeros(size(dataPoints));
            
            for j = 1:size(dataPoints,2)
                
                sourceMidpoint = (obj.maxDataVal(j) + obj.minDataVal(j)) / 2;
                sourceRange = obj.maxDataVal(j) - obj.minDataVal(j);
                
                
                % Rescale to (-1, +1)
                scaledDataPoints(:,j) = (dataPoints(:,j) - sourceMidpoint)./(sourceRange/2);
                
                
                targetMidpoint = (obj.minScaledVal+obj.maxScaledVal) / 2;
                targetRange = obj.maxScaledVal - obj.minScaledVal;
                
                scaledDataPoints(:,j) = (scaledDataPoints(:,j) .* (targetRange/2)) + targetMidpoint;
                
                
            end
            
            
            
        end
        
        
    end
    
end

