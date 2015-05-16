% Bad stimList. This is specific for each monkey and grid type because of
% differences in the good electrodes and thresholds.

% Murty V P S Dinavahi 19-09-2014

showElectrodes=[]; 
threshold=6; 

if  (~exist('dataLog','var'))
    uiopen;
    monkeyName = strjoin(dataLog(1,2));
    gridType=strjoin(dataLog(2,2));
    folderSourceString = 'D:\';
    expDate = strjoin(dataLog(3,2));
    protocolName = strjoin(dataLog(4,2));
    checkTheseElectrodes = (cell2mat(dataLog(7,2)));
else
    monkeyName = strjoin(dataLog(1,2));
    gridType=strjoin(dataLog(2,2));
    folderSourceString = 'D:\';
    expDate = strjoin(dataLog(3,2));
    protocolName = strjoin(dataLog(4,2));
    checkTheseElectrodes = (cell2mat(dataLog(7,2)));
end

Lims = str2num(cell2mat(inputdlg('Checking for bad trials. Please input [minLimit maxLimit]')));
if isempty(Lims); Lims = [-100 100]; end

disp([monkeyName expDate protocolName]);
[allBadTrials,badTrials] = findBadTrialsForGAV(dataLog,threshold,Lims(2),showElectrodes,Lims(1));