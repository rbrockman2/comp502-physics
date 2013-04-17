classdef stdScaler < handle % Objects are passed by reference. 
    
    properties
        shift;
        multiplier;     
    end
    
    methods
        
        function obj=stdScaler(dataPoints)
                     
            obj.shift = zeros(size(dataPoints,2),1);
            obj.multiplier = zeros(size(dataPoints,2),1);
           
            for j = 1:size(dataPoints,2)
                obj.shift(j) = - mean(dataPoints(:,j));
                obj.multiplier(j) = 1/std(dataPoints(:,j));          
            end

        end
        
        function [scaledDataPoints] = scaleForward(obj, dataPoints)
            scaledDataPoints = zeros(size(dataPoints));
            
            for j = 1:size(dataPoints,2)                
                scaledDataPoints(:,j) = (dataPoints(:,j) +obj.shift(j)) * obj.multiplier(j);            
            end        
        end   
        
        
        function [dataPoints] = scaleBackward(obj,dataPoints)
            for j = 1:size(dataPoints,2)
                dataPoints(:,j) = (dataPoints(:,j)/obj.multiplier(j)) -obj.shift(j);
            end
            
        end
    end    
end

