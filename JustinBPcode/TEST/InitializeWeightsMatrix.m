function [WCell,WGr] = InitializeWeightsMatrix(A,PEVec,alpha,IWMSt)
%INITIALIZEWEIGHTSMATRIX Summary of this function goes here
%   Detailed explanation goes here

F = sum(A,1);
v = alpha./sqrt(F);
WGr = full(single(sprand(A).*repmat(v,[size(A,1) 1])));

if nargin>2
    if length(PEVec)==4
        WGr(end-PEVec(4)+1:end,:) = full(single(sprand(A).*repmat(IWMSt.bias,[PEVec(4) 1])));
    end
end

for i=1:length(PEVec)-1
    WCell{i}=ones(PEVec(i+1),PEVec(i))
end


end

