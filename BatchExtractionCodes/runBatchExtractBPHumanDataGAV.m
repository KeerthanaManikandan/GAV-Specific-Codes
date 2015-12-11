% This code defines all the standardised default parameters for extraction
% of EEG Data. This is to facilitate consistency across all extractions.
% All the defaults for all the devices in use should be defined here.
%
% Murty V P S Dinavahi 30-11-2015

function runBatchExtractBPHumanDataGAV(extractTheseIndices)

extractProp.electrodesToStore = []; % If left empty, all electrodes are stored
extractProp.ignoreTargetStimFlag=1; % For GaborRFMap stimuli, set this to 1 if the program is run in the fixation mode. 
extractProp.FsEye = 200;
extractProp.frameRate = 100;
extractProp.reallignElec = [];
extractProp.reallignFlag = 0; 
extractProp.badTrialsFlag = 1;
extractProp.checkTheseElectrodesForBadTrialsActiCap64 = [61 62 63 29 30 31];
extractProp.checkTheseElectrodesForBadTrialsBrainCap64 = [45 63 46 9 64 10];
extractProp.thresholdBadTrials=6; 
extractProp.saveBadTrialsFlag = 1; 
extractProp.showTrialsBadTrials = 0;
extractProp.notchLineNoise = 0;
extractProp.reRefFlag = 0; 
extractProp.refElec = [];
extractProp.LJData = 1;
extractProp.auxElectrodesToStore = 1:6;
extractProp.FsLJ = 2500;
extractProp.Lims = [-100 100];
extractProp.FsBR = 2000;
extractProp.FsBP = 2500;

timeStartFromBaseLineList(1) = -0.55; deltaTList(1) = 1.024; % in seconds
timeStartFromBaseLineList(2) = -1.148; deltaTList(2) = 2.048;
timeStartFromBaseLineList(3) = -1.5; deltaTList(3) = 4.096;
timeStartFromBaseLineList(4) = -1; deltaTList(4) = 3;
timeStartFromBaseLineList(5) = -1; deltaTList(5) = 3.2768; % For BP data with Fs = 2500: Compatible with matching pursuit
timeStartFromBaseLineList(6) = -0.5; deltaTList(6) = 2.048; % For BR data with Fs = 2000: Compatible with matching pursuit

subjectName = 'Human'; gridType = 'EEG'; folderSourceString = 'D:'; 
[expProp.subjectNames,expProp.expDates,expProp.protocolNames,expProp.stimTypes,expProp.deviceNames,expProp.capLayout] = eval(['allProtocols' upper(subjectName(1)) subjectName(2:end) gridType]);
clear subjectName

batchExtractBPHumanDataGAV(extractTheseIndices,extractProp,expProp,timeStartFromBaseLineList,deltaTList,gridType,folderSourceString)
end