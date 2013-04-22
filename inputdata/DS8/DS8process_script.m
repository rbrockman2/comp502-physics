% Robert Brockman II, Justin DeVito, and Ricky LeVan
% COMP 502 Spring 2013
% Final Project
%
% DS8process_script.m
%
M55 = load('Table_100t400_8TeV-55.txt');
M52 = load('Table_100t400_8TeV-52.txt');
MN = load('Table_ttjALL.txt');

setsizeN = floor(size(MN,1)/3);

MS = [M55; M52];

setsizeS = floor(size(MS,1)/3);

noise_train_8 = MN(1:setsizeN,1:end-1);
noise_cv_8 = MN(1+setsizeN:2*setsizeN,1:end-1);
noise_test_8 = MN(1+2*setsizeN:3*setsizeN,1:end-1);

signal_train_8 = MS(1:setsizeS,1:end-1);
signal_cv_8 = MS(1+setsizeS:2*setsizeS,1:end-1);
signal_test_8 = MS(1+2*setsizeS:3*setsizeS,1:end-1);

save('noise_train_8.mat','noise_train_8')
save('noise_cv_8.mat','noise_cv_8')
save('noise_test_8.mat','noise_test_8')
save('signal_train_8.mat','signal_train_8')
save('signal_cv_8.mat','signal_cv_8')
save('signal_test_8.mat','signal_test_8')

dlmwrite('noise_train_8.csv',MN(1:setsizeN,1:end-1),',')
dlmwrite('noise_cv_8.csv',MN(1+setsizeN:2*setsizeN,1:end-1),',')
dlmwrite('noise_test_8.csv',MN(1+2*setsizeN:3*setsizeN,1:end-1),',')

dlmwrite('signal_train_8.csv',MS(1:setsizeS,1:end-1),',')
dlmwrite('signal_cv_8.csv',MS(1+setsizeS:2*setsizeS,1:end-1),',')
dlmwrite('signal_test_8.csv',MS(1+2*setsizeS:3*setsizeS,1:end-1),',')
