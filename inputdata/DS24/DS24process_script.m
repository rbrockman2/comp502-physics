M55 = load('55.txt');
M52 = load('52.txt');
MN = load('N.txt');

setsizeN = floor(size(MN,1)/3);

MS = [M55; M52];


setsizeS = floor(size(MS,1)/3);

noise_train_24 = MN(1:setsizeN,1:end-1);
noise_cv_24 = MN(1+setsizeN:2*setsizeN,1:end-1);
noise_test_24 = MN(1+2*setsizeN:3*setsizeN,1:end-1);

signal_train_24 = MS(1:setsizeS,1:end-1);
signal_cv_24 = MS(1+setsizeS:2*setsizeS,1:end-1);
signal_test_24 = MS(1+2*setsizeS:3*setsizeS,1:end-1);

save('noise_train_24.mat','noise_train_24')
save('noise_cv_24.mat','noise_cv_24')
save('noise_test_24.mat','noise_test_24')
save('signal_train_24.mat','signal_train_24')
save('signal_cv_24.mat','signal_cv_24')
save('signal_test_24.mat','signal_test_24')

dlmwrite('noise_train_24.csv',MN(1:setsizeN,1:end-1),',')
dlmwrite('noise_cv_24.csv',MN(1+setsizeN:2*setsizeN,1:end-1),',')
dlmwrite('noise_test_24.csv',MN(1+2*setsizeN:3*setsizeN,1:end-1),',')

dlmwrite('signal_train_24.csv',MS(1:setsizeS,1:end-1),',')
dlmwrite('signal_cv_24.csv',MS(1+setsizeS:2*setsizeS,1:end-1),',')
dlmwrite('signal_test_24.csv',MS(1+2*setsizeS:3*setsizeS,1:end-1),',')