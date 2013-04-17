function del = FeedBackward(W,y,fyDes,TF,bias)
%FEEDBACKWARD Summary of this function goes here
%   Detailed explanation goes here

del = cell(length(W),1);

dertmp = feval(TF.funDerName,y{end},TF.params);
deltmp = (fyDes-y{end}).*(dertmp);
del{end} = zeros(size(deltmp));
del{end} = deltmp;

for i=(length(y)-1):-1:1
    dertmp = feval(TF.funDerName,y{i},TF.params);
    if bias == 1
        deltmp = (W{i+1}(:,2:end)'*del{i+1}).*(dertmp);
    elseif bias == 0
        deltmp = (W{i+1}'*del{i+1}).*(dertmp);
    end
    
    del{i} = zeros(size(deltmp));
    del{i} = deltmp;
end

end

