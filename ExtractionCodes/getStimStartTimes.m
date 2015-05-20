function [stimStartTimesFromZero,stimStartPosFromZero] = getStimStartTimes(dataLog,ainp,threshold,saveFlag)

%% Initialise
[~,folderName]=getFolderDetails(dataLog);
folderExtract = fullfile(folderName,'extractedData');
folderLFP = fullfile(folderName,'segmentedData','LFP');

%% Load data and timeVals

load(fullfile(folderExtract,'goodStimNums.mat'));
load(fullfile(folderLFP,'lfpInfo.mat'));
if saveFlag
    load(fullfile(folderLFP,['unalligned' upper(ainp(1)) ainp(2:end)]));
else
    load(fullfile(folderLFP,ainp));
end

%% Calculate time shift
blZero = (find(timeVals == 0));
blPeriod = (blZero-100):blZero;
    for i=1:size(analogData,1)
        Data=abs((analogData(i,:)));
        blData=Data(blPeriod);
        meanData = mean(blData,2)';
        stdData  = std(blData,[],2)';
        blValue = (meanData + threshold*stdData);
        try
            stimStartPosFromZero(i) = (find(Data(blZero:end)>blValue,1))-1;
        catch err
            stimStartPosFromZero(i) = 0;
        end
        stimStart = blZero+stimStartPosFromZero(i);
        stimStartTimesFromZero(i)=timeVals(stimStart);
    end

%% Display statistics
disp(['Set threshold: ' num2str(threshold)]);
disp(['mean start time from zero: ' num2str((mean(stimStartTimesFromZero))*1000) ' ms']);
disp(['std of start times from zero: ' num2str((std(stimStartTimesFromZero))*1000) ' ms']);
%% Reallign
unallignedGoodStimTimes = goodStimTimes;
goodStimTimes = unallignedGoodStimTimes + stimStartTimesFromZero;

%% Save
if saveFlag
    save(fullfile(folderExtract,'goodStimNums.mat'),'goodStimNums','goodStimTimes');
    save(fullfile(folderExtract,'unallignedgoodStimNums.mat'),'goodStimNums','unallignedGoodStimTimes');
end
end