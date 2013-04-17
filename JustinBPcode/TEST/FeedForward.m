function [y,yend] = FeedForward(W,x,bias,TF)
%FEEDFORWARD Summary of this function goes here
%   Detailed explanation goes here

lW = length(W);
y = cell(lW,1);

for i=1:lW
    if bias==1
        if i==1
            onesvec = ones(1,size(x,2));
            NETi = W{i}*[onesvec; x];
        else
            onesvec = ones(1,size(y{i-1},2));
            NETi = W{i}*[onesvec; y{i-1}];
        end
    else
        if i==1
            NETi = W{i}*x;
        else
            NETi = W{i}*y{i-1};
        end
    end
    
    if i==lW
        yend = feval(TF.funName,NETi,TF.params);
        y{i} = yend;
    else
        y{i} = zeros(size(NETi));
        y{i} = feval(TF.funName,NETi,TF.params);
    end
end

end

