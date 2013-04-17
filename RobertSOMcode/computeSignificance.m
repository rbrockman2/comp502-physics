function [ significance, finalSignalCount, finalNoiseCount ] = computeSignificance(finalSignalNum, finalNoiseNum )

% Cross sections of signal and background in fb for m_stop = 400 GeV and
% m_neutralino = 100 GeV.
initialSignalCrossSection = 337; 
initialNoiseCrossSection = 2E5+0.24E5;

% Significance based on 50 fb^-1 of collisions.
luminosity = 50;

% Training, test, and crossvalidation sets are 1/3 of entire data set.
initialSignalNum=(7293+11362) / 3;
initialNoiseNum=29746 /3;


finalSignalCrossSection =  finalSignalNum / initialSignalNum * initialSignalCrossSection;
finalNoiseCrossSection = finalNoiseNum / initialNoiseNum * initialNoiseCrossSection;

disp(finalSignalCrossSection);
disp(finalNoiseCrossSection);

finalSignalCount = finalSignalCrossSection * luminosity;
finalNoiseCount = finalNoiseCrossSection * luminosity;


significance = finalSignalCount / finalNoiseCount^0.5;

% Goal:  get significance greater than 0.20⋅50 / ((0.26 +0.28 )⋅50) ^ 0.5 =
% 1.925

end

