function y = UnscaleDataSet(yS,SDS)
%UNSCALEDATASET Summary of this function goes here
%   Detailed explanation goes here


% y = yS.*SDS.scf + SDS.ycenter;
y = yS.*repmat(SDS.scf,[1, size(yS,2)]) + repmat(SDS.ycenter,[1, size(yS,2)]);

end

