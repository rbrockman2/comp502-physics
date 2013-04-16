classdef somFilter
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        kohonenSom;
        gainMatrix;
        minimumGain;
        
        initialSignalCrossSection = 5.55;
        initialNoiseCrossSection = 192;
        
        highGainSOMCellMatrix;
        debug=0;
    end
    
    methods
        
        
        function obj=somFilter(gainMatrix,kohonenSom,minimumGain)
            obj.kohonenSom = kohonenSom;
            obj.gainMatrix = gainMatrix;
            obj.minimumGain = minimumGain;
            
            obj.highGainSOMCellMatrix = zeros(obj.kohonenSom.height,obj.kohonenSom.width);
            for i=1:obj.kohonenSom.height
                for j=1:obj.kohonenSom.width
                    if obj.gainMatrix(i,j) >= obj.minimumGain
                        obj.highGainSOMCellMatrix(i,j) = 1;
                    end;
                end
            end     
            
            if obj.debug == 1
                grayscaleSquaresPlot(obj.highGainSOMCellMatrix,5);
                figure(5);
                colorbar('off');
            end
            
        end
        
        
        function [ filteredEvents ] = filterEvents(obj, rawEvents)         
            filteredEvents = zeros(size(rawEvents,1),size(rawEvents,2));
            
            k=0;
            for l = 1:size(rawEvents,1)
                winningPE = obj.kohonenSom.findWinner(rawEvents(l,:));
                if obj.highGainSOMCellMatrix(winningPE(1),winningPE(2)) == 1
                    k=k+1;
                    % disp(winningPE);
                    filteredEvents(k,:) = rawEvents(l,:);
                end
            end
            filteredEvents = filteredEvents(1:k,:);
            
        end     
    end
    
end





