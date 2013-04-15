function dydx = tanhDER(y,params)
%TANHDER Summary of this function goes here
%   Detailed explanation goes here

% y = f(x) = a*tanh(b*x)

dydx = params.a*params.b-(params.b/params.a)*y.^2;

end

