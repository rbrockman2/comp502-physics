% CreateWeightsMat
%
% Inputs:
% x - one input, or data set of inputs (m-# inputs x n-# samples)
% yt - one output, or data set of outputs (m-# outputs x n-# samples)
% hLayerVec - Row Vector containing #PEs in each hidden layer
% bias - 1 to include bias, 0 for bias off, row vector for more options
% CWM Structure:
%   CWM.mode - 'cell' or 'incgraph' , if 'incgraph' graph will also be
%       generated
%   CWM.alpha - Range for non-bias nodes (over sqrt of node fan-in)
%   CWM.biasRange - Range for the bias nodes
%
% Outputs:
% GS.A - Node Adjacency Matrix
% GS.WG- Weighted Adjacency Matrix
% PEVec - Vector containing number of nodes in each layer
% W - Weighted Adjacency Matrix or Weight Matrices within Cells


function [WC,PEVec,GS] = CreateWeightsMat(dimIn,dimOut,hLayerVec,bias,CWM)
nhL = length(hLayerVec);

if length(bias) > 1
    disp('Fancy bias not yet implemented')
elseif bias == 1
    nBiasEl = (1 + nhL);
    PEVec = [dimIn, hLayerVec, dimOut, nBiasEl];
else
    PEVec = [dimIn, hLayerVec, dimOut];
end

if strcmp(CWM.mode,'incgraph')
    nEl = sum(PEVec);
    amountAlloc = ceil((nEl-dimOut)*(nEl-nBiasEl));
    A = spalloc(nEl,nEl,amountAlloc,'int8'); %zeros(nEl,nEl,'int8');
    
    Ii2 = cumsum(PEVec);
    Ii1 = [1, Ii2(1:end-1)+1];
    for i=1:nhL+1
        A(Ii1(i):Ii2(i),Ii1(i+1):Ii2(i+1))=1;
    end
    
    if bias == 1
        for i=1:nBiasEl
            A((nEl-nBiasEl)+i,Ii1(i+1):Ii2(i+1))=1;
        end
    end
    
    F = sum(A,1);
    v = CWM.alpha./sqrt(F);
    W = full(single(sprand(A).*repmat(v,[size(A,1) 1])));
    
    if nargin>2
        if length(PEVec)==4
            W(end-PEVec(4)+1:end,:) = full(single(sprand(A).*repmat(bias,[PEVec(4) 1])));
        end
    end
    GS.WG = W;
    GS.A = A;
else
    GS = 0;
end


WC = cell(nhL+1,1);
for i=1:nhL+1
    % Fan-In Calculations
    Fip1 = (PEVec(i)+bias);
    
    if bias == 1
    % For Fan-In
    %WC{i}= [((2*(rand([PEVec(i+1) 1])-0.5)).*CWM.biasRange), (2*(rand([PEVec(i+1) PEVec(i)])-0.5)).*CWM.alpha./sqrt(Fip1)];
    
    %For Range -0.1 to 0.1 , Bias Range 1
    %WC{i}= [((2*(rand([PEVec(i+1) 1])-0.5)).*1), (2*(rand([PEVec(i+1) PEVec(i)])-0.5)).*0.1];    
    
    % For Range -0.1 to 0.1 
    WC{i}= [((2*(rand([PEVec(i+1) 1])-0.5)).*1), (2*(rand([PEVec(i+1) PEVec(i)])-0.5)).*0.1];   
    elseif bias ==0
    WC{i}= [(2*(rand([PEVec(i+1) PEVec(i)])-0.5)).*CWM.alpha./sqrt(Fip1)];
        
    end
 
end



end