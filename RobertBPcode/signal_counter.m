% Robert Brockman II, Justin DeVito, and Ricky LeVan
% COMP 502 Spring 2013
% Final Project
%
% signal_counter.m - Calculate the number of true positives in a data set.
%
function [hitNum, output] = signal_counter(mp,dataInput,bias)
hitNum =0;

output = zeros(size(dataInput,1),2);
for i=1:size(dataInput,1)
    output(i,:) = mp.mpOutput(dataInput(i,:)');
    if output(i,1) > output(i,2) + bias
        hitNum = hitNum +1;
    end
end

end
