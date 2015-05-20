function saveEyeDataInDegGAV(monkeyName,expDate,protocolName,folderSourceString,gridType,timePeriodMS,FsEye,maxStimPos)

dataLog{1,2} = monkeyName;
dataLog{2,2} = gridType;
dataLog{3,2} = expDate;
dataLog{4,2} = protocolName;

[~,folderName]=getFolderDetails(dataLog);
folderExtract = (fullfile(folderName,'extractedData'));

clear eyeData 
load(fullfile(folderExtract,'EyeData.mat'));

clear goodStimNums
load(fullfile(folderExtract,'goodStimNums.mat'));

if exist([folderExtract 'validStimAfterTarget.mat'],'file')
    load(fullfile(folderExtract,'validStimAfterTarget.mat'));
    disp(['Removing ' num2str(length(validStimuliAfterTarget)) ' stimuli from goodStimNums']);
    goodStimNums(validStimuliAfterTarget)=[];
end

clear stimResults
load(fullfile(folderExtract,'stimResults.mat'));

goodStimPos = stimResults.stimPosition(goodStimNums);

% all stimPostions greater than 1
useTheseStims = find(goodStimPos>1);

[eyeDataDegX,eyeDataDegY] = convertEyeDataToDeg(eyeData(useTheseStims),1);
folderSave = fullfile(folderName,'segmentedData','eyeData');
makeDirectory(folderSave);
save(fullfile(folderSave,'eyeDataDeg.mat'),'eyeDataDegX','eyeDataDegY');

% lengthEyeSignal = size(eyeDataDegX,2);
% eyeSpeedX = [eyeDataDegX(:,2:lengthEyeSignal)-eyeDataDegX(:,1:lengthEyeSignal-1) zeros(size(eyeDataDegX,1),1)];
% eyeSpeedY = [eyeDataDegY(:,2:lengthEyeSignal)-eyeDataDegY(:,1:lengthEyeSignal-1) zeros(size(eyeDataDegY,1),1)];
% save([folderSave 'eyeSpeed.mat'],'eyeSpeedX','eyeSpeedY');

% More data saved for GRF protocol
[eyeXAllPos,eyeYAllPos,xs] = getEyeDataStimPosGAV(dataLog,folderSourceString,timePeriodMS,FsEye,maxStimPos);
save(fullfile(folderSave,'EyeDataStimPos.mat'),'eyeXAllPos','eyeYAllPos','xs','timePeriodMS');
end
function [eyeXAllPos,eyeYAllPos,xs,timePeriodMS] = getEyeDataStimPosGAV(dataLog,folderSourceString,timePeriodMS,Fs,maxStimPos)

intervalTimeMS=1000/Fs;

% Get Lablib data
datFileName = fullfile(folderSourceString,'data','rawData',[dataLog{1,2} dataLog{3,2}],[dataLog{1,2} dataLog{3,2} dataLog{4,2} '.dat']);
header = readLLFile('i',datFileName);

for j=1:maxStimPos                                  
    eyeXAllPos{j}=[];
    eyeYAllPos{j}=[];
    xs{j}=[];
end
    
for i=1:header.numberOfTrials
    trial = readLLFile('t',i);
    
    % Work on only Correct Trials, which are not instruction, catch or
    % uncertified trials
    if (trial.trialEnd.data == 0) && (trial.trial.data.instructTrial==0) && ...
            (trial.trialCertify.data==0) && (trial.trial.data.catchTrial==0)
        
        % get eye data
        eX=trial.eyeXData.data';
        eY=trial.eyeYData.data';
        cal=trial.eyeCalibrationData.data.cal;
        numUsefulStim = trial.trial.data.targetIndex; % these are the useful stimuli, excluding target
        
        stimOnTimes = trial.stimulusOnTime.timeMS;
        gaborPos = find([trial.stimDesc.data.gaborIndex]==1);
        if numUsefulStim>1
            for j=2:numUsefulStim
                stp = ceil((stimOnTimes(gaborPos(j)) - trial.trialStart.timeMS)/intervalTimeMS);
                
                eXshort = eX( stp + ((j-1)*timePeriodMS(1))/intervalTimeMS : stp + timePeriodMS(2)/intervalTimeMS);
                eYshort = eY( stp + ((j-1)*timePeriodMS(1))/intervalTimeMS : stp + timePeriodMS(2)/intervalTimeMS);
                
                eyeX = cal.m11*eXshort + cal.m21 * eYshort + cal.tX;
                eyeY = cal.m12*eXshort + cal.m22 * eYshort + cal.tY;
                
                eyeXAllPos{j} = cat(1,eyeXAllPos{j},eyeX);
                eyeYAllPos{j} = cat(1,eyeYAllPos{j},eyeY);
                
                if isempty(xs{j})
                    xs{j} = 0:intervalTimeMS:timePeriodMS(2) - (j-1)*timePeriodMS(1);
                end
            end
        end
    end
end
end