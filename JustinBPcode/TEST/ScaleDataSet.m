function yS = ScaleDataSet(y,SDS)
%SCALEDATASET Summary of this function goes here
%   Detailed explanation goes here


yS = (y - repmat(SDS.ycenter,[1, size(y,2)]))./repmat(SDS.scf,[1, size(y,2)]);
%yS = (y - SDS.ycenter)./SDS.scf;
end

