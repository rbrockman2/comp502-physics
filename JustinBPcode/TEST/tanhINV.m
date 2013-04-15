function x = tanhINV(y,params)
%TANHINV Summary of this function goes here
%   Detailed explanation goes here

x = atanh(y*(1/params.a))*(1/params.b);

end

