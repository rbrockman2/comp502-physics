% testing function. Let's test things. 

noise_target = [0;0.8];
signal_target = [0.8;0];

midpoint = (noise_target+signal_target)/2;

% The fair line is the line through this midpoint that is equidistant from
% noise_target and signal_target at all points. 
% fair_line_angle is the angle of this line, w.r.t. the x-axis. 


c = noise_target - signal_target;
phi = atan(abs(c(2))/abs(c(1)));
% angle in radians
fair_line_angle = pi - phi;

% Now we put 

% counter-clockwise rotation matrix
CCW_rotation = @(theta) [cos(-theta) -sin(-theta); sin(-theta) ...
    cos(-theta)];

% Y in natural coordinates
Ynat = (CCW_rotation(fair_line_angle))*(Y - midpoint);