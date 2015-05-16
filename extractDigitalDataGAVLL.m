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

load(fullfile(folderExtract,'digitalEvents.mat'));

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load Lablib data structure
load(fullfile(folderExtract,'LL.mat'));

activeSide = [];
if sum(LL.stimType1)>0
    activeSide=[activeSide 0];
elseif sum(LL.stimType2)>0
    activeSide=[activeSide 1];
end

activeSide=[activeSide 5]; % added by MD: activeSide = 5 for Auditory gabors

%%%%%%%%%%%%%%%%% Get info from LL to construct stimResults %%%%%%%%%%%%%%%
% for i=1:length(activeSide) % for and 
    switch activeSide(1) % switch loop added by MD
        case 0
%         if activeSide==0 % Map0
            validMap = find(LL.stimType1>0);
            aziLL = LL.azimuthDeg1(validMap);
            eleLL = LL.elevationDeg1(validMap);
            sigmaLL = LL.sigmaDeg1(validMap);

            if isfield(LL,'radiusDeg1')
                radiusExists = 1;
                radiusLL = LL.radiusDeg1(validMap);
            else
                radiusExists = 0;
            end
            sfLL = LL.spatialFreqCPD1(validMap);
            oriLL = LL.orientationDeg1(validMap);
            conLL = LL.contrastPC1(validMap); 
            tfLL = LL.temporalFreqHz1(validMap); 
            timeLL = LL.time1(validMap)/1000;
            mapping0Times = timeLL;
            taskType = LL.stimType1(validMap);

%         elseif activeSide==1 % Map2

        case 1
            validMap = find(LL.stimType2>0);
            aziLL = LL.azimuthDeg2(validMap);
            eleLL = LL.elevationDeg2(validMap);
            sigmaLL = LL.sigmaDeg2(validMap);
            if isfield(LL,'radiusDeg2')
                radiusExists = 1;
                radiusLL = LL.radiusDeg2(validMap);
            else
                radiusExists = 0;
            end
            sfLL = LL.spatialFreqCPD2(validMap);
            oriLL = LL.orientationDeg2(validMap);
            conLL = LL.contrastPC2(validMap); 
            tfLL = LL.temporalFreqHz2(validMap);
            timeLL = LL.time2(validMap)/1000;
            mapping1Times = timeLL;
            taskType = LL.stimType2(validMap);
        otherwise
            validMap = [];
            aziLL = [];
            eleLL = [];
            sigmaLL = [];
            radiusLL = [];            
            radiusExists = 0;            
            sfLL = [];
            oriLL = [];
            conLL = []; 
            tfLL = [];
            timeLL = [];
            mapping1Times = [];
            taskType = [];
    end
% end

stimResults.azimuth = aziLL;
stimResults.elevation = eleLL;
stimResults.contrast = conLL;
stimResults.temporalFrequency = tfLL;
if radiusExists
    stimResults.radius = radiusLL;
end
stimResults.sigma = sigmaLL;
stimResults.orientation = oriLL;
stimResults.spatialFrequency = sfLL;

% Added by MD
stimResults.auditoryAzimuth = LL.AuditoryAzimuth;
stimResults.auditoryElevation = LL.AuditoryElevation;
stimResults.rippleFrequency = LL.RippleFrequency;
stimResults.ripplePhase = LL.RipplePhase;
stimResults.auditoryContrast = LL.AuditoryContrast;
stimResults.rippleVelocity = LL.RippleVelocity;

timeASLL = LL.time2/1000;
mappingASTimes = timeASLL;
if isempty(timeLL); timeLL=timeASLL; end;
if isempty(taskType); taskType = LL.stimType2; end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get timing
trialStartTimes = [digitalCodeInfo(find(convertStrCodeToDec('TS')==allDigitalCodesInDec)).time];
eotCodes = convertUnits([digitalCodeInfo(find(convertStrCodeToDec('TE')==allDigitalCodesInDec)).value])';
trialStartTimesLL = LL.startTime;
eotCodesLL = LL.eotCode;


numTrials = length(trialStartTimes);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Instruction trials
instructionTrials = LL.instructTrial;
if length(instructionTrials) ~= numTrials 
    error('Number of instruction trial entries different from numTrials');
end

% Catch trials
catchTrials = LL.catchTrial;
if length(catchTrials) ~= numTrials 
    error('Number of catch trial entries different from numTrials');
end

% TrialCertify & TrialEnd (eotCode)
% These two entries may be repeated twice during force quit
trialCertify = LL.trialCertify;

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
% dEOT = max(abs(diff(eotCodes(1,:)-eotCodesLL(1,:))));
% diffMS = (diffTD(:) - diffTL(:));
% diffTS = (trialStartTimesLL(:) - trialStartTimes(:));
dEOT = max(abs(diff(eotCodes(:)-eotCodesLL(:))));                                   

maxDiffCutoffMS = 5; % throw an error if the difference exceeds 5 ms
if maxDiffMS > maxDiffCutoffMS || dEOT > 0
    error('The digital codes do not match with the LL data...');
else
    disp(['Maximum difference between LL and LFP/EEG start times: ' num2str(maxDiffMS) ' ms']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numStims  = getStimPosPerTrial(trialStartTimesLL,timeLL);
stimResults.side = activeSide;

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
            stimResults.stimOnFrame(pos+1:pos+numStims(i)) = ...
                (mapping0Times(pos+1:pos+numStims(i)) - mapping0Times(pos+1))*frameRate;
        elseif stimResults.side(1)==1
            stimResults.stimOnFrame(pos+1:pos+numStims(i)) = ...
                (mapping1Times(pos+1:pos+numStims(i)) - mapping1Times(pos+1))*frameRate;
        elseif stimResults.side(1)==5 % MD
            stimResults.stimOnFrame(pos+1:pos+numStims(i)) = ...
                (mappingASTimes(pos+1:pos+numStims(i)) - mappingASTimes(pos+1))*frameRate;
        end
        
        stimResults.instructionTrials(pos+1:pos+numStims(i)) = instructionTrials(i); %always zero
        stimResults.catch(pos+1:pos+numStims(i)) = catchTrials(i);
        stimResults.eotCodes(pos+1:pos+numStims(i)) = eotCodes(i);
        stimResults.trialCertify(pos+1:pos+numStims(i)) = trialCertify(i);
        pos = pos+numStims(i);
%     end
    posTask = posTask+numStims(i);
end

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
