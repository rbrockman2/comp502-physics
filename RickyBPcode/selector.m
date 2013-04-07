% function to select desired random elements to feed to the network
% training system

function [x,d] = selector(X,D)

% equivalently, we could have used size(D) for size(X) below
[~,samples] = size(X);

pick = ceil(rand*samples);

x = X(:,pick); d = D(:,pick);

return

