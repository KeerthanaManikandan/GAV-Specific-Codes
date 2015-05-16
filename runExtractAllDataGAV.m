%% runExtractAllDataGAV
%
% Original file modified by Murty V P S Dinavahi 13-09-2014
% newer modifications added by MD 17-04-2015

%% Initialise

clc;
tic;
if  (~exist('dataLog','var'))
    fileType = {'Create New dataLog File','Open Existing dataLog File'};
    fileTypeIndex = listdlg('SelectionMode','single','ListString', fileType);
    if (fileTypeIndex == 1)
        subjectName = strjoin(inputdlg('subjectName'));
        expDate = strjoin(inputdlg('Experiment Date (ddmmyy):'));
        protocolName = strjoin(inputdlg('Protocol (ProtocolName_index):'));
        ElecList = {'EEG', 'Microelectrodes', 'ECoG'};
        gridTypeIndex = listdlg('PromptString','gridType:','SelectionMode','single','ListString', ElecList);
        gridType=strjoin(ElecList(gridTypeIndex));
        folderSourceString = 'D:\';
        dataLog = {'subjectName',subjectName;'gridType',gridType;'expDate',expDate;'protocolName',protocolName};
        clear ElecList;
        clear gridTypeIndex;
        clear folderName;
    else 
        uiopen;
        subjectName = strjoin(dataLog(1,2));
        gridType=strjoin(dataLog(2,2));
        folderSourceString = 'D:\';
        expDate = strjoin(dataLog(3,2));
        protocolName = strjoin(dataLog(4,2));
    end
    clear fileType;
    clear fileTypeIndex;
else
    subjectName = strjoin(dataLog(1,2));
    gridType=strjoin(dataLog(2,2));
    folderSourceString = 'D:\';
    expDate = strjoin(dataLog(3,2));
    protocolName = strjoin(dataLog(4,2));
end

ainpSelect = 'ainp5';
LLFlag=1;
LLExtractFlag=1;
reallignFlag = 0;
ignoreTargetStimFlag=1; % For GaborRFMap stimuli, set this to 1 if the program is run in the fixation mode.

electrodesToStore = [];
timeStartFromBaseLine = str2num(cell2mat(inputdlg('Time start from baseline:')));
deltaT = str2num(cell2mat(inputdlg('Total length:')));

frameRate=100;
deviceName = 'BP';
Fs=2000;

