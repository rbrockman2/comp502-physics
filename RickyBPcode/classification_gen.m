% classification_gen. 

% Look to attached picture files for a visual representation of the
% concepts here described. 

% ***DESCRIPTION***
% This function performs a variable classification scheme that can favor
% signal or noise classifications to an arbitrary degree. It does this by
% imagining skew parabolas tangent to a fair line dividing the signal and
% noise target values. It then performs an isometry of the plane (thus 
% preserving the Euclidean metric) by displacement then rotation, which
% puts the output vectors into a natural basis.
% In this basis, the parabolas are naturalized such that they are functions
% and are of the form a*x^2 + 0*x + 0*c. Then a simple inequality relation
% will perform the classification. 

% ***INPUTS***
% Y: a 2*n matrix of the actual outputs of our neural network. 
% D: a 2*n matrix of the desired outputs of our neural network.
% signal_target: desired signal value, a column of D
% noise_target: desired noise value, another column of D
% signal_favor_param: a real number describing the extent to which the
% classifier will favor signal over noise classifications. 

% Notes on inputs:
% signal_target and noise_target can technically be derived from D,
% but the order of columns in D may vary. So for the most generality and
% conceptual simplicity, classification_gen will take these as arguments
% distinct from D.
% In the plane, noise_target must be above and to the left of
% signal_target. This agrees with our convention of putting the signal
% target on the x-axis and the noise target on the y-axis.
% signal_favor_param indeed is the extent to which signal events are
% favored in classification, but somewhat confusingly (though out of
% necessity) this is what leads to the parabola bending *toward* the
% noise_target value.

% ***OUTPUTS*** 
% [tp,fp,tn,fn]: the number of true positives, false positives, true
% negatives, and false negatives. Together, these will and must sum to n,
% the number of events in consideration.

function [tp,fp,tn,fn] = classification_gen(Y,D,signal_target,...
    noise_target,signal_favor_param)

% We first gather and process the information we need for the natural basis
% transform. 
midpoint = (noise_target+signal_target)/2;

% The fair line is the line through this midpoint that is equidistant from
% noise_target and signal_target at all points. 
% fair_line_angle is the angle of this line, w.r.t. the x-axis. 
c = noise_target - signal_target;
phi = atan(abs(c(2))/abs(c(1)));
fair_line_angle = pi - phi;

% With fair_line_angle and midpoint in hand, we construct the natural
% transform. 

% counter-clockwise rotation matrix
CCW_rotation = @(theta) [cos(-theta) -sin(-theta); sin(-theta) ...
    cos(-theta)];

% I also need to make midpoint into a matrix, so I can properly subtract
% it.
[~,n] = size(Y);

% just googled this trick. repmat does what you'd expect
midpoint_matrix = repmat(midpoint,1,n);

% Y in natural coordinates
Ynat = (CCW_rotation(fair_line_angle))*(Y - midpoint_matrix);
% parabola function in the natural coordinates
parabola_fun = @(x,a) a*x.^2;

% Now we initialize our counts of the true and false positives and
% negatives. 
tp = 0; fp = 0; tn = 0; fn = 0;


% this is the classification loop. It also draws on the *actual* value of
% the event in question to further classify outcomes as tp,fp,tn,fn. 
for i = 1:n
    % seeing if the point is above the parabola in the plane. parabola_fun
    % takes Y(1,i) because that is the x-coordinate in question. 
    if Ynat(2,i) > parabola_fun(Ynat(1,i),signal_favor_param)
        % note this is less and less likely as the parameter increases
        % class_val short for "classification value"
        class_val = 'noise';
    else
        class_val = 'signal';
    end
    % Now we look to see what the actual value is
    if D(:,i) == signal_target
        actual_val = 'signal';
    else
        actual_val = 'noise';
    end
    % And now we add to tp,fp,tn,fn straightforwardly
    if strcmp(class_val,'signal') && strcmp(actual_val,'signal')
        tp = tp + 1;
    elseif strcmp(class_val,'signal') && strcmp(actual_val,'noise')
        fp = fp + 1;
    elseif strcmp(class_val,'noise') && strcmp(actual_val,'noise')
        tn = tn + 1;
    elseif strcmp(class_val,'noise') && strcmp(actual_val,'signal')
        fn = fn + 1;
    end
end

return


    
    
    
    
























