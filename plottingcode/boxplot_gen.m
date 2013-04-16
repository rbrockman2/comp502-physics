% This is code for creating the boxplots and general average values over
% the eight derived physics variables. 

%function boxplot_gen

datapath = '../inputdata/';

signal_train = load([datapath 'signal_train.mat']);
noise_train = load([datapath 'noise_train.mat']);

% Now I just need to take the data and put it into matrix form, instead of
% having it in the cell form as before. 
Xsig = cell2mat(struct2cell(signal_train));
Xnoi = cell2mat(struct2cell(noise_train));

% Transposing for convention
Xsig = Xsig';
Xnoi = Xnoi';

% Now we need to scale these values. 
% initializing:
Xsig_sc = zeros(size(Xsig));
Xnoi_sc = zeros(size(Xnoi));
for i = 1:8
    Xsig_sc(i,:) = Xsig(i,:)/max(Xsig(i,:));
    Xnoi_sc(i,:) = Xnoi(i,:)/max(Xnoi(i,:));
end

% Now it is time to generate vectors of the average values. 

Xsig_avg = zeros(8,1);
Xnoi_avg = zeros(8,1);

for i = 1:8
    Xsig_avg(i) = mean(Xsig_sc(i,:));
    Xnoi_avg(i) = mean(Xnoi_sc(i,:));
end

% blue for signal, red for noise


plot(1:8,Xsig_avg,'-bs','linewidth',2)
hold on

plot(1:8,Xnoi_avg,'-rs','linewidth',2)
set(gca,'XTickLabel',{' '})
boxplot(Xsig_sc','whisker',25,'colors','b','notch','off')
set(gca,'XTickLabel',{' '})
boxplot(Xnoi_sc','whisker',25,'colors','r','notch','off')
set(gca,'XTickLabel',{' '})
hold off


title('Averages, Maxima, and Minima for the Eight Derived Features', ...
    'interpreter','latex','fontsize',18)
ylabel('Parameter values scaled between 0 and 1',...
    'interpreter','latex','fontsize',16)
xlabel('Derived physics parameters','interpreter','latex','fontsize',16)
legend('Signal Event','Noise Event')












