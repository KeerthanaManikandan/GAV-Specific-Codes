% This function is used to extract the digital data for the GAV Protocol.
% (Murty V P S Dinavahi)

function goodStimTimes = extractDigitalDataGAVOld(digitalEvents,digitalTimeStamps,folderExtract,ignoreTargetStimFlag,frameRate)

if ~exist('ignoreTargetStimFlag','var')   ignoreTargetStimFlag=0;       end
if ~exist('frameRate','var')              frameRate=100;                 end    %frameRate of BenQ

useSingleITC18Flag=1;

% Special cases in case a singleITC is used.
if useSingleITC18Flag
    % First, find the reward signals
    rewardOnPos = find(rem(digitalEvents,2)==0);
    rewardOffPos = find(digitalEvents==2^16-1);
    
    if length(rewardOnPos)~=length(rewardOffPos)
        disp('Unequal number of reward on and reward off!!');
    else
        rewardPos = [rewardOnPos(:) ; rewardOffPos(:)];
        disp([num2str(length(rewardPos)) ' are reward signals and will be discarded' ]);
        digitalEvents(rewardPos)=[];
        digitalTimeStamps(rewardPos)=[];
    end
    digitalEvents=digitalEvents-1;
end

% All digital codes all start with a leading 1, which means that they are greater than hex2dec(8000) = 32768.
modifiedDigitalEvents = digitalEvents(digitalEvents>32768) - 32768;
allCodesInDec = unique(modifiedDigitalEvents);
disp(['Number of distinct codes: ' num2str(length(allCodesInDec))]);
allCodesInStr = convertDecCodeToStr(allCodesInDec,useSingleITC18Flag);

clear identifiedDigitalCodes badDigitalCodes
count=1; badCount=1;
for i=1:length(allCodesInDec)
    if ~digitalCodeDictionary(allCodesInStr(i,:))
        disp(['Unidentified digital code: ' allCodesInStr(i,:) ', bin: ' dec2bin(allCodesInDec(i),16) ', dec: ' num2str(allCodesInDec(i)) ', occured ' num2str(length(find(modifiedDigitalEvents==allCodesInDec(i))))]);
        badDigitalCodes(badCount) = allCodesInDec(i);
        badCount=badCount+1;
    else
        identifiedDigitalCodes(count) = allCodesInDec(i);
        count=count+1;
    end
end

if badCount>1
    error(['The following Digital Codes are bad: ' num2str(badDigitalCodes)]);
end

numDigitalCodes = length(identifiedDigitalCodes);
disp(['Number of distinct codes identified: ' num2str(numDigitalCodes)]);

for i=1:numDigitalCodes
    digitalCodeInfo(i).codeNumber = identifiedDigitalCodes(i); %#ok<*AGROW>
    digitalCodeInfo(i).codeName = convertDecCodeToStr(identifiedDigitalCodes(i));
    clear codePos
    codePos = find(identifiedDigitalCodes(i) == digitalEvents-32768);
    digitalCodeInfo(i).time = digitalTimeStamps(codePos);
    digitalCodeInfo(i).value = digitalEvents(codePos+1);
end

% Write the digitalCodes
makeDirectory(folderExtract);
save([folderExtract 'digitalEvents.mat'],'digitalCodeInfo','digitalTimeStamps','digitalEvents');

%%%%%%%%%%%%%%%%%%%%%%% Get Stimulus results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
readDigitalCodesGRF(folderExtract,frameRate); % writes stimResults and trialResults
[goodStimNums,goodStimTimes] = getGoodStimNumsGRF(folderExtract,ignoreTargetStimFlag); % Good stimuli


getDisplayCombinationsGRF(folderExtract,goodStimNums);


save([folderExtract 'goodStimNums.mat'],'goodStimNums');

end

% GAV Specific protocols
function [stimResults,trialResults,trialEvents] = readDigitalCodesGRF(folderOut,frameRate)

if ~exist('frameRate','var')              frameRate=100;                 end   %frameRate of BenQ
kForceQuit=7;

% Get the values of the following trial events for comparison with the dat
% file from lablib
trialEvents{1} = 'TS'; % Trial start
trialEvents{2} = 'TE'; % Trial End

folderOut = appendIfNotPresent(folderOut,'\');
load([folderOut 'digitalEvents.mat']);

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

% Added by MD for audio stimulus 27-10-2014
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
    % numFalseQuits added by MD 28-10-14 to deal with a bug in GaborRFMap that sends a False Alarm/...
    % quit (code 5) after all the mapping
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


% Vinay - undo the checking ahead if the task gabor is hidden
taskGabor = 0; % Vinay - implies that the task gabor is visible or not
if taskGabor
% Check if Task and Mapping stim nums are the same for non-intruction trials
nonInstructionTrials = find(instructionTrials==0);
    if (max(abs(numStimTask(nonInstructionTrials) - numStimMap0(nonInstructionTrials)))==0)
        disp('Mapping0 and Task times are the same');
        numStims = numStimMap0;
        stimResults.time = [digitalCodeInfo(find(convertStrCodeToDec('M0')==allDigitalCodesInDec)).time]';
    elseif (max(abs(numStimTask(nonInstructionTrials) - numStimMap1(nonInstructionTrials)))==0)
        disp('Mapping1 and Task times are the same');
        numStims = numStimMap1;
        stimResults.time = [digitalCodeInfo(find(convertStrCodeToDec('M1')==allDigitalCodesInDec)).time]';
    else
        error('Mapping0/1 and Task times not the same');
    end

elseif (sum(numStimMap0) == 0) && (sum(numStimMap1) > 0)
    numStims = numStimMap1;
    stimResults.time = [digitalCodeInfo(find(convertStrCodeToDec('M1')==allDigitalCodesInDec)).time]';
elseif (sum(numStimMap1) == 0) && (sum(numStimMap0) > 0)
    numStims = numStimMap0;
    stimResults.time = [digitalCodeInfo(find(convertStrCodeToDec('M0')==allDigitalCodesInDec)).time]';
else % MD
    numStims = numStimMapAS;
    stimResults.time = [digitalCodeInfo(find(convertStrCodeToDec('AD')==allDigitalCodesInDec)).time]';
end
% changes over


taskType = convertUnits([digitalCodeInfo(find(convertStrCodeToDec('TG')==allDigitalCodesInDec)).value])';
posTask = 0;
pos=0;

% changes made by Vinay
for i=1:numTrials
    taskTypeThisTrial = taskType(posTask+1:posTask+numStimTask(i));
%     if (numStims(i)>0) % loop removed by MD 28-10-2014 for hide both gabor conditions
%         stimResults.type(pos+1:pos+numStims(i)) = taskTypeThisTrial;
        stimResults.type(pos+1:pos+numStimTask(i)) = taskTypeThisTrial; % Vinay - changed numStims to numStimTask 
        % (so that in cases where numStim0/1 are not equal to numStimTask,
        % the code doesn't get stuck here. Anyway, this seems to be the
        % right way to do it)
        stimResults.trialNumber(pos+1:pos+numStims(i)) = i;
        stimResults.stimPosition(pos+1:pos+numStims(i)) = 1:numStims(i);
        
%         if (~isempty('mapping0Times') || ~isempty('mapping1Times'))  % added by MD 28-10-2014 for hide both gabor conditions
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
%         end
        
        stimResults.instructionTrials(pos+1:pos+numStims(i)) = instructionTrials(i); %always zero
        stimResults.catch(pos+1:pos+numStims(i)) = catchTrials(i);
        stimResults.eotCodes(pos+1:pos+numStims(i)) = eotCodes(i);
        stimResults.trialCertify(pos+1:pos+numStims(i)) = trialCertify(i);
        pos = pos+numStims(i);
%     end
    posTask = posTask+numStimTask(i);
end
% changes over

% Save in folderOut
save([folderOut 'stimResults.mat'],'stimResults');
save([folderOut 'trialResults.mat'],'trialEvents','trialResults');

end
function [goodStimNums,goodStimTimes] = getGoodStimNumsGRF(folderOut,ignoreTargetStimFlag)

if ~exist('ignoreTargetStimFlag','var')       ignoreTargetStimFlag=0;   end

folderOut = appendIfNotPresent(folderOut,'\');
load([folderOut 'stimResults.mat']);

totalStims = length(stimResults.eotCodes);
disp(['Number of trials: ' num2str(max(stimResults.trialNumber))]);
disp(['Number of stimuli: ' num2str(totalStims)]);

% exclude uncertified trials, catch trials and instruction trials
tc = find(stimResults.trialCertify==1);
it = find(stimResults.instructionTrials==1);
ct = find(stimResults.catch==1);

if ignoreTargetStimFlag
    badStimNums = [it tc]; % catch trials are now considered good
else
    badStimNums = [it tc ct];
end

%eottypes
% 0 - correct, 1 - wrong, 2-failed, 3-broke, 4-ignored, 5-False
% Alarm/quit, 6 - distracted, 7 - force quit
%disp('Analysing correct, wrong and failed trials');
%badEOTs = find(stimResults.eotCodes>2); 
%disp('Analysing correct and wrong trials')
%badEOTs = find(stimResults.eotCodes>1); 
disp('Analysing only correct trials')
badEOTs = find(stimResults.eotCodes>0); 
badStimNums = [badStimNums badEOTs];

goodStimNums = setdiff(1:totalStims,unique(badStimNums));

% stim types
% 0 - Null, 1 - valid, 2 - target, 3 - frontpadding, 4 - backpadding
if ~ignoreTargetStimFlag
    disp('Only taking valid stims ');
    validStims = find(stimResults.type==1);
    goodStimNums = intersect(goodStimNums,validStims);
    
    %%%%%%%%%%%%%% Remove bad stimuli after target %%%%%%%%%%%%%%%%%%%%
    
    clear trialNums stimPos
    trialNums = stimResults.trialNumber(goodStimNums);
    stimPos   = stimResults.stimPosition(goodStimNums);
    
    % Get the target positions of the trialNums
    clear goodTrials
    goodTrials = unique(trialNums);
    
    clear targetPos
    for i=1:length(goodTrials)
        allStimWithThisTrialNum = find(stimResults.trialNumber==goodTrials(i));
        
        if sum(stimResults.catch(allStimWithThisTrialNum))>0        % catch trials
            targetPos(trialNums==goodTrials(i)) = inf; %#ok<*AGROW>
        else
            targetPos(trialNums==goodTrials(i)) = find(stimResults.type(allStimWithThisTrialNum)==2);
        end
    end
    
    validStimuliAfterTarget = find(stimPos>targetPos);
    if ~isempty(validStimuliAfterTarget)
        disp([num2str(length(validStimuliAfterTarget)) ' out of ' num2str(length(goodStimNums)) ' stimuli after target']);
        save([folderOut 'validStimAfterTarget.mat'],'validStimuliAfterTarget');
    end
    
    goodStimNums(validStimuliAfterTarget)=[];
end
disp(['Number of good stimuli: ' num2str(length(goodStimNums))]);
goodStimTimes = stimResults.time(goodStimNums);
end
function parameterCombinations = getDisplayCombinationsGRF(folderOut,goodStimNums)

folderOut = appendIfNotPresent(folderOut,'\');
load([folderOut 'stimResults.mat']);

% 12 parameters are chosen:
% 1. Azimuth
% 2. Elevation
% 3. Sigma, Radius 
% 4. Spatial Frequency
% 5. Orientation
% 6. Contrast
% 7. Temporal Frequency
% 8. Audio Volume
% 9. Audio TF
% 10. Audio SF
% 11. Audio Ori
% 12. Audio Azi

% Initialise (MD 27-10-2014)
aLen=0;
eLen=0;
sLen=0;
fLen=0;
oLen=0;
cLen=0;
tLen=0;
aaLen=0;
asLen=0;
aoLen=0;
avLen=0;
atLen=0;


% Parameters index
parameters{1} = 'azimuth';
parameters{2} = 'elevation';
parameters{3} = 'sigma';
parameters{4} = 'spatialFrequency';
parameters{5} = 'orientation';
parameters{6} = 'contrast';
parameters{7} = 'temporalFrequency'; %#ok<NASGU>
parameters{8} = 'audioAzi';
parameters{9} = 'audioSF';
parameters{10} = 'audioOri';
parameters{11} = 'audioVolume';
parameters{12} = 'audioTF';


if ~exist('goodStimNums','var')
    goodStimNums = getGoodStimNumsGRF(folderOut);
end

if ~isempty(stimResults.azimuth)
    aValsAll  = stimResults.azimuth;
    aValsGood = aValsAll(goodStimNums);
    aValsUnique = unique(aValsGood); aLen = length(aValsUnique);
    disp(['Number of unique azimuths: ' num2str(aLen)]);
end

if ~isempty(stimResults.elevation) 
    eValsAll  = stimResults.elevation;
    eValsGood = eValsAll(goodStimNums);
    eValsUnique = unique(eValsGood); eLen = length(eValsUnique);
    disp(['Number of unique elevations: ' num2str(eLen)]);
end

if ~isempty(stimResults.sigma)
    sValsAll  = stimResults.sigma;
    sValsGood = sValsAll(goodStimNums);
    sValsUnique = unique(sValsGood); sLen = length(sValsUnique);
    disp(['Number of unique sigmas: ' num2str(sLen)]);
end

if ~isempty(stimResults.spatialFrequency)
    fValsAll  = stimResults.spatialFrequency;
    fValsGood = fValsAll(goodStimNums);
    fValsUnique = unique(fValsGood); fLen = length(fValsUnique);
    disp(['Number of unique Spatial freqs: ' num2str(fLen)]);
end

if ~isempty(stimResults.orientation)
    oValsAll  = stimResults.orientation;
    oValsGood = oValsAll(goodStimNums);
    oValsUnique = unique(oValsGood); oLen = length(oValsUnique);
    disp(['Number of unique orientations: ' num2str(oLen)]);
end

if ~isempty(stimResults.contrast)
    cValsAll  = stimResults.contrast;
    cValsGood = cValsAll(goodStimNums);
    cValsUnique = unique(cValsGood); cLen = length(cValsUnique);
    disp(['Number of unique contrasts: ' num2str(cLen)]);
end
    
if ~isempty(stimResults.temporalFrequency)
    tValsAll  = stimResults.temporalFrequency;
    tValsGood = tValsAll(goodStimNums);
    tValsUnique = unique(tValsGood); tLen = length(tValsUnique);
    disp(['Number of unique temporal freqs: ' num2str(tLen)]);
end
    
if ~isempty(stimResults.audioAzi)
    aaValsAll = stimResults.audioAzi;
    aaValsGood = aaValsAll(goodStimNums);   
    aaValsUnique = unique(aaValsGood); aaLen = length(aaValsUnique);
    disp(['Number of unique auditory SFs: ' num2str(aaLen)]);
end

if ~isempty(stimResults.audioSF)
    asValsAll = stimResults.audioSF;
    asValsGood = asValsAll(goodStimNums);   
    asValsUnique = unique(asValsGood); asLen = length(asValsUnique);
    disp(['Number of unique auditory SFs: ' num2str(asLen)]);
end

if ~isempty(stimResults.audioOri)
    aoValsAll = stimResults.audioOri;
    aoValsGood = aoValsAll(goodStimNums);   
    aoValsUnique = unique(aoValsGood); aoLen = length(aoValsUnique);
    disp(['Number of unique auditory Oris: ' num2str(aoLen)]);
end

if ~isempty(stimResults.audioVolume)
    avValsAll = stimResults.audioVolume;
    avValsGood = avValsAll(goodStimNums);
    avValsUnique = unique(avValsGood); avLen = length(avValsUnique);
    disp(['Number of unique auditory volumes: ' num2str(avLen)]);
end
    
if ~isempty(stimResults.audioTF)
    atValsAll = stimResults.audioTF;
    atValsGood = atValsAll(goodStimNums);   
    atValsUnique = unique(atValsGood); atLen = length(atValsUnique);
    disp(['Number of unique auditory TFs: ' num2str(atLen)]);
end

% If more than one value, make another entry with all values
if (aLen > 1)           aLen=aLen+1;                    end
if (eLen > 1)           eLen=eLen+1;                    end
if (sLen > 1)           sLen=sLen+1;                    end
if (fLen > 1)           fLen=fLen+1;                    end
if (oLen > 1)           oLen=oLen+1;                    end
if (cLen > 1)           cLen=cLen+1;                    end
if (tLen > 1)           tLen=tLen+1;                    end
if (aaLen > 1)           aaLen=aaLen+1;                    end
if (asLen > 1)           asLen=asLen+1;                    end
if (aoLen > 1)           aoLen=aoLen+1;                    end
if (avLen > 1)           avLen=avLen+1;                    end
if (atLen > 1)           atLen=atLen+1;                    end

% Added by MD to include 'no codes' from gabors 27-10-2014
if (aLen==0); aLen=1; aValsUnique=-999; end
if (eLen==0); eLen=1; eValsUnique=-999; end
if (sLen==0); sLen=1; sValsUnique=-999; end
if (fLen==0); fLen=1; fValsUnique=-999; end
if (oLen==0); oLen=1; oValsUnique=-999; end
if (cLen==0); cLen=1; cValsUnique=-999; end
if (tLen==0); tLen=1; tValsUnique=-999; end
if (aaLen==0); aaLen=1; aaValsUnique=-999; end
if (asLen==0); asLen=1; asValsUnique=-999; end
if (aoLen==0); aoLen=1; aoValsUnique=-999; end
if (avLen==0); avLen=1; avValsUnique=-999; end
if (atLen==0); atLen=1; atValsUnique=-999; end

allPos = 1:length(goodStimNums);
disp(['total combinations: ' num2str((aLen)*(eLen)*(sLen)*(fLen)*(oLen)*(cLen)*(tLen)*(aaLen)*(asLen)*(aoLen)*(avLen)*(atLen))]);

for a=1:aLen
    if a==aLen
        aPos = allPos;
    else
        aPos = find(aValsGood == aValsUnique(a));
    end

    for e=1:eLen
        if e==eLen
            ePos = allPos;
        else
            ePos = find(eValsGood == eValsUnique(e));
        end

        for s=1:sLen
            if s==sLen
                sPos = allPos;
            else
                sPos = find(sValsGood == sValsUnique(s));
            end

            for f=1:fLen
                if f==fLen
                    fPos = allPos;
                else
                    fPos = find(fValsGood == fValsUnique(f));
                end

                for o=1:oLen
                    if o==oLen
                        oPos = allPos;
                    else
                        oPos = find(oValsGood == oValsUnique(o));
                    end

                    for c=1:cLen
                        if c==cLen
                            cPos = allPos;
                        else
                            cPos = find(cValsGood == cValsUnique(c));
                        end

                        for t=1:tLen
                            if t==tLen
                                tPos = allPos;
                            else
                                tPos = find(tValsGood == tValsUnique(t));
                            end
                                for aa=1:aaLen
                                    if aa==aaLen
                                        aaPos = allPos;
                                    else
                                        aaPos = find(aaValsGood == aaValsUnique(aa));
                                    end                                                                                    
                                        for as=1:asLen
                                        if as==asLen
                                            asPos = allPos;
                                        else
                                            asPos = find(asValsGood == asValsUnique(as));
                                        end

                                            for ao=1:aoLen
                                                if ao==aoLen
                                                    aoPos = allPos;
                                                else
                                                    aoPos = find(aoValsGood == aoValsUnique(ao));
                                                end
                                                for av=1:avLen
                                                    if av==avLen
                                                        avPos = allPos;
                                                    else
                                                        avPos = find(avValsGood == avValsUnique(av));
                                                    end
                                                        for at=1:atLen
                                                            if at==atLen
                                                                atPos = allPos;
                                                            else
                                                                atPos = find(atValsGood == atValsUnique(at));
                                                            end

                                                                aePos = intersect(aPos,ePos);
                                                                aesPos = intersect(aePos,sPos);
                                                                aesfPos = intersect(aesPos,fPos);
                                                                aesfoPos = intersect(aesfPos,oPos);
                                                                aesfocPos = intersect(aesfoPos,cPos);
                                                                aesfoctPos = intersect(aesfocPos,tPos);
                                                                aesfoctaaPos = intersect(aesfoctPos,aaPos);
                                                                aesfoctaaasPos = intersect(aesfoctaaPos,asPos);
                                                                aesfoctaaasaoPos = intersect(aesfoctaaasPos,aoPos);
                                                                aesfoctaaasaoavPos = intersect(aesfoctaaasaoPos,avPos);
                                                                aesfoctaaasaoavatPos = intersect(aesfoctaaasaoavPos,atPos);
                                                                parameterCombinations{a,e,s,f,o,c,t,aa,as,ao,av,at} = aesfoctaaasaoavatPos; %#ok<AGROW>
                                                        end
                                                end
                                            end
                                        end
                                end
                        end
                    end
                end
            end
        end
    end
end

% save
save([folderOut 'parameterCombinations.mat'],'parameters','parameterCombinations', ...
    'aValsUnique','eValsUnique','sValsUnique','fValsUnique','oValsUnique','cValsUnique',...
    'tValsUnique','aaValsUnique','asValsUnique','aoValsUnique','avValsUnique','atValsUnique');
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

if useSingleITC18Flag
    outNum=outNum/2;
end
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
