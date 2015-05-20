% We check, for each trial, whether there is a value greater than 
% 1. threshold times the std dev. 
% 2. maxLimit
% If yes, that trial is marked as a bad trial 

% Bad trials are also copied to the cluster

% Modified by MD

function [allBadTrials,badTrials] = findBadTrialsForGAV(dataLog,checkTheseElectrodes,threshold,maxLimit,showElectrodes,minLimit,saveDataFlag) 

% Initialise
[dataLog,folderName] = getFolderDetails(dataLog);
% monkeyName = strjoin(dataLog(1,2));
% gridType=strjoin(dataLog(2,2));
% expDate = strjoin(dataLog(3,2));
% protocolName = strjoin(dataLog(4,2));
if ~exist('checkTheseElectrodes','var')
    checkTheseElectrodes = (cell2mat(dataLog(7,2)));
    disp('Checking bad trials for all electrodes');
else disp(['Checking bad trials for electrodes: ' num2str(checkTheseElectrodes)]);
end

if ~exist('saveDataFlag','var');             saveDataFlag = 1;                          end

% folderName = ['C:\Users\LabComputer6\Documents\MATLAB\Extracted_Data\' gridType '\' monkeyName '\' expDate '\' protocolName '\'];
folderSegment = [folderName 'segmentedData\'];

numElectrodes = length(checkTheseElectrodes);
allBadTrials = cell(1,numElectrodes);

for i=1:numElectrodes
    electrodeNum=checkTheseElectrodes(i);
    
    load([folderSegment 'LFP\elec' num2str(electrodeNum) '.mat']);
    
    numTrials = size(analogData,1); %#ok<*NODEF>
    meanData = mean(analogData,2)';
    stdData  = std(analogData,[],2)';
    maxData  = max(analogData,[],2)';
    minData  = min(analogData,[],2)';
    
    clear tmpBadTrials tmpBadTrials2
    tmpBadTrials = unique([find(maxData > meanData + threshold * stdData) find(minData < meanData - threshold * stdData)]);
    tmpBadTrials2 = unique(find(maxData > maxLimit));
    tmpBadTrials3 = unique(find(minData < minLimit));
    allBadTrials{i} = unique([tmpBadTrials tmpBadTrials2 tmpBadTrials3]);
end

badTrials=allBadTrials{1};
for i=1:numElectrodes
    badTrials=intersect(badTrials,allBadTrials{i}); % in the previous case we took the union
end

disp(['total Trials: ' num2str(numTrials) ', bad trials: ' num2str(badTrials)]);

for i=1:numElectrodes
    if length(allBadTrials{i}) ~= length(badTrials)
        disp(['Bad trials for electrode ' num2str(checkTheseElectrodes(i)) ': ' num2str(length(allBadTrials{i}))]);
    else
        disp(['Bad trials for electrode ' num2str(checkTheseElectrodes(i)) ': all (' num2str(length(badTrials)) ')']);
    end
end

if saveDataFlag
    disp(['Saving ' num2str(length(badTrials)) ' bad trials']);
    save([folderSegment 'badTrials.mat'],'badTrials','checkTheseElectrodes','threshold','maxLimit');
%     save([folderSegmentCluster 'badTrials.mat'],'badTrials','checkTheseElectrodes','threshold','maxLimit');
else
    disp('Bad trials will not be saved..'); %#ok<UNRCH>
end

load([folderSegment 'LFP\lfpInfo.mat']);

lengthShowElectrodes = length(showElectrodes);
if ~isempty(showElectrodes)
    for i=1:lengthShowElectrodes
        
        if lengthShowElectrodes>1
            subplot(lengthShowElectrodes,1,i);
        else
            subplot(2,1,1);
        end
        channelNum = showElectrodes(i);

        clear signal analogData
        load([folderSegment 'LFP\elec' num2str(channelNum) '.mat']);
        
        if numTrials<4000
            plot(timeVals,analogData(setdiff(1:numTrials,badTrials),:),'color','k');
            hold on;
        else
            disp('More than 4000 trials...');
        end
        if ~isempty(badTrials)
            plot(timeVals,analogData(badTrials,:),'color','g');
        end
        title(['electrode ' num2str(channelNum)]);
        axis tight;
        
        if lengthShowElectrodes==1
            subplot(2,1,2);
            plot(timeVals,analogData(setdiff(1:numTrials,badTrials),:),'color','k');
            axis tight;
        end
    end
end
