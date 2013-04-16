function [  ] = exemplarSquaresPlot( redMatrix, greenMatrix, blueMatrix, kohonenSom,figureNum)
% exemplarSquaresPlot.m  
%
%   Creates a 2-D plot of squares centered on the indexes of the
%   matrices, which must all have the same dimensions.  Each square is 
%   given an RGB value, with color vales corresponding to the matrix value
%   scaled by the maximum value for that particular matrix.  The normalized
%   exemplars for SOM cells are plotted in the corresponding squares. 
%
%   Inputs:
%
%       redMatrix:  unscaled red intensity value
%       greenMatrix:  unscaled red intensity value
%       blueMatrix:  unscaled red intensity value
%       kohonenSom:  trained SOM
%       figureNum:  MATLAB figure to use
%
%   All matrix values must be non-negative.

% Plot colored squares
colorSquaresPlot( redMatrix, greenMatrix, blueMatrix,figureNum)

% Scale SOM weights to 0-1, normalized for each input parameter.
scaledWeightMatrix = zeros(kohonenSom.height,kohonenSom.width,kohonenSom.numInputs);
for k = 1:kohonenSom.numInputs
    maxVal = max(max(kohonenSom.weightMatrix(:,:,k)));
    minVal = min(min(kohonenSom.weightMatrix(:,:,k)));
    scaledWeightMatrix(:,:,k) = (kohonenSom.weightMatrix(:,:,k) - minVal)./(maxVal-minVal);
end

% Plot a little graph of each normalized exemplar in each SOM square.
hold on;
for i=1:size(redMatrix,1)
    for j=1:size(redMatrix,2)
        exemplar = zeros(kohonenSom.numInputs,1);
        for k=1:kohonenSom.numInputs
            exemplar(k) = scaledWeightMatrix(i,j,k);
        end
        exemplarVarAxis = ((1:kohonenSom.numInputs)-0.5)/kohonenSom.numInputs;       
        plot(exemplarVarAxis+i-0.5,exemplar/max(exemplar)+j-0.5);    
    end
end
hold off;

end

