% class_driver. 
% This will drive the classification_gen function, setting the proper
% inputs and performing post-processing on the outputs, including plotting
% of a figure comparing true and false positives.

% **For this purpose, we will only have the network try to classify the 
% data used in the training. This driver is largely hardwired, although the
% main function it calls, classification_gen, is clear and elegant in its
% focus.

% Gathering all the inputs needed for classification_gen

signal_target = [0.8;0]; noise_target = [0;0.8];
% bringing in the saved weight cell. We need the weights so we can 
% construct the output values by running the inputs through the network
outputdatapath = '../RickyBPcode/';
W_struct = load([outputdatapath 'decent_weight_output']);
intermed = struct2cell(W_struct);
W = intermed{1};

% Now I need to bring in the input values, so I can put them through the
% network and get the output values.

inputdatapath = '../inputdata/';
signal_train = load([inputdatapath 'signal_train.mat']);
noise_train = load([inputdatapath 'noise_train.mat']);
signal_train = cell2mat(struct2cell(signal_train));
noise_train = cell2mat(struct2cell(noise_train));

% getting rid of some of the noise pieces!
noise_train = noise_train(1:2595,:);

Xraw = cat(1,signal_train,noise_train);
Xraw = Xraw';
% Normalization of the derived variables to be between 0 and 1. 
[p,q] = size(Xraw);
X = zeros(p,q);
for i = 1:8
    X(i,:) = Xraw(i,:)/max(Xraw(i,:));
end
[~,n] = size(X);
Y = zeros(2,n);
for i = 1:n
    intermed = signal_gen(X(:,i),W);
    Y(:,i) = intermed{length(intermed)}; 
end
    
% Now I need to bring in the desired values. This part is very hardcoded to
% the particular case. To do otherwise would require a sort of abstraction
% in file-manipulation that I have too little practice with and too little
% time to attempt right now. More copy-pasta from physics_driver:

signal_tag = [0.8;0]; noise_tag = [0; 0.8];
% I need to consider how many of the entries in X are signal vs. noise 
[signum,~] = size(signal_train);
D = zeros(2,q);
for i = 1:signum
    D(:,i) = signal_tag;
end
for i = signum+1:q
    D(:,i) = noise_tag;
end

% ***Now just for science, I'll hardwire a particular value for
% signal_favor_param. Say, 0. And we'll see if good results come out. If
% they do, then I can generalize to a loop over many different values for
% signal_favor_param.
signal_favor_param = 1;

[tp,fp,tn,fn] = classification_gen(Y,D,signal_target,...
    noise_target,signal_favor_param);



% ****HERE IS YOUR NEXT TASK****
% Plot some of the Y values in blue for signal, then others in red for the
% noise. Hold on, and draw black lines for the x and y axes. Finally, draw
% big black squares (or something similar) at [0.8; 0] and [0; 0.8]. This
% will be a good graph in general. Plus, it will allow you to get a feel
% for the data, and thus where the bugs might be. 

figure(1)
plot(Y(1,1:signum),Y(2,1:signum),'b*','markersize',2)
hold on
plot(Y(1,signum+1:end),Y(2,signum+1:end),'r*','markersize',2)
plot(linspace(-1,1,200),linspace(-1,1,200)*0,'k')
line([0;0],[-0.4;1],'Color','k')
axis on


% I'm a terrible copy-pasta. Punish me, baby!

midpoint = (noise_target+signal_target)/2;

% The fair line is the line through this midpoint that is equidistant from
% noise_target and signal_target at all points. 
% fair_line_angle is the angle of this line, w.r.t. the x-axis. 
c = noise_target - signal_target;
phi = atan(abs(c(2))/abs(c(1)));
fair_line_angle = pi  - phi;

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
Ysilly = Y - midpoint_matrix;



figure(2)
plot(Ysilly(1,1:signum),Ysilly(2,1:signum),'b*','markersize',2)
hold on
plot(Ysilly(1,signum+1:end),Ysilly(2,signum+1:end),'r*','markersize',2)
plot(linspace(-1,1,200),linspace(-1,1,200)*0,'k')
line([0;0],[-0.4;1],'Color','k')
axis on






figure(3)
plot(Ynat(1,1:signum),Ynat(2,1:signum),'b*','markersize',2)
hold on
plot(Ynat(1,signum+1:end),Ynat(2,signum+1:end),'r*','markersize',2)
plot(linspace(-1,1,200),linspace(-1,1,200)*0,'k')
line([0;0],[-0.4;1],'Color','k')
axis on



 