[~,folderName]=getFolderDetails(dataLog);
folderExtract = [folderName 'extractedData\'];

makeDirectory(folderName)
diary([folderName '\ExtractionReport.txt']);
        
%% Get Digital Data

% Step 1 - extract the digital data from a particular data acquisition
% system. Each data acquisition system has a different program. 
% This step creates extractedData folder and NEVFileInfo.mat

disp('Saving digital data from neural files...');
if strcmpi(deviceName,'BR') || strcmpi(deviceName,'Blackrock')        % Blackrock
        disp([char(10) 'Device name: BlackRock']);
        [hFile,digitalTimeStamps,digitalEvents]=extractDigitalDataBlackrock(subjectName,expDate,protocolName,folderSourceString,gridType);
elseif strcmpi(deviceName,'BP') || strcmpi(deviceName,'BrainProducts')  % BrainProducts
        disp([char(10) 'Device name: BrainProducts']);
        [digitalTimeStamps,digitalEvents]=extractDigitalDataBrainProducts(subjectName,expDate,protocolName,folderSourceString,gridType);
end
    
% Step 2 - Save digital information in a common format.
% This step creates digitalEvents.mat
saveDigitalData(digitalEvents,digitalTimeStamps,folderExtract);
    
    
%% Integrate digital information

% Step 1 - Get Lablib LL Data
% This step creates LL.mat
try
    disp([char(10) 'Saving LL Data...'])
    if LLExtractFlag
        LLFileExistsFlag = saveLLData(subjectName,expDate,protocolName,folderSourceString,gridType); % Save stimulus information using Lablib data
        disp('LL Data saved')
    else
        LLFileExistsFlag = 0;
    end
catch err
    LLFileExistsFlag = 0;
    disp('No LL data file!!');
end

if LLFileExistsFlag == 0    
    LLFlag = 0;
end

% Step 2 - extract digital information in a useful format, depending on the protocol.
% This step saves stimResults.mat, trialResults.mat,goodStimNums.mat and
% the LL versions if LLFlag=1
if strcmpi(deviceName,'BR') || strcmpi(deviceName,'Blackrock')        % Blackrock
    if strncmpi(protocolName,'GAV',3)
        disp([char(10) 'Extracting digital data for GAV Protocol...']);
        if LLFileExistsFlag
            disp([char(10) 'Extracting digital data from Lablib data file...']);
            extractDigitalDataGAVLL(folderExtract,ignoreTargetStimFlag,frameRate);
        end
        disp([char(10) 'Extracting digital data from .nev data file...']);
        extractDigitalDataGAV(folderExtract,ignoreTargetStimFlag,frameRate);
    elseif strncmpi(protocolName,'GRF',3)
        disp([char(10) 'Extracting digital data for GRF Protocol...']);
        if LLFileExistsFlag
            disp([char(10) 'Extracting digital data from Lablib data file...']);
            extractDigitalDataGRFLL(folderExtract,ignoreTargetStimFlag,frameRate);
        end
        disp([char(10) 'Extracting digital data from .nev data file...']);
        extractDigitalDataGRF(folderExtract,ignoreTargetStimFlag,frameRate);
    end
%     if LLFileExistsFlag
%         matchingParameters=compareLLwithNEV(folderExtract,activeSide,1); % Compare Lablib and digital file. If digital codes for stimulus paramaters are not sent, extract that information from Lablib
%         saveEyePositionAndBehaviorData(subjectName,expDate,protocolName,folderSourceString,gridType,FsEye); % As of now this works only if Target and Mapping stimuli have the same duration and ISI
%     end

elseif strcmpi(deviceName,'BP') || strcmpi(deviceName,'BrainProducts')  % BrainProducts
    if LLFileExistsFlag
        if strncmpi(protocolName,'GAV',3)
            displayTSTEComparison(folderExtract);
            extractDigitalDataGAVLL(folderExtract,ignoreTargetStimFlag,frameRate);
        elseif strncmpi(protocolName,'GRF',3)
            displayTSTEComparison(folderExtract);
            extractDigitalDataGRFLL(folderExtract,ignoreTargetStimFlag,frameRate);
        end
        %saveEyePositionAndBehaviorData(subjectName,expDate,protocolName,folderSourceString,gridType,FsEye); % As of now this works only if Target and Mapping stimuli have the same duration and ISI
    else
        error('With BrainProducts, digital codes cannot be obtained without Lablib File...');
    end
end

% Step 3 - generate 'parameterCombinations' that allows us to find the
    % useful combinations
if strncmpi(protocolName,'GAV',3)
    disp([char(10) 'Extracting Parameter combinations for GAV Protocol...']);
    getDisplayCombinationsGAV(folderExtract,0);
    if LLFlag
        disp([char(10) 'Extracting Parameter combinations for GAV Protocol using Lablib data...']);
        getDisplayCombinationsGAV(folderExtract,1);
    end
elseif strncmpi(protocolName,'GRF',3)
    disp([char(10) 'Extracting Parameter combinations for GRF Protocol...']);
    getDisplayCombinationsGRF(folderExtract,0);
    if LLFlag
        disp([char(10) 'Extracting Parameter combinations for GRF Protocol using Lablib data...']);
        getDisplayCombinationsGRF(folderExtract,1);
    end
end


%% Get Ainp data for realigning of trials

if reallignFlag
    
    % Step 1: Get data
    disp([char(10) 'Getting Ainp data for realigning of trials...']);
    if LLFlag == 0
        LLExtractFlag = 0;
    end
    if LLExtractFlag
        disp('Getting Ainp data based on LL Data!!');
    else
        disp('Getting Ainp data based on Neural Data!!');
    end
    if strcmpi(deviceName,'BR') || strcmpi(deviceName,'Blackrock')        % Blackrock        

        analogChannelsToStore = 'ainp';
        neuralChannelsToStore = analogChannelsToStore;
        getLFP=1;getSpikes=1;
        if (strcmp(gridType,'EEG')==1);
            getSpikes=0;
        end

        getLFPandSpikesBlackrock(dataLog,folderSourceString,analogChannelsToStore,neuralChannelsToStore,...
            timeStartFromBaseLine,deltaT,Fs,hFile,getLFP,getSpikes,LLExtractFlag);

    elseif strcmpi(deviceName,'BP') || strcmpi(deviceName,'BrainProducts')  % BrainProducts

        getEEGDataBrainProducts(subjectName,expDate,protocolName,folderSourceString,gridType,goodStimTimes,timeStartFromBaseLine,deltaT);
    end

    % Step 2: Get time differences
    getStimStartTimes(dataLog,ainpSelect,6,1);
end


%% Save Analog and Spike Data

disp([char(10) 'Saving Analog and Spike Data...']);
if LLFlag == 0
    LLExtractFlag = 0;
end
if LLExtractFlag
    disp('Saving Analog and Spike Data based on LL Data!!');
else
    disp('Saving Analog and Spike Data based on Neural Data!!');
end
if strcmpi(deviceName,'BR') || strcmpi(deviceName,'Blackrock')        % Blackrock        
    
    analogChannelsToStore = electrodesToStore;
    neuralChannelsToStore = analogChannelsToStore;
    getLFP=1;getSpikes=1;
    if (strcmp(gridType,'EEG')==1);
        getSpikes=0;
    end

    [electrodeNums,elecSampleRate,AinpSampleRate] = getLFPandSpikesBlackrock(dataLog,folderSourceString,analogChannelsToStore,neuralChannelsToStore,...
        timeStartFromBaseLine,deltaT,Fs,hFile,getLFP,getSpikes,LLExtractFlag);

elseif strcmpi(deviceName,'BP') || strcmpi(deviceName,'BrainProducts')  % BrainProducts

    getEEGDataBrainProducts(subjectName,expDate,protocolName,folderSourceString,gridType,goodStimTimes,timeStartFromBaseLine,deltaT);
end

getStimStartTimes(dataLog,ainpSelect,6,0);

%% Save a log of the extraction for further analyses

dataLog{1,1}='subjectName';
dataLog{5,1}='timeStartFromBaseLine';
dataLog{6,1}='deltaT';
dataLog{7,1}='electrodesToStore';
dataLog{8,1}='badTrials';

dataLog{5,2}=timeStartFromBaseLine;
dataLog{6,2}=deltaT;
dataLog{7,2}=electrodeNums;

if (~isempty(dataLog{7,2}))
    runFindBadTrialsGAV;
    dataLog(8,2)={badTrials};
else
    dataLog(8,2)={[]};
end
dataLog(9,1)=cellstr('elecSampleRate');
dataLog(9,2)={elecSampleRate};
dataLog(10,1)=cellstr('AinpSampleRate');
dataLog(10,2)={AinpSampleRate};

dataLog{11,1}='LLData';
if LLFileExistsFlag
    dataLog{11,2}='YES';
else
    dataLog{11,2}='NO';
end

dataLog{12,1}='LLExtract';
if LLFlag
    dataLog{12,2}='YES';
else
    dataLog{12,2}='NO';
end

dataLog{13,1}='Reallign';
if reallignFlag
    dataLog{13,2}='YES';
else
    dataLog{13,2}='NO';
end

save([folderName 'dataLog.mat'], 'dataLog');

dataLog

elapsedTime = toc/60;
disp([char(10) 'Total time taken for extraction: ' num2str(elapsedTime) ' min.']);
disp(['dataLog saved to ' folderName 'dataLog.mat']);
disp(['Extraction report saved to ' folderName 'ExtractionReport.txt']);
diary('off');
