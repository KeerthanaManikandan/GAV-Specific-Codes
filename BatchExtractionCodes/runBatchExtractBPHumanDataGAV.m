
function runBatchExtractBPHumanDataGAV(extractTheseIndices)

extractProp.electrodesToStore = []; % If left empty, all electrodes are stored
extractProp.ignoreTargetStimFlag=1; % For GaborRFMap stimuli, set this to 1 if the program is run in the fixation mode. 
extractProp.FsEye = 200;
extractProp.frameRate = 100;
extractProp.elecTypeVal = 1; % For actiCap64
extractProp.gridLayout = 2; % For actiCap64
extractProp.reallignElec = [];
extractProp.reallignFlag = 0; 
extractProp.badTrialsFlag = 1;
extractProp.checkTheseElectrodesForBadTrials = [61 62 63 29 30 31];
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

timeStartFromBaseLineList(1) = -0.55; deltaTList(1) = 1.024; % in seconds
timeStartFromBaseLineList(2) = -1.148; deltaTList(2) = 2.048;
timeStartFromBaseLineList(3) = -1.5; deltaTList(3) = 4.096;
timeStartFromBaseLineList(4) = -1; deltaTList(4) = 3;
timeStartFromBaseLineList(5) = -0.524; deltaTList(5) = 2.048;

subjectName = 'Human'; gridType = 'EEG'; folderSourceString = 'D:';
[expProp.subjectNames,expProp.expDates,expProp.protocolNames,expProp.stimTypes,expProp.deviceNames] = eval(['allProtocols' upper(subjectName(1)) subjectName(2:end) gridType]);
clear subjectName

batchExtractBPHumanDataGAV(extractTheseIndices,extractProp,expProp,timeStartFromBaseLineList,deltaTList)
end