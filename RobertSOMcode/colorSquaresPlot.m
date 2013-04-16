function [  ] = colorSquaresPlot( redMatrix, greenMatrix, blueMatrix, figureNum)
% colorSquaresPlot.m  
%
%   Creates a 2-D plot of squares centered on the indexes of the
%   matrices, which must all have the same dimensions.  Each square is 
%   given an RGB value, with color vales corresponding to the matrix value
%   scaled by the maximum value for that particular matrix.
%
%   Inputs:
%
%       redMatrix:  unscaled red intensity value
%       greenMatrix:  unscaled red intensity value
%       blueMatrix:  unscaled red intensity value
%       figureNum:  MATLAB figure to use
%
%   All matrix values must be non-negative.

figure(figureNum);
plot(1,1,'o'); % dummy dot to initialize graph
hold on;

redMaxVal = max(max(redMatrix));
if redMaxVal == 0
    redMaxVal = 1;
end

greenMaxVal = max(max(greenMatrix));
if greenMaxVal == 0
    greenMaxVal = 1;
end

blueMaxVal = max(max(blueMatrix));
if blueMaxVal == 0
    blueMaxVal = 1;
end


for i=1:size(redMatrix,1)
    for j=1:size(redMatrix,2)
        redVal = redMatrix(i,j)/redMaxVal;
        greenVal = greenMatrix(i,j)/greenMaxVal;
        blueVal = blueMatrix(i,j)/blueMaxVal;
        
        rectangle('Position',[i-0.5,j-0.5,1,1],...
            'Curvature',[0,0],...
            'FaceColor',[redVal greenVal blueVal]);

        
    end
end
hold off;
axis([0.5 size(redMatrix,1)+0.5 0.5 size(redMatrix,2)+0.5]);
xlabel('Coordinate 1');
ylabel('Coordinate 2');
set(gcf,'color','w');

end

