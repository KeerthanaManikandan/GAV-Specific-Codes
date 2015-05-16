% runExtractHumanDataGAV
% This is the main program for doing all data extraction.

% Each data file is identified by the following
% 1. subjectName
% 2. expDate - date of the experiment
% 3. protocolName - name of the protocol
% 4. gridType - Microelectrode, ECoG, EEG etc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Once proper data collection begins, a separate file called
% allProtocols{subjectName}{gridType} is created in
% \Programs\DataMAP\SubjectData. This file has a list of three parameters -
% expDate, protocolName and stimType. stimType is a number that describes
% the duration of the signal around each stimulus onset that needs to be
% extracted (given by timeStartFromBaseLineList and deltaTList). The
% following nomenclature is used: 

% stimType = 1; % stim On - 200 ms, stim Off - 300 ms. Used for RF mapping
% stimType = 2; % stim On - 400 ms, stim Off - 600 ms.
% stimType = 3; % stim On - 1500 ms, stim Off - 1500 ms.

%% Initialise
clear; clc;
tic;

timeStartFromBaseLineList(1) = -0.55; deltaTList(1) = 1.024; % in seconds
timeStartFromBaseLineList(2) = -1.148; deltaTList(2) = 2.048;
timeStartFromBaseLineList(3) = -1.5; deltaTList(3) = 4.096;

timeStartFromBaseLineList(4) = -1; deltaTList(4) = 3;

FsEye=200; % This is set by Lablib, not by the Eye tracking system

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
extractTheseIndices = str2num(cell2mat(inputdlg('Index')));

subjectName = 'Human'; gridType = 'EEG'; folderSourceString = 'D:';
[subjectNames,expDates,protocolNames,stimTypes] = eval(['allProtocols' upper(subjectName(1)) subjectName(2:end) gridType]);
clear subjectName

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
electrodesToStore = []; % If left empty, all electrodes are stored
auxElectrodesToStore = 1:3; % only for Labjack data
ignoreTargetStimFlag=1; % For GaborRFMap stimuli, set this to 1 if the program is run in the fixation mode. 
frameRate=100;
Fs=2000;

deviceName = 'BR'; % BR: Blackrock, BP: BrainProducts, EGI: EGI

ainpSelect = 'ainp6';
reallignFlag = 1;



