% This is code for creating the boxplots and general average values over
% the eight derived physics variables. 

%function boxplot_gen

datapath = '../inputdata/';

signal_train = load([datapath 'signal_train.mat']);
noise_train = load([datapath 'noise_train.mat']);

% Now I just need to take the data and put it into matrix form, instead of
% having it in the cell form as before. 
Xsig = cell2mat(struct2cell(signal_train)); Xnoi = cell2mat(struct2cell(noise_train));
Xsig = Xsig'; Xnoi = Xnoi';

% Now we need to scale these values. 
% initializing:
Xsig_sc = zeros(size(Xsig)); Xnoi_sc = zeros(size(Xnoi));
for i = 1:8
    Xsig_sc(i,:) = Xsig(i,:)/max(Xsig(i,:));
    Xnoi_sc(i,:) = Xnoi(i,:)/max(Xnoi(i,:));
end

% Now it is time to generate vectors of the average values. 
Xsig_avg = zeros(8,1); Xnoi_avg = zeros(8,1);

for i = 1:8
    Xsig_avg(i) = mean(Xsig_sc(i,:));
    Xnoi_avg(i) = mean(Xnoi_sc(i,:));
end

% blue for signal, red for noise
plot(1:8,Xsig_avg,'-bs','linewidth',2); hold on
set(gca,'XTick',[])
plot(1:8,Xnoi_avg,'-rs','linewidth',2)
set(gca,'XTick',[])

xaxlabels1 = {'','','','','','','',''};
xaxlabels2 = {'m3a','m3b','m2a','m2b','angb','angj1','angj2','mspt'};
boxplot(Xsig_sc','whisker',25,'colors','b','labels',xaxlabels1)
boxplot(Xnoi_sc','whisker',25,'colors','r','labels',xaxlabels2)

title('Statistics for the Derived Features', ...
    'interpreter','latex','fontsize',18)
ylabel('Parameter Values (Scaling: [0,1] )',...
    'interpreter','latex','fontsize',16)
xlabel('Derived Parameters','interpreter','latex','fontsize',16)
legend('Signal Event','Noise Event')

set(gcf,'color','w')