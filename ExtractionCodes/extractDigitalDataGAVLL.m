% This function is used to extract the digital data for the GRF Protocol.

% These are the following modes in which the GaborRFMap protocol has been used so far.

% 1. Target and mapping stimulus 0 are on and are presented synchronously,
% while mapping stimulus 1 is off. Digital codes are sent only for map0 stimulus.

% 2. The task is run in the fixation mode, in which target stimulus is off
% and all trials are catch trials. Digital codes are sent only for map0
% stimulus. The invisible target is assumed to be synchronous with the
% mapping stimulus in this case. 

% This is copied from extractDigitalDataGRF. This reads all the digital
% data from LL file

function [goodStimNums,goodStimTimes,side] = extractDigitalDataGAVLL(folderExtract,ignoreTargetStimFlag,frameRate)

if ~exist('ignoreTargetStimFlag','var');   ignoreTargetStimFlag=1;      end % Default set to 1 by MD
if ~exist('frameRate','var');              frameRate=100;               end

stimResults = readDigitalCodesGAVLL(folderExtract,frameRate); % writes stimResults and trialResults
side = stimResults.side;
[goodStimNums,goodStimTimes] = getGoodStimNumsGAV(folderExtract,ignoreTargetStimFlag,1); % Good stimuli
save(fullfile(folderExtract,'goodStimNums.mat'),'goodStimNums','goodStimTimes');
end

% GRF Specific protocols
function [stimResults,trialResults,trialEvents] = readDigitalCodesGAVLL(folderExtract,frameRate)

if ~exist('frameRate','var');              frameRate=100;               end

% stimType (MD)
kNullStim = 0; kValidStim = 1; kTargetStim = 2; kFrontPaddingStim = 3; 
kBackPaddingStim = 4; kPlaidStim = 5; kAudStim = 6; kVisAudStim = 7;

kForceQuit=7;

% TrialEvents are actually not useful - just keeping for compatibility with
% older programs.

trialEvents{1} = 'TS'; % Trial start
trialEvents{2} = 'TE'; % Trial End

try
    load(fullfile(folderExtract,'digitalEvents.mat'));
    fileFlag = 1;
catch
    disp('digitalEvents.mat file not found.');
    fileFlag = 0;
end

if fileFlag
    allDigitalCodesInDec = [digitalCodeInfo.codeNumber];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the times and values of the events in trialEvents

    for i=1:length(trialEvents)
        pos = find(convertStrCodeToDec(trialEvents{i})==allDigitalCodesInDec);
        if isempty(pos)
            disp(['Code ' trialEvents{i} ' not found!!']);
        else
            trialResults(i).times = [digitalCodeInfo(pos).time]; %#ok<*AGROW>
            trialResults(i).value = [digitalCodeInfo(pos).value];
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load Lablib data structure
load(fullfile(folderExtract,'LL.mat'));

% activeSide = [];
% if sum(LL.stimType1)>0
%     activeSide=[activeSide 0];
% elseif sum(LL.stimType2)>0
%     activeSide=[activeSide 1];
% end
stimResults.side = [];
activeSide = [LL.stimType1(1) LL.stimType2(1)];

%%%%%%%%%%%%%%%%% Get info from LL to construct stimResults %%%%%%%%%%%%%%%
for i=1:length(activeSide) % for and 
    switch activeSide(i) % switch loop added by MD
        
        case kValidStim
            clear validMap;
            validMap = find(LL.(['stimType' num2str(i)])== kValidStim);           
            stimResults.(['azimuth' num2str(i)]) = LL.(['azimuthDeg' num2str(i)])(validMap);
            stimResults.(['elevation' num2str(i)]) = LL.(['elevationDeg' num2str(i)])(validMap);
            stimResults.(['contrast' num2str(i)]) = LL.(['contrastPC' num2str(i)])(validMap);
            stimResults.(['temporalFrequency' num2str(i)]) = LL.(['temporalFreqHz' num2str(i)])(validMap);
%             stimResults.(['sigma' num2str(i)]) = LL.(['sigmaDeg' num2str(i)])(validMap);
            stimResults.(['sigma' num2str(i)]) = LL.(['radiusDeg' num2str(i)])(validMap); % added by MD, 25-08-15 ...
                %this stores radius of stimuli in the sigma field. This is
                %useful for size protocols. The name sigma has been
                %retained for compatibility with a lot of programs written
                %earlier, but this does not represent sigma in actuality.
            stimResults.(['orientation' num2str(i)]) = LL.(['orientationDeg' num2str(i)])(validMap);
            stimResults.(['spatialFrequency' num2str(i)]) = LL.(['spatialFreqCPD' num2str(i)])(validMap);
            stimResults.side = [stimResults.side i-1];
            stimTime.(['gabor' num2str(i-1)]) = (LL.(['time' num2str(i)])(validMap))/1000;
            stimTask.(['gabor' num2str(i-1)]) = LL.(['stimType' num2str(i)])(validMap);
            
        case kPlaidStim
            clear validMap;
            validMap = find(LL.(['stimType' num2str(i)])== kPlaidStim);            
            stimResults.(['azimuth' num2str(i)]) = LL.(['azimuthDeg' num2str(i)])(validMap);
            stimResults.(['elevation' num2str(i)]) = LL.(['elevationDeg' num2str(i)])(validMap);
            stimResults.(['contrast' num2str(i)]) = LL.(['contrastPC' num2str(i)])(validMap);
            stimResults.(['temporalFrequency' num2str(i)]) = LL.(['temporalFreqHz' num2str(i)])(validMap);
%             stimResults.(['sigma' num2str(i)]) = LL.(['sigmaDeg' num2str(i)])(validMap);
            stimResults.(['sigma' num2str(i)]) = LL.(['radiusDeg' num2str(i)])(validMap); % added by MD, 25-08-15...
                %this stores radius of stimuli in the sigma field. This is
                %useful for size protocols. The name sigma has been
                %retained for compatibility with a lot of programs written
                %earlier, but this does not represent sigma in actuality.
            stimResults.(['orientation' num2str(i)]) = LL.(['orientationDeg' num2str(i)])(validMap);
            stimResults.(['spatialFrequency' num2str(i)]) = LL.(['spatialFreqCPD' num2str(i)])(validMap);
            stimResults.side = [stimResults.side i-1];
            stimTime.(['gabor' num2str(i-1)]) = (LL.(['time' num2str(i)])(validMap))/1000;
            stimTask.(['gabor' num2str(i-1)]) = LL.(['stimType' num2str(i)])(validMap);
            
        case kAudStim  
            clear validMap;
            validMap = find(LL.(['stimType' num2str(i)])== kAudStim);
            stimResults.(['auditoryAzimuth' num2str(i)]) = LL.(['AuditoryAzimuth' num2str(i)])(validMap);
            stimResults.(['auditoryElevation' num2str(i)]) = LL.(['AuditoryElevation' num2str(i)])(validMap);
            stimResults.(['rippleFrequency' num2str(i)]) = LL.(['RippleFrequency' num2str(i)])(validMap);
            stimResults.(['ripplePhase' num2str(i)]) = LL.(['RipplePhase' num2str(i)])(validMap);
            stimResults.(['auditoryContrast' num2str(i)]) = LL.(['AuditoryContrast' num2str(i)])(validMap);
            stimResults.(['rippleVelocity' num2str(i)]) = LL.(['RippleVelocity' num2str(i)])(validMap);
            stimResults.side = [stimResults.side 5];
            ASGabor = i;
            stimTime.(['ASgabor' num2str(ASGabor)]) = (LL.(['time' num2str(i)])(validMap))/1000;
            stimTask.(['ASgabor' num2str(ASGabor)]) = LL.(['stimType' num2str(i)])(validMap);
            
        case kVisAudStim
            clear validMap;
            validMap = find(LL.(['stimType' num2str(i)])== kVisAudStim);            
            stimResults.(['azimuth' num2str(i)]) = LL.(['azimuthDeg' num2str(i)])(validMap);
            stimResults.(['elevation' num2str(i)]) = LL.(['elevationDeg' num2str(i)])(validMap);
            stimResults.(['contrast' num2str(i)]) = LL.(['contrastPC' num2str(i)])(validMap);
            stimResults.(['temporalFrequency' num2str(i)]) = LL.(['temporalFreqHz' num2str(i)])(validMap);
%             stimResults.(['sigma' num2str(i)]) = LL.(['sigmaDeg' num2str(i)])(validMap);
            stimResults.(['sigma' num2str(i)]) = LL.(['radiusDeg' num2str(i)])(validMap); % added by MD, 25-08-15...
                %this stores radius of stimuli in the sigma field. This is
                %useful for size protocols. The name sigma has been
                %retained for compatibility with a lot of programs written
                %earlier, but this does not represent sigma in actuality.
            stimResults.(['orientation' num2str(i)]) = LL.(['orientationDeg' num2str(i)])(validMap);
            stimResults.(['spatialFrequency' num2str(i)]) = LL.(['spatialFreqCPD' num2str(i)])(validMap);
            stimResults.(['auditoryAzimuth' num2str(i)]) = LL.(['AuditoryAzimuth' num2str(i)])(validMap);
            stimResults.(['auditoryElevation' num2str(i)]) = LL.(['AuditoryElevation' num2str(i)])(validMap);
            stimResults.(['rippleFrequency' num2str(i)]) = LL.(['RippleFrequency' num2str(i)])(validMap);
            stimResults.(['ripplePhase' num2str(i)]) = LL.(['RipplePhase' num2str(i)])(validMap);
            stimResults.(['auditoryContrast' num2str(i)]) = LL.(['AuditoryContrast' num2str(i)])(validMap);
            stimResults.(['rippleVelocity' num2str(i)]) = LL.(['RippleVelocity' num2str(i)])(validMap);
            stimResults.side = [stimResults.side i-1];
            stimTime.(['gabor' num2str(i-1)]) = (LL.(['time' num2str(i)])(validMap))/1000;
            stimTask.(['gabor' num2str(i-1)]) = LL.(['stimType' num2str(i)])(validMap);
            
        otherwise
            timeLL = [];
            mapping1Times = [];
            taskType = [];
    end
end

% stimResults.azimuth = aziLL;
% stimResults.elevation = eleLL;
% stimResults.contrast = conLL;
% stimResults.temporalFrequency = tfLL;
% if radiusExists
%     stimResults.radius = radiusLL;
% end
% stimResults.sigma = sigmaLL;
% stimResults.orientation = oriLL;
% stimResults.spatialFrequency = sfLL;
% 
% % Added by MD
% stimResults.auditoryAzimuth = LL.AuditoryAzimuth;
% stimResults.auditoryElevation = LL.AuditoryElevation;
% stimResults.rippleFrequency = LL.RippleFrequency;
% stimResults.ripplePhase = LL.RipplePhase;
% stimResults.auditoryContrast = LL.AuditoryContrast;
% stimResults.rippleVelocity = LL.RippleVelocity;

switch stimResults.side(1)
    case 0
        timeLL = stimTime.gabor0; mapping0Times = timeLL; taskType = stimTask.gabor0;
    case 1
        timeLL = stimTime.gabor1; mapping1Times = timeLL; taskType = stimTask.gabor1;
    case 5
        timeLL = stimTime.(['ASgabor' num2str(ASGabor(1))]); mappingASTimes = timeLL; taskType = stimTask.(['ASgabor' num2str(ASGabor(1))]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get timing

trialStartTimesLL = LL.startTime;
eotCodesLL = LL.eotCode;
instructionTrials = LL.instructTrial;
catchTrials = LL.catchTrial;
trialCertify = LL.trialCertify;

if fileFlag
    trialStartTimes = [digitalCodeInfo(find(convertStrCodeToDec('TS')==allDigitalCodesInDec)).time];
    eotCodes = convertUnits([digitalCodeInfo(find(convertStrCodeToDec('TE')==allDigitalCodesInDec)).value])';
    numTrials = length(trialStartTimes);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Instruction trials
    if length(instructionTrials) ~= numTrials 
        error('Number of instruction trial entries different from numTrials');
    end

    % Catch trials
    if length(catchTrials) ~= numTrials 
        error('Number of catch trial entries different from numTrials');
    end

    % TrialCertify & TrialEnd (eotCode)
    % These two entries may be repeated twice during force quit
    forceQuits = find(eotCodes==kForceQuit);
    numForceQuits = length(forceQuits);
    numFalseQuits = length(find(eotCodes == 5));

    if length(eotCodes)-numForceQuits-numFalseQuits == numTrials                               
        if (eotCodes(length(eotCodes)) == 5)
            TempEotCodes = eotCodes(1,1:(length(eotCodes)-1));
            eotCodes = TempEotCodes;
        end
        % numFalseQuits added by MD 28-10-14 to deal with a False Alarm/...
        % quit (code 5) sent by GaborRFMap after all the mapping
        % blocks are over and the stimulus presentation stops.
        disp(['numTrials: ' num2str(numTrials) ' numEotCodes: '  ...
            num2str(length(eotCodes)) ', ForceQuits: ' num2str(numForceQuits) ' FalseQuits: ' num2str(numFalseQuits)]);
        goodEOTPos = find(eotCodes ~=kForceQuit);
        eotCodes = eotCodes(goodEOTPos);                                               
        trialCertify = trialCertify(goodEOTPos);                                        
    else
         disp(['numTrials: ' num2str(numTrials) ' numEotCodes: '  ...
            num2str(length(eotCodes)) ', forcequits: ' num2str(numForceQuits)]);
        error('ForceQuit pressed after trial started'); % TODO - deal with this case
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%% Compare TS and TE data %%%%%%%%%%%%%%%%%%%%%%%
    % Moved here by MD 17-04-15 to deal with a False Alarm/...
        % quit (code 5) in the eotCode as mentioned above
    diffTD = diff(trialStartTimes); diffTL = diff(trialStartTimesLL);

    maxDiffMS = 1000*max(abs(diffTD(:) - diffTL(:)));
    dEOT = max(abs(diff(eotCodes(:)-eotCodesLL(:))));                                   

    maxDiffCutoffMS = 5; % throw an error if the difference exceeds 5 ms
    if maxDiffMS > maxDiffCutoffMS || dEOT > 0
        error('The digital codes do not match with the LL data...');
    else
        disp(['Maximum difference between LL and LFP/EEG start times: ' num2str(maxDiffMS) ' ms']);
    end
else
    trialStartTimes = trialStartTimesLL;
    eotCodes = eotCodesLL;
    numTrials = length(trialStartTimes);
    forceQuits = find(eotCodes==kForceQuit);
    numForceQuits = length(forceQuits);
    numFalseQuits = length(find(eotCodes == 5));

    if length(eotCodes)-numForceQuits-numFalseQuits == numTrials                               
        if (eotCodes(length(eotCodes)) == 5)
            TempEotCodes = eotCodes(1,1:(length(eotCodes)-1));
            eotCodes = TempEotCodes;
        end
        % numFalseQuits added by MD 28-10-14 to deal with a False Alarm/...
        % quit (code 5) sent by GaborRFMap after all the mapping
        % blocks are over and the stimulus presentation stops.
        disp(['numTrials: ' num2str(numTrials) ' numEotCodes: '  ...
            num2str(length(eotCodes)) ', ForceQuits: ' num2str(numForceQuits) ' FalseQuits: ' num2str(numFalseQuits)]);
        goodEOTPos = find(eotCodes ~=kForceQuit);
        eotCodes = eotCodes(goodEOTPos);                                               
        trialCertify = trialCertify(goodEOTPos);                                        
    else
         disp(['numTrials: ' num2str(numTrials) ' numEotCodes: '  ...
            num2str(length(eotCodes)) ', forcequits: ' num2str(numForceQuits)]);
        error('ForceQuit pressed after trial started'); % TODO - deal with this case
    end
    trialResults = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numStims  = getStimPosPerTrial(trialStartTimesLL,timeLL);

posTask = 0;
pos=0;
for i=1:numTrials 
    
    taskTypeThisTrial = taskType(posTask+1:posTask+numStims(i));
%     if (numStims(i)>0) % loop removed by MD 28-10-2014 for hide both gabor conditions
        stimTimesFromTrialStart = timeLL(pos+1:pos+numStims(i)) - trialStartTimesLL(i);
        stimResults.time(pos+1:pos+numStims(i)) = trialStartTimes(i) + stimTimesFromTrialStart; % times relative to the LFP/EEG data, not LL Data
    
        stimResults.type(pos+1:pos+numStims(i)) = taskTypeThisTrial;
        stimResults.trialNumber(pos+1:pos+numStims(i)) = i;
        stimResults.stimPosition(pos+1:pos+numStims(i)) = 1:numStims(i);
        
        if stimResults.side(1)==0
            if pos == length(mapping0Times) % Added by MD 20-08-15
                if pos+numStims(i) > pos
                    error('mapping0Times not proper. Aborting extraction')
                end
            else
                stimResults.stimOnFrame(pos+1:pos+numStims(i)) = ...
                    (mapping0Times(pos+1:pos+numStims(i)) - mapping0Times(pos+1))*frameRate;
            end
        elseif stimResults.side(1)==1
            if pos == length(mapping0Times)
                if pos+numStims(i) > pos
                    error('mapping1Times not proper. Aborting extraction')
                end
            else
                stimResults.stimOnFrame(pos+1:pos+numStims(i)) = ...
                    (mapping1Times(pos+1:pos+numStims(i)) - mapping1Times(pos+1))*frameRate;
            end
        elseif stimResults.side(1)==5 % MD
            if pos == length(mapping0Times)
                if pos+numStims(i) > pos
                    error('mappingASTimes not proper. Aborting extraction')
                end
            else
                stimResults.stimOnFrame(pos+1:pos+numStims(i)) = ...
                    (mappingASTimes(pos+1:pos+numStims(i)) - mappingASTimes(pos+1))*frameRate;
            end
        end
        
        stimResults.instructionTrials(pos+1:pos+numStims(i)) = instructionTrials(i); %always zero
        stimResults.catch(pos+1:pos+numStims(i)) = catchTrials(i);
        stimResults.eotCodes(pos+1:pos+numStims(i)) = eotCodes(i);
        stimResults.trialCertify(pos+1:pos+numStims(i)) = trialCertify(i);
        pos = pos+numStims(i);
%     end
    posTask = posTask+numStims(i);
end

stimResults.side = activeSide;
% Save in folderExtract
save(fullfile(folderExtract,'stimResults.mat'),'stimResults');
save(fullfile(folderExtract,'trialResults.mat'),'trialEvents','trialResults');
end

function outNum = convertUnits(num,f,useSingleITC18Flag)

if ~exist('f','var')                        f=1;                        end
if ~exist('useSingleITC18Flag','var')       useSingleITC18Flag=1;       end

for i=1:length(num)
    if num(i) > 16384
        num(i)=num(i)-32768;
    end
end
outNum = num/f;

% if useSingleITC18Flag
%     outNum=outNum/2;
% end
end
function [numStim,stimOnPos] = getStimPosPerTrial(trialStartTimes, stimStartTimes)

numTrials = length(trialStartTimes);

stimOnPos = cell(1,numTrials);
numStim   = zeros(1,numTrials);

for i=1:numTrials-1
    stimOnPos{i} = intersect(find(stimStartTimes>=trialStartTimes(i)),find(stimStartTimes<trialStartTimes(i+1)));
    numStim(i) = length(stimOnPos{i});
end
stimOnPos{numTrials} = find(stimStartTimes>=trialStartTimes(numTrials));
numStim(numTrials) = length(stimOnPos{numTrials});
end