for i=1:length(extractTheseIndices)
    
    subjectName = subjectNames{extractTheseIndices(i)};
    expDate = expDates{extractTheseIndices(i)};
    protocolName = protocolNames{extractTheseIndices(i)};
    
    type = stimTypes{extractTheseIndices(i)};
    deltaT = deltaTList(type);
    timeStartFromBaseLine = timeStartFromBaseLineList(type);
    
    dataLog{1,2} = subjectName;
    dataLog{2,2} = gridType;
    dataLog{3,2} = expDate;
    dataLog{4,2} = protocolName;
    dataLog{14,2} = folderSourceString;
    
    [~,folderName]=getFolderDetails(dataLog);
    folderExtract = fullfile(folderName,'extractedData');

    makeDirectory(folderName)
    diary(fullfile(folderName,'ExtractionReport.txt'));
    

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
        LLFileExistsFlag = saveLLDataGAV(subjectName,expDate,protocolName,folderSourceString,gridType); % Save stimulus information using Lablib data
        disp('LL Data saved')        
    catch err
        LLFileExistsFlag = 0;
        disp('No LL data file!!');
    end
    
    % Step 2 - extract digital information in a useful format, depending on the protocol.
    % This step saves stimResults.mat, trialResults.mat,goodStimNums.mat
    if strcmpi(deviceName,'BR') || strcmpi(deviceName,'Blackrock')        % Blackrock
        if strncmpi(protocolName,'GAV',3)
            disp([char(10) 'Extracting digital data for GAV Protocol...']);            
                disp([char(10) 'Extracting digital data from Lablib data file...']);
                extractDigitalDataGAVLL(folderExtract,ignoreTargetStimFlag,frameRate);           
        elseif strncmpi(protocolName,'GRF',3)
            disp([char(10) 'Extracting digital data for GRF Protocol...']);            
                disp([char(10) 'Extracting digital data from Lablib data file...']);
                extractDigitalDataGRFLL(folderExtract,ignoreTargetStimFlag,frameRate);                        
        end
        
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
        disp([char(10) 'Extracting Parameter combinations for GAV Protocol using Lablib data...']);
        getDisplayCombinationsGAV(folderExtract);        
    elseif strncmpi(protocolName,'GRF',3)        
        disp([char(10) 'Extracting Parameter combinations for GRF Protocol using Lablib data...']);
        getDisplayCombinationsGRF(folderExtract,1);        
    end
    
    %% Get Ainp data for realigning of trials

    if reallignFlag

        % Step 1: Get data
        disp([char(10) 'Getting Ainp data for realigning of trials...']);           
        disp('Getting Ainp data based on LL Data!!');
        
        if strcmpi(deviceName,'BR') || strcmpi(deviceName,'Blackrock')        % Blackrock      
            analogChannelsToStore = 'ainp';
            neuralChannelsToStore = analogChannelsToStore;
            getLFP=1;getSpikes=1;
            if (strcmp(gridType,'EEG')==1);
                getSpikes=0;
            end
            getLFPandSpikesBlackrock(dataLog,folderSourceString,analogChannelsToStore,neuralChannelsToStore,...
                timeStartFromBaseLine,deltaT,Fs,hFile,getLFP,getSpikes,1);

        elseif strcmpi(deviceName,'BP') || strcmpi(deviceName,'BrainProducts')  % BrainProducts
            getEEGDataBrainProducts(subjectName,expDate,protocolName,folderSourceString,gridType,goodStimTimes,timeStartFromBaseLine,deltaT);
        end

        % Step 2: Get time differences
        getStimStartTimes(dataLog,ainpSelect,6,1);
    end

    %% Save Analog and Spike Data
    disp([char(10) 'Saving Analog and Spike Data...']);    
    disp('Saving Analog and Spike Data based on LL Data!!');   
    
    if strcmpi(deviceName,'BR') || strcmpi(deviceName,'Blackrock')        % Blackrock
        
        analogChannelsToStore = electrodesToStore;
        neuralChannelsToStore = analogChannelsToStore;
        getLFP=1;getSpikes=0;

        [electrodeNums,elecSampleRate,AinpSampleRate] = getLFPandSpikesBlackrock(dataLog,folderSourceString,analogChannelsToStore,neuralChannelsToStore,...
        timeStartFromBaseLine,deltaT,Fs,hFile,getLFP,getSpikes,1);
        
    elseif strcmpi(deviceName,'BP') || strcmpi(deviceName,'BrainProducts')  % BrainProducts        
        getEEGDataBrainProducts(subjectName,expDate,protocolName,folderSourceString,gridType,goodStimTimes,timeStartFromBaseLine,deltaT);
        getAuxDataLabjack(subjectName,expDate,protocolName,folderSourceString,gridType,goodStimTimes,timeStartFromBaseLine,deltaT,auxElectrodesToStore);
    end
    
    getStimStartTimes(dataLog,ainpSelect,6,0);
    
    %% Save a log of the extraction for further analyses

    dataLog{1,1}='subjectName';
    dataLog{2,1}='gridType';
    dataLog{3,1}='expDate';
    dataLog{4,1}='protocolName';    
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
    dataLog{11,2}='YES';   

    dataLog{12,1}='LLExtract';    
    dataLog{12,2}='YES';    

    dataLog{13,1}='Reallign';
    if reallignFlag
        dataLog{13,2}='YES';
    else
        dataLog{13,2}='NO';
    end
    
    dataLog{14,1} = 'folderSourceString';

    save(fullfile(folderName,'dataLog.mat'), 'dataLog');

    dataLog

    elapsedTime = toc/60;
    disp([char(10) 'Total time taken for extraction: ' num2str(elapsedTime) ' min.']);
    disp(['dataLog saved to ' folderName 'dataLog.mat']);
    disp(['Extraction report saved to ' folderName 'ExtractionReport.txt']);
    diary('off');
    
end