function [ ] = grayscaleSquaresPlot( matrix, figureNum )
% greyscaleSquaresPlot.m  
%
%   Creates a 2-D plot of squares centered on the indexes of the
%   matrix.  Each square is given an greyscale value corresponding to the
%   matrix value scaled by the maximum value for that particular matrix.
%
%   Inputs:
%
%       matrix:  unscaled intensity value
%       figureNum:  MATLAB figure to use
%
%   All matrix values must be non-negative.
%   Essentially a wrapper for colorSquaresPlot.
%


colorSquaresPlot(matrix,matrix,matrix,figureNum);

colorbar;
%   Color bar will range from zero to the maximum matrix value.
caxis([0 max(max(matrix))]);

set(gcf,'color','w');
colormap('gray');
end

