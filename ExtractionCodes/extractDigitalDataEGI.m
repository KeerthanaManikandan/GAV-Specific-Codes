% This function is used to extract the digital data from EGI files
% extracted in .mat format by Net Station Tools.

% Each data file is characterized by four parameters - subjectName, expDate,
% protocolName and gridType.

% We assume that the raw data is initially stored in
% folderSourceString\data\rawData\{subjectName}{expDate}\

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In order to make sure that digital codes from different recording systems
% are similar, we convert the digital codes to the Blackrock format.

% The GAV Protocol automatically extends the length of two digital -
% trialStart and trialEnd, to 2 ms, making sure that they are captured
% properly as long as the sampling frequency exceeds 1 kHz. Further, the
% codes corresponding to reward are also recorded. The program therefore
% does the following:

% 1. Finds out which codes correspond to reward on, TrialStart and TrialEnd
% 2. Puts reward off codes in the Digital Data based on reward on codes 
% 3. Changes these codes to the format used in Blackrock
% 4. Ignores the other digital codes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [digitalTimeStamps,digitalEvents]=extractDigitalDataEGI(subjectName,expDate,protocolName,folderSourceString,gridType,deltaLimitMS)

% We only consider codes that are separated by at least deltaLimit ms to make sure
% that none of the codes are during the transition period.
if ~exist('deltaLimitMS','var');    deltaLimitMS = 1;                   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataLog{1,2} = subjectName;
dataLog{2,2} = gridType;
dataLog{3,2} = expDate;
dataLog{4,2} = protocolName;
dataLog{14,2} = folderSourceString;

[~,folderName]=getFolderDetails(dataLog);

fileName = [subjectName expDate protocolName '.mat'];
% folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName);
makeDirectory(folderName);
folderIn = fullfile(folderSourceString,'data','rawData',[subjectName expDate]);
folderExtract = fullfile(folderName,'extractedData');
makeDirectory(folderExtract);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load(fullfile(folderIn,fileName));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% Digital Codes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[digitalTimeStamps,digitalEvents] = getStimulusEvents(evt_255_DINs);
disp(['Digital events: ' num2str(length(digitalEvents))]);
[digitalTimeStamps,digitalEvents] = removeBadCodes(digitalTimeStamps/EEGSamplingRate,digitalEvents,deltaLimitMS);

rewardOnPos = find(rem(digitalEvents,2)==0);
rewardOffCode = digitalEvents(rewardOnPos)+1;

for rewardCount = 1:length(rewardOnPos)
    digitalEvents = insertNumberIntoVector(digitalEvents,rewardOffCode(rewardCount),rewardOnPos(rewardCount)+rewardCount);
    digitalTimeStamps = insertNumberIntoVector(digitalTimeStamps,rewardOffCode(rewardCount),rewardOnPos(rewardCount)+rewardCount);
end

end

function [eventTimes,eventVals] = getStimulusEvents(allEvents)

for count=1:size(allEvents,2)  
    eventTimes(count) = allEvents{2, count};
%     eventVals(count)   = str2double(allEvents{1, count}(4:end)); %#ok<*AGROW>
    eventVals(count)   = str2double(allEvents{1, count}(regexp(allEvents{1, count},'\d'):end)) + 2^15; %#ok<*AGROW>
end

% MSB is set to negative. Change to positive
x = find(eventVals<0);
eventVals(x) = 2^16 + eventVals(x);

end
function [digitalTimeStamps,digitalEvents] = removeBadCodes(digitalTimeStamps,digitalEvents,deltaLimitMS)
deltaLimit = deltaLimitMS/1000; 
dt = diff(digitalTimeStamps);
badDTPos = find(dt<=deltaLimit);

if ~isempty(badDTPos)
    disp([num2str(length(badDTPos)) ' of ' num2str(length(digitalTimeStamps)) ' (' num2str(100*length(badDTPos)/length(digitalTimeStamps),2) '%) are separated by less than ' num2str(1000*deltaLimit) ' ms and will be discarded']);
    digitalTimeStamps(badDTPos)=[];
    digitalEvents(badDTPos)=[];
end
end

function newVector = insertNumberIntoVector(Vector,Number,Index)
    if size(Vector,1)>1
        Vector = Vector';
    end
    newVector = [Vector(1:Index-1),Number,Vector(Index:end)] ;
end