function DelW = ChangeWeightDelta(DelW,DelWOld,gamma,alpha,del,x,y,bias)
%CHANGEWEIGHTDELTAS Summary of this function goes here
%   Detailed explanation goes here

if bias == 1
    onesvec = ones(1, size(x,2));
    if DelW == 0
        DelW = cell(length(y),1);
        DelWtmp = gamma.*del{1}*[onesvec; x]';
        DelW{1} = zeros(size(DelWtmp));
        DelW{1} = DelWtmp;
        for i=2:length(del)
            onesvec = ones(1, size(y{i-1},2));
            DelWtmp = gamma.*del{i}*[onesvec; y{i-1}]';
            DelW{i} = zeros(size(DelWtmp));
            DelW{i} = DelWtmp + alpha*DelWOld{i};
        end
    else
        DelWtmp = gamma.*del{1}*[onesvec; x]';
        DelW{1} = DelW{1} + DelWtmp;
        for i=2:length(del)
            onesvec = ones(1, size(y{i-1},2));
            DelWtmp = gamma.*del{i}*[onesvec; y{i-1}]';
            DelW{i} = zeros(size(DelWtmp));
            DelW{i} = DelW{i} + DelWtmp;
        end
    end
elseif bias == 0
    if DelW == 0
        DelW = cell(length(y),1);
        DelWtmp = gamma.*del{1}*x';
        DelW{1} = zeros(size(DelWtmp));
        DelW{1} = DelWtmp;
        for i=2:length(del)
            DelWtmp = gamma.*del{i}*y{i-1}';
            DelW{i} = zeros(size(DelWtmp));
            DelW{i} = DelWtmp + alpha*DelWOld{i};
        end
    else
        DelWtmp = gamma.*del{1}*x';
        DelW{1} = DelW{1} + DelWtmp;
        for i=2:length(del)
            DelWtmp = gamma.*del{i}*y{i-1}';
            DelW{i} = zeros(size(DelWtmp));
            DelW{i} = DelW{i} + DelWtmp;
        end
    end
    
end
end

