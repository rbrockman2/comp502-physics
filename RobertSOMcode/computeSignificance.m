function [ significance, finalSignalCount, finalNoiseCount ] = computeSignificance( initialSignalNum, initialNoiseNum, finalSignalNum, finalNoiseNum )

% Cross sections of signal and background in fb 
initialSignalCrossSection = 5.55;
initialNoiseCrossSection = 192;

% Significance based on 50 fb^-1 of collisions.
luminosity = 50;

finalSignalCrossSection =  finalSignalNum / initialSignalNum * initialSignalCrossSection;
finalNoiseCrossSection = finalNoiseNum / initialNoiseNum * initialNoiseCrossSection;

finalSignalCount = finalSignalCrossSection * luminosity;
finalNoiseCount = finalNoiseCrossSection * luminosity;


significance = finalSignalCount / finalNoiseCount^0.5;

end

