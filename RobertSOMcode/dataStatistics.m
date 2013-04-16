

for i = 1:size(signal_train,2)
    %for i = 1:1
    figure(i)
    hist(signal_train(:,i),10);
    
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r','EdgeColor','w')
    hold on;
    hist(noise_train(:,i),10);
    h = findobj(gca,'Type','patch');
    set(h,'facealpha',0.75);
    hold off;
end

figure(20);

% Ask Sergei.

% Scale me!
% Add standard deviations! See overlap!
% SOM weight plots
for i=1:8
    sigMean(i) = mean(signal_train(:,i));
    noiseMean(i) = mean(noise_train(:,i));   
end 
clf;
hold on;
plot(sigMean,'-r');
plot(noiseMean,'-b');
hold off;
