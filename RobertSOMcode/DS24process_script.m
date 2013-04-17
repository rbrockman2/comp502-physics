M55 = load('55.txt');
M52 = load('52.txt');
MN = load('N.txt');

setsizeN = floor(size(MN,1)/3);

MS = [M55; M52];

setsizeS = floor(size(MS,1)/3);

dlmwrite('noise_train.csv',MN(1:setsizeN),',')
dlmwrite('noise_cv.csv',MN(1+setsizeN:2*setsizeN),',')
dlmwrite('noise_test.csv',MN(1+2*setsizeN:3*setsizeN),',')

dlmwrite('signal_train.csv',MN(1:setsizeS),',')
dlmwrite('signal_cv.csv',MN(1+setsizeS:2*setsizeS),',')
dlmwrite('signal_test.csv',MN(1+2*setsizeS:3*setsizeS),',')