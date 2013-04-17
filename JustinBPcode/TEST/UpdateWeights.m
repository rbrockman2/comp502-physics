function [W,DelW,DelWOld] = UpdateWeights(W,DelW)
for i=1:length(W);
    W{i} = W{i} + DelW{i};
end
DelWOld = DelW;
DelW = 0;

end