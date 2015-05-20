% Bad stimList. This is specific for each monkey and grid type because of
% differences in the good electrodes and thresholds.

% Murty V P S Dinavahi 19-09-2014
% Modified 20-05-2015

if ~exist('checkTheseElectrodesForBadTrials','var')
    occipitalElec = [61 62 63 29 30 31];
    temporalElec = [12 17 51 23 55 16 27 22];
    centralElec = [19 53 20 25];
    checkTheseElectrodesForBadTrials = centralElec; 
    thresholdBadTrials=6; 
    saveBadTrialsFlag = 1;
    showTrialsBadTrials = 0;
end

% thresholdBadTrials=6; 
% saveBadTrialsFlag = 1;
% showTrialsBadTrials = 0;

if  (~exist('dataLog','var'))
    uiopen;
end

Lims = str2num(cell2mat(inputdlg('Checking for bad trials. Please input [minLimit maxLimit]')));
if isempty(Lims); Lims = [-100 100]; end

[allBadTrials, badTrials, nameElec] = findBadTrialsEEG_GAV(dataLog,checkTheseElectrodesForBadTrials,thresholdBadTrials,Lims(2),Lims(1),saveBadTrialsFlag,showTrialsBadTrials);