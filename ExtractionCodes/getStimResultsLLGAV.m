function LL = getStimResultsLLGAV(subjectName,gridType,expDate,protocolName,folderSourceString,SaveLLDataFlag,EyePosBehDataFlag,eyeRangeMS,Fs)

dataLog{1,2} = subjectName;
dataLog{2,2} = gridType;
dataLog{3,2} = expDate;
dataLog{4,2} = protocolName;
dataLog{14,2} = folderSourceString;

if ~exist('SaveLLDataFlag','var'); SaveLLDataFlag=1; end;
if ~exist('EyePosBehDataFlag','var'); EyePosBehDataFlag=0; end;

% Get Lablib data
datFileName = fullfile(dataLog{14,2},'data','rawData',[dataLog{1,2} dataLog{3,2}],[dataLog{1,2} dataLog{3,2} dataLog{4,2} '.dat']);
header = readLLFile('i',datFileName);

% stimType (MD)
kNullStim = 0; kValidStim = 1; kTargetStim = 2; kFrontPaddingStim = 3; 
kBackPaddingStim = 4; kPlaidStim = 5; kAudStim = 6; kVisAudStim = 7;

% Stimulus properties
numTrials = header.numberOfTrials;

allStimulusIndex = [];
allStimulusOnTimes = [];
gaborIndex = [];
stimType = [];
azimuthDeg = [];
elevationDeg = [];
sigmaDeg = [];
radiusDeg = [];
spatialFreqCPD =[];
orientationDeg = [];
contrastPC = [];
temporalFreqHz = [];

% Added by MD 16-03-2015 for GAV protocol
AuditoryAzimuth=[];
AuditoryElevation=[];
AuditoryProtType=[];
RippleFrequency=[];
RipplePhase=[];
AuditoryContrast=[];
RippleVelocity=[];

eotCode=[];
myEotCode=[];
endTime=[];
startTime=[];

instructTrial=[];
catchTrial=[];
trialCertify=[];

hW = waitbar(0,['trial ' num2str(1) ' of ' num2str(numTrials)]); % Added by MD 18-04-2015

for i=1:numTrials
    waitbar(i/numTrials,hW,['Analysing trial ' num2str(i) ' of ' num2str(numTrials)])
    clear trials
    trials = readLLFile('t',i);
    
    if isfield(trials,'trial')
        instructTrial = [instructTrial [trials.trial.data.instructTrial]];
        catchTrial    = [catchTrial [trials.trial.data.catchTrial]];
    end
    
    if isfield(trials,'trialCertify')
        trialCertify = [trialCertify [trials.trialCertify.data]];
    end
    
    if isfield(trials,'trialEnd')
        eotCode = [eotCode [trials.trialEnd.data]];
        endTime = [endTime [trials.trialEnd.timeMS]];
    end
    
    if isfield(trials,'myTrialEnd')
        myEotCode = [myEotCode [trials.myTrialEnd.data]];
    end
    
    if isfield(trials,'trialStart')
        startTime = [startTime [trials.trialStart.timeMS]];
    end
    
    if isfield(trials,'stimulusOn')
        allStimulusIndex = [allStimulusIndex [trials.stimulusOn.data]'];
    end
    
    if isfield(trials,'stimulusOnTime')
        allStimulusOnTimes = [allStimulusOnTimes [trials.stimulusOnTime.timeMS]'];
    end
    
    if isfield(trials,'stimDesc')        
        gaborIndex = [gaborIndex [trials.stimDesc.data.gaborIndex]];        
        stimType = [stimType [trials.stimDesc.data.stimType]];
        
        % Visual Stimuli
            azimuthDeg = [azimuthDeg [trials.stimDesc.data.azimuthDeg]];
            elevationDeg = [elevationDeg [trials.stimDesc.data.elevationDeg]];
            sigmaDeg = [sigmaDeg [trials.stimDesc.data.sigmaDeg]];
            if isfield(trials.stimDesc.data,'radiusDeg')
                radiusExists=1;
                radiusDeg = [radiusDeg [trials.stimDesc.data.radiusDeg]];
            else
                radiusExists=0;
            end
            spatialFreqCPD = [spatialFreqCPD [trials.stimDesc.data.spatialFreqCPD]];
            orientationDeg = [orientationDeg [trials.stimDesc.data.directionDeg]];
            contrastPC = [contrastPC [trials.stimDesc.data.contrastPC]];
            temporalFreqHz = [temporalFreqHz [trials.stimDesc.data.temporalFreqHz]];

        % Added by MD 16-03-2015 for GAV protocol
            AuditoryAzimuth=[AuditoryAzimuth [trials.stimDesc.data.azimuthDeg]];
            AuditoryElevation=[AuditoryElevation [trials.stimDesc.data.elevationDeg]];
            AuditoryProtType=[AuditoryProtType [trials.stimDesc.data.sigmaDeg]];
            RippleFrequency=[RippleFrequency [trials.stimDesc.data.spatialFreqCPD]];
            RipplePhase=[RipplePhase [trials.stimDesc.data.directionDeg]];
            AuditoryContrast=[AuditoryContrast [trials.stimDesc.data.contrastPC]];
            RippleVelocity=[RippleVelocity [trials.stimDesc.data.temporalFreqHz]];
        
    end
end
close(hW);

% Sort stim properties by stimType
numGabors = length(unique(gaborIndex));
for i=1:numGabors
    gaborIndexFromStimulusOn{i} = find(allStimulusIndex==i-1);
    gaborIndexFromStimDesc{i} = find(gaborIndex==i-1);
end

if isequal(gaborIndexFromStimDesc,gaborIndexFromStimulusOn)
    for i=1:numGabors
        LL.(['time' num2str(i-1)]) = allStimulusOnTimes(gaborIndexFromStimulusOn{i});
        LL.(['stimType' num2str(i-1)]) = stimType(gaborIndexFromStimulusOn{i});
        
        if ( ~isequal(LL.(['stimType' num2str(i-1)]),kNullStim*(ones(1,length(LL.(['stimType' num2str(i-1)])))))...
                && ~isequal(LL.(['stimType' num2str(i-1)]),kAudStim*(ones(1,length(LL.(['stimType' num2str(i-1)])))))) % MD
            LL.(['azimuthDeg' num2str(i-1)]) = azimuthDeg(gaborIndexFromStimulusOn{i});
            LL.(['elevationDeg' num2str(i-1)]) = elevationDeg(gaborIndexFromStimulusOn{i});
            LL.(['sigmaDeg' num2str(i-1)]) = sigmaDeg(gaborIndexFromStimulusOn{i});
            if radiusExists
                LL.(['radiusDeg' num2str(i-1)]) = radiusDeg(gaborIndexFromStimulusOn{i});
            end
            LL.(['spatialFreqCPD' num2str(i-1)]) = spatialFreqCPD(gaborIndexFromStimulusOn{i});
            LL.(['orientationDeg' num2str(i-1)]) = orientationDeg(gaborIndexFromStimulusOn{i});
            LL.(['contrastPC' num2str(i-1)]) = contrastPC(gaborIndexFromStimulusOn{i});
            LL.(['temporalFreqHz' num2str(i-1)]) = temporalFreqHz(gaborIndexFromStimulusOn{i});
        end
        
        % Added by MD 16-03-2015 for GAV protocol
         if ( isequal(LL.(['stimType' num2str(i-1)]),kAudStim*(ones(1,length(LL.(['stimType' num2str(i-1)])))))...
                || isequal(LL.(['stimType' num2str(i-1)]),kVisAudStim*(ones(1,length(LL.(['stimType' num2str(i-1)]))))))
            LL.(['AuditoryAzimuth' num2str(i-1)]) = AuditoryAzimuth(gaborIndexFromStimulusOn{i});%+ones(1,size(AuditoryAzimuth(gaborIndexFromStimulusOn{i}),2));
            LL.(['AuditoryElevation' num2str(i-1)])=AuditoryElevation(gaborIndexFromStimulusOn{i});
            LL.(['AuditoryProtType' num2str(i-1)])=AuditoryAzimuth(gaborIndexFromStimulusOn{i});
            LL.(['RippleFrequency' num2str(i-1)])=RippleFrequency(gaborIndexFromStimulusOn{i});%+ones(1,size(RippleFrequency(gaborIndexFromStimulusOn{i}),2));
            LL.(['RipplePhase' num2str(i-1)])=RipplePhase(gaborIndexFromStimulusOn{i});%+ones(1,size(RipplePhase(gaborIndexFromStimulusOn{i}),2));
            LL.(['AuditoryContrast' num2str(i-1)])=floor(AuditoryContrast(gaborIndexFromStimulusOn{i}));
            LL.(['RippleVelocity' num2str(i-1)])=RippleVelocity(gaborIndexFromStimulusOn{i});%+ones(1,size(RippleVelocity(gaborIndexFromStimulusOn{i}),2));            
        end
    end
else
    error('Gabor indices from stimuluOn and stimDesc do not match!!');
end

LL.eotCode = eotCode;
LL.myEotCode = myEotCode;
LL.startTime = startTime/1000; % in seconds
LL.endTime = endTime/1000; % in seconds
LL.instructTrial = instructTrial;
LL.catchTrial = catchTrial;
LL.trialCertify = trialCertify;

% Save
[~,folderName]=getFolderDetails(dataLog);
folderExtract = fullfile(folderName,'extractedData');

if SaveLLDataFlag
    save(fullfile(folderExtract,'LL.mat'),'LL');
end

% Get Eye Position And Behavioral Data
if EyePosBehDataFlag
    [allTrials,goodTrials,stimData,eyeData,eyeRangeMS] = getEyePositionAndBehavioralDataGAV(header,eyeRangeMS,Fs);
    save(fullfile(folderExtract,'BehaviorData.mat'),'allTrials','goodTrials','stimData');
    save(fullfile(folderExtract,'EyeData.mat'),'eyeData','eyeRangeMS');
end

end

function [allTrials,goodTrials,stimData,eyeData,eyeRangeMS] = getEyePositionAndBehavioralDataGAV(header,eyeRangeMS,Fs) % [MD]: This needs to be tested for GAV protocol
    % Getting eye position and behavioural data
    if ~exist('eyeRangeMS','var')           eyeRangeMS = [-480 800];        end    % ms
    if ~exist('Fs','var')                   Fs = 200;                       end % Eye position sampled at 200 Hz.

    eyeRangePos = eyeRangeMS*Fs/1000;

    % Stimulus properties
    numTrials = header.numberOfTrials;
    stimNumber=1;
    correctIndex=1;
    trialEndIndex=1;

    for i=1:numTrials
        disp(i);
        clear trials
        trials = readLLFile('t',i);

        if isfield(trials,'trialEnd')
            allTrials.trialEnded(i) = 1;
            allTrials.catchTrials(trialEndIndex) = trials.trial.data.catchTrial;
            allTrials.instructTrials(trialEndIndex) = trials.trial.data.instructTrial;
            allTrials.trialCertify(trialEndIndex) = trials.trialCertify.data;
            allTrials.targetPosAllTrials(trialEndIndex) = trials.trial.data.targetIndex+1;
            allTrials.eotCodes(trialEndIndex) = trials.trialEnd.data;

            allTrials.fixWindowSize(trialEndIndex) = trials.fixWindowData.data.windowDeg.size.width;
            allTrials.respWindowSize(trialEndIndex) = trials.responseWindowData.data.windowDeg.size.width;
            allTrials.certifiedNonInstruction(trialEndIndex) = (allTrials.instructTrials(trialEndIndex)==0)*(allTrials.trialCertify(trialEndIndex)==0);

            if (allTrials.eotCodes(trialEndIndex)==0) &&  (allTrials.certifiedNonInstruction(trialEndIndex)==1)
                    %&& (allTrials.catchTrials(trialEndIndex)==0) % Work on only Correct Trials, which are not instruction or uncertified trials. Include catch trials

                isCatchTrial = (allTrials.catchTrials(trialEndIndex)==1);

                % Get Eye Data
                eyeX = trials.eyeXData.data;
                eyeY = trials.eyeYData.data;
                % eyeStartTime = trials.eyeXData.timeMS(1);  % This is wrong.
                % The eye data is synchronized with trialStartTime.
                eyeStartTime = trials.trialStart.timeMS;
                eyeAllTimes = eyeStartTime + (0:(length(eyeX)-1))*(1000/Fs);

                stimOnTimes  = [trials.stimulusOnTime.timeMS];
                numStimuli = allTrials.targetPosAllTrials(trialEndIndex); %=length(stimOnTimes)/3;

                goodTrials.targetPos(correctIndex) = numStimuli;
                goodTrials.targetTime(correctIndex) = stimOnTimes(end);
                goodTrials.fixateMS(correctIndex) = trials.fixate.timeMS;
                goodTrials.fixonMS(correctIndex) = trials.fixOn.timeMS;
                goodTrials.stimOnTimes{correctIndex} = stimOnTimes;

                % Find position of Gabor1
                gaborPos = find([trials.stimDesc.data.gaborIndex]==1); % could be 4 gabors for GRF protocol

                if isCatchTrial
                    stimEndIndex = numStimuli;    % Take the last stimulus because it is still a valid stimulus
                else
                    stimEndIndex = numStimuli-1;  % Don't take the last one because it is the target
                end

                if stimEndIndex>0  % At least one stimulus
                    for j=1:stimEndIndex
                        stimTime = stimOnTimes(gaborPos(j));
                        stp=find(eyeAllTimes>=stimTime,1);

                        stimData.stimOnsetTimeFromFixate(stimNumber) = stimTime-trials.fixate.timeMS;
                        stimData.stimPos(stimNumber) = j;

                        startingPos = max(1,stp+eyeRangePos(1)); % First stimulus may not have sufficient baseline           
                        endingPos   = min(stp+eyeRangePos(2)-1,length(eyeX)); % Last stimulus may not have suffiecient length, e.g. for a catch trial

                        eyeData(stimNumber).eyePosDataX = eyeX(startingPos:endingPos);
                        eyeData(stimNumber).eyePosDataY = eyeY(startingPos:endingPos);

                        eyeData(stimNumber).eyeCal = trials.eyeCalibrationData.data.cal;
                        stimNumber=stimNumber+1;
                    end
                end
                correctIndex=correctIndex+1;
            end
            trialEndIndex=trialEndIndex+1;
        end
    end
end