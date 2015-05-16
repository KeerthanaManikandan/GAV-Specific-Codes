% This function is used to extract the digital data for the GAV Protocol.

% These are the following modes in which the GaborRFMap protocol has been used so far.

% 1. Target and mapping stimulus 0 are on and are presented synchronously,
% while mapping stimulus 1 is off. Digital codes are sent only for map0 stimulus.

% 2. The task is run in the fixation mode, in which target stimulus is off
% and all trials are catch trials. Digital codes are sent only for map0
% stimulus. The target is assumed to be synchronous with the mapping
% stimulus in this case.

function [goodStimNums,goodStimTimes,side] = extractDigitalDataGAV(folderExtract,ignoreTargetStimFlag,frameRate)

if ~exist('ignoreTargetStimFlag','var');   ignoreTargetStimFlag=1;      end % Default set to 1 by MD
if ~exist('frameRate','var');              frameRate=100;               end

stimResults = readDigitalCodesGAV(folderExtract,frameRate); % writes stimResults and trialResults
side = stimResults.side;
[goodStimNums,goodStimTimes] = getGoodStimNumsGAV(folderExtract,ignoreTargetStimFlag,0); % Good stimuli
save(fullfile(folderExtract,'goodStimNums.mat'),'goodStimNums','goodStimTimes');
end

% GAV Specific protocols
function [stimResults,trialResults,trialEvents] = readDigitalCodesGAV(folderOut,frameRate)

if ~exist('frameRate','var');              frameRate=100;               end
kForceQuit=7;

% Get the values of the following trial events for comparison with the dat
% file from lablib
trialEvents{1} = 'TS'; % Trial start
trialEvents{2} = 'TE'; % Trial End

folderOut = appendIfNotPresent(folderOut,'\');
load(fullfile(folderOut,'digitalEvents.mat'));

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus properties
azimuth          = [digitalCodeInfo(find(convertStrCodeToDec('AZ')==allDigitalCodesInDec)).value];
elevation        = [digitalCodeInfo(find(convertStrCodeToDec('EL')==allDigitalCodesInDec)).value];
contrast         = [digitalCodeInfo(find(convertStrCodeToDec('CO')==allDigitalCodesInDec)).value];
temporalFrequency= [digitalCodeInfo(find(convertStrCodeToDec('TF')==allDigitalCodesInDec)).value];
radius           = [digitalCodeInfo(find(convertStrCodeToDec('RA')==allDigitalCodesInDec)).value];
sigma            = [digitalCodeInfo(find(convertStrCodeToDec('SI')==allDigitalCodesInDec)).value];
spatialFrequency = [digitalCodeInfo(find(convertStrCodeToDec('SF')==allDigitalCodesInDec)).value];
orientation      = [digitalCodeInfo(find(convertStrCodeToDec('OR')==allDigitalCodesInDec)).value];

% Added by MD for audio stimulus 27-10-2014; Modified in April 2015
audioVolume = [digitalCodeInfo(find(convertStrCodeToDec('AV')==allDigitalCodesInDec)).value];
audioTF = [digitalCodeInfo(find(convertStrCodeToDec('AT')==allDigitalCodesInDec)).value];
audioSF = [digitalCodeInfo(find(convertStrCodeToDec('AS')==allDigitalCodesInDec)).value];
audioOri = [digitalCodeInfo(find(convertStrCodeToDec('AO')==allDigitalCodesInDec)).value];
audioAzi = [digitalCodeInfo(find(convertStrCodeToDec('AA')==allDigitalCodesInDec)).value];

% Get timing
trialStartTimes = [digitalCodeInfo(find(convertStrCodeToDec('TS')==allDigitalCodesInDec)).time];
taskGaborTimes  = [digitalCodeInfo(find(convertStrCodeToDec('TG')==allDigitalCodesInDec)).time];
mapping0Times   = [digitalCodeInfo(find(convertStrCodeToDec('M0')==allDigitalCodesInDec)).time];
mapping1Times   = [digitalCodeInfo(find(convertStrCodeToDec('M1')==allDigitalCodesInDec)).time];
mappingASTimes = [digitalCodeInfo(find(convertStrCodeToDec('AD')==allDigitalCodesInDec)).time]; % added by MD
numTrials = length(trialStartTimes);


% Check the default case - only mapping0/1 is on, and only its stimulus properties are put out.

if (max(diff([length(azimuth) length(elevation) length(contrast) length(temporalFrequency) ...
    length(radius) length(sigma) length(spatialFrequency) length(orientation)])) > 0 )

    error('Length of stimulus properties are not even');
else
    if  ((~isempty(mapping0Times)) && ((isempty(mapping1Times)))) % ((length(azimuth) == length(mapping0Times)) && isempty(mapping1Times))
        disp('Only Mapping 0 is used');
        stimResults.azimuth = convertUnits(azimuth',100);
        stimResults.elevation = convertUnits(elevation',100);
        stimResults.contrast = convertUnits(contrast',10);
        stimResults.temporalFrequency = convertUnits(temporalFrequency',100);
        stimResults.radius = convertUnits(radius',100);
        stimResults.sigma = convertUnits(sigma',100);
        stimResults.orientation = convertUnits(orientation');
        stimResults.spatialFrequency = convertUnits(spatialFrequency',100);
        stimResults.side=0;
        
    elseif ((~isempty(mapping1Times)) && ((isempty(mapping0Times))))%((length(azimuth) == length(mapping1Times)) && isempty(mapping0Times))
        disp('Only Mapping 1 is used');
        stimResults.azimuth = convertUnits(azimuth',100);
        stimResults.elevation = convertUnits(elevation',100);
        stimResults.contrast = convertUnits(contrast',10);
        stimResults.temporalFrequency = convertUnits(temporalFrequency',10);
        stimResults.radius = convertUnits(radius',100);
        stimResults.sigma = convertUnits(sigma',100);
        stimResults.orientation = convertUnits(orientation');
        stimResults.spatialFrequency = convertUnits(spatialFrequency',100);
        stimResults.side=1;
        
    else
        if ((isempty(mapping0Times)) && ((isempty(mapping1Times))))
            disp('No Visual Stimuli!!!');
        else
            disp('Digital codes from both sides!!!');
        end
        stimResults.azimuth = convertUnits(azimuth',100);
        stimResults.elevation = convertUnits(elevation',100);
        stimResults.contrast = convertUnits(contrast',10);
        stimResults.temporalFrequency = convertUnits(temporalFrequency',10);
        stimResults.radius = convertUnits(radius',100);
        stimResults.sigma = convertUnits(sigma',100);
        stimResults.orientation = convertUnits(orientation');
        stimResults.spatialFrequency = convertUnits(spatialFrequency',100);
        stimResults.side=[];
    end
end

% added by MD for Auditory Digital codes
stimResults.audioVolume = convertUnits(audioVolume');
stimResults.audioTF = convertUnits(audioTF');
stimResults.audioOri = convertUnits(audioOri');
stimResults.audioSF = convertUnits(audioSF');
stimResults.audioAzi = convertUnits(audioAzi');
if (~isempty(mappingASTimes))
    stimResults.side=[stimResults.side 5]; % 5 corresponds to auditory stimulus
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Instruction trials
instructionTrials = convertUnits([digitalCodeInfo(find(convertStrCodeToDec('IT')==allDigitalCodesInDec)).value])';
if length(instructionTrials) ~= numTrials 
    error('Number of instruction trial entries different from numTrials');
end

% Catch trials
catchTrials = convertUnits([digitalCodeInfo(find(convertStrCodeToDec('CT')==allDigitalCodesInDec)).value])';
if length(catchTrials) ~= numTrials 
    error('Number of catch trial entries different from numTrials');
end

% TrialCertify & TrialEnd (eotCode)
% These two entries may be repeated twice during force quit
trialCertify = convertUnits([digitalCodeInfo(find(convertStrCodeToDec('TC')==allDigitalCodesInDec)).value])';
eotCodes = convertUnits([digitalCodeInfo(find(convertStrCodeToDec('TE')==allDigitalCodesInDec)).value])';

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
        num2str(length(eotCodes)) ', ForceQuits: ' num2str(numForceQuits)]);
    goodEOTPos = find(eotCodes ~=kForceQuit);
    eotCodes = eotCodes(goodEOTPos);
    trialCertify = trialCertify(goodEOTPos);
else
     disp(['numTrials: ' num2str(numTrials) ' numEotCodes: '  ...
        num2str(length(eotCodes)) ', forcequits: ' num2str(numForceQuits)]);
    error('ForceQuit pressed after trial started'); % TODO - deal with this case
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numStimTask  = getStimPosPerTrial(trialStartTimes, taskGaborTimes);
numStimMap0  = getStimPosPerTrial(trialStartTimes, mapping0Times);
numStimMap1  = getStimPosPerTrial(trialStartTimes, mapping1Times);
numStimMapAS  = getStimPosPerTrial(trialStartTimes, mappingASTimes); % MD 28-10-14

% Check if Task and Mapping stim nums are the same for non-intruction trials
nonInstructionTrials = find(instructionTrials==0);
if (max(abs(numStimTask(nonInstructionTrials) - numStimMap0(nonInstructionTrials)))==0)
    disp('Mapping0 and Task times are the same');
    numStims = numStimMap0;
    stimResults.time = [digitalCodeInfo(find(convertStrCodeToDec('M0')==allDigitalCodesInDec)).time]';
    stimResults.side = 0;
    taskType = convertUnits([digitalCodeInfo(find(convertStrCodeToDec('TG')==allDigitalCodesInDec)).value])'; 
    
    if sum(taskType)==0 % Target is always null
        taskType = convertUnits([digitalCodeInfo(find(convertStrCodeToDec('M0')==allDigitalCodesInDec)).value])';
    end
    
elseif (max(abs(numStimTask(nonInstructionTrials) - numStimMap1(nonInstructionTrials)))==0)
    disp('Mapping1 and Task times are the same');
    numStims = numStimMap1;
    stimResults.time = [digitalCodeInfo(find(convertStrCodeToDec('M1')==allDigitalCodesInDec)).time]';
    stimResults.side = 1;
    taskType = convertUnits([digitalCodeInfo(find(convertStrCodeToDec('TG')==allDigitalCodesInDec)).value])';
    
    if sum(taskType)==0 % Target is always null
        taskType = convertUnits([digitalCodeInfo(find(convertStrCodeToDec('M1')==allDigitalCodesInDec)).value])';
    end
    
else
    disp('Mapping0/1 and Task times not the same');
    
    if sum(numStimMap0)>0 && sum(numStimMap1)==0
        disp('Using Mapping0 times instead of task times...');
        numStimTask=numStimMap0;        % Assume task time is the same as mapping stimulus time                            
        numStims = numStimMap0;
        stimResults.time = [digitalCodeInfo(find(convertStrCodeToDec('M0')==allDigitalCodesInDec)).time]';
        
%         stimResults.side = 0; % commented by MD
        taskType = convertUnits([digitalCodeInfo(find(convertStrCodeToDec('M0')==allDigitalCodesInDec)).value])'; % Assume task times and types are the same as M0
    
    elseif sum(numStimMap0)==0 && sum(numStimMap1)>0
        disp('Using Mapping1 times instead of task times...');
        numStimTask=numStimMap1;        % Assume task time is the same as mapping stimulus time
        numStims = numStimMap1;
        stimResults.time = [digitalCodeInfo(find(convertStrCodeToDec('M1')==allDigitalCodesInDec)).time]';
        
%         stimResults.side = 1; % commented by MD
        taskType = convertUnits([digitalCodeInfo(find(convertStrCodeToDec('M1')==allDigitalCodesInDec)).value])'; % Assume task times and types are the same as M1
    else % Added by MD
        disp('Using MappingAS times instead of task times...');
        numStimTask=numStimMapAS;        % Assume task time is the same as mapping stimulus time
        numStims = numStimMapAS;
        stimResults.time = [digitalCodeInfo(find(convertStrCodeToDec('AD')==allDigitalCodesInDec)).time]';
        taskType = convertUnits([digitalCodeInfo(find(convertStrCodeToDec('AD')==allDigitalCodesInDec)).value])'; % Assume task times and types are the same as AD
    end
end

posTask = 0;
pos=0;
for i=1:numTrials
    taskTypeThisTrial = taskType(posTask+1:posTask+numStimTask(i));
%     if (numStims(i)>0) % loop removed by MD 28-10-2014 for hide both gabor conditions
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
        else
            error('No digital code present. Hence, can not proceed with extraction!!') % MD
        end
        
        stimResults.instructionTrials(pos+1:pos+numStims(i)) = instructionTrials(i); %always zero
        stimResults.catch(pos+1:pos+numStims(i)) = catchTrials(i);
        stimResults.eotCodes(pos+1:pos+numStims(i)) = eotCodes(i);
        stimResults.trialCertify(pos+1:pos+numStims(i)) = trialCertify(i);
        pos = pos+numStims(i);
%     end
    posTask = posTask+numStimTask(i);
end

% Save in folderOut
save(fullfile(folderOut,'stimResults.mat'),'stimResults');
save(fullfile(folderOut,'trialResults.mat'),'trialEvents','trialResults');

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
