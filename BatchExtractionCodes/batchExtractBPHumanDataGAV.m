function batchExtractBPHumanDataGAV(extractTheseIndices,extractProp,expProp,timeStartFromBaseLineList,deltaTList)

for iIndex = 1:length(extractTheseIndices)

    tic;
    clearvars -except extractTheseIndices extractProp expProp timeStartFromBaseLineList deltaTList iIndex;
    electrodesToStore = extractProp.electrodesToStore;
    ignoreTargetStimFlag = extractProp.ignoreTargetStimFlag;
    FsEye = extractProp.FsEye;
    frameRate = extractProp.frameRate;
    elecTypeVal = extractProp.elecTypeVal; 
    gridLayout = extractProp.gridLayout; 
    reallignElec = extractProp.reallignElec;
    reallignFlag = extractProp.reallignFlag; 
    badTrialsFlag = extractProp.badTrialsFlag;
    checkTheseElectrodesForBadTrials = extractProp.checkTheseElectrodesForBadTrials;
    thresholdBadTrials = extractProp.thresholdBadTrials; 
    saveBadTrialsFlag = extractProp.saveBadTrialsFlag; 
    showTrialsBadTrials = extractProp.showTrialsBadTrials;
    Lims = extractProp.Lims;
    notchLineNoise = extractProp.notchLineNoise;
    reRefFlag = extractProp.reRefFlag; 
    refElec = extractProp.refElec;
    LJData = extractProp.LJData;
    auxElectrodesToStore = extractProp.auxElectrodesToStore;
    FsLJ = extractProp.FsLJ;
    
    subjectName = expProp.subjectNames{extractTheseIndices(iIndex)};
    expDate = expProp.expDates{extractTheseIndices(iIndex)};
    protocolName = expProp.protocolNames{extractTheseIndices(iIndex)};
    deviceName = expProp.deviceNames{extractTheseIndices(iIndex)};
    gridType = 'EEG'; folderSourceString = 'D:';
    type = expProp.stimTypes{extractTheseIndices(iIndex)};
    deltaT = deltaTList(type);
    timeStartFromBaseLine = timeStartFromBaseLineList(type);

    dataLog{1,2} = subjectName;
    dataLog{2,2} = gridType;
    dataLog{3,2} = expDate;
    dataLog{4,2} = protocolName;
    dataLog{14,2} = folderSourceString;

    if strcmp(deviceName,'BR')
        disp('This index corresponds to BR data. Hence aborting extraction of this index.');
        elapsedTime = toc/60;
        disp([char(10) 'Total time taken: ' num2str(elapsedTime) ' min.']);
        disp('dataLog not saved');
        return;
    elseif strcmp(deviceName,'BP')
        FsBP=2500;
    end
    
    if gridLayout == 1             
        elecType = 'easyCap64';
    elseif gridLayout == 2
        elecType = 'actiCap64';
    else
        elecType = 'others';
    end
    
    if ~isempty(reallignElec)
        ainpSelect = ['ainp' reallignElec];
    else
        ainpSelect = '';
    end
    
    if LJData ~= 1; LJData = 0; end;
    if reallignFlag ~= 1; reallignFlag = 0; end;
    if badTrialsFlag ~= 1; badTrialsFlag = 0; end;
    if saveBadTrialsFlag ~= 1; saveBadTrialsFlag = 0; end;
    if reRefFlag ~= 1; reRefFlag = 0; end;

    [~,folderName]=getFolderDetails(dataLog);
    folderExtract = fullfile(folderName,'extractedData');
    makeDirectory(folderName)
    diary(fullfile(folderName,'ExtractionReport.txt'));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Get Digital Data

    % Step 1 - extract the digital data from a particular data acquisition
    % system. Each data acquisition system has a different program. 
    % This step creates extractedData folder and NEVFileInfo.mat

    disp('Saving digital data from neural files...');
    if strcmpi(deviceName,'BR') || strcmpi(deviceName,'Blackrock')        % Blackrock
            disp([char(10) 'Device name: BlackRock']);
            [hFile,digitalTimeStamps,digitalEvents]=extractDigitalDataBlackrock(subjectName,expDate,protocolName,folderSourceString,gridType);
            saveDigitalData(digitalEvents,digitalTimeStamps,folderExtract);
    elseif strcmpi(deviceName,'BP') || strcmpi(deviceName,'BrainProducts')  % BrainProducts
            disp([char(10) 'Device name: BrainProducts']);
            try
                [digitalTimeStamps,digitalEvents]=extractDigitalDataBrainProducts(subjectName,expDate,protocolName,folderSourceString,gridType);
                saveDigitalData(digitalEvents,digitalTimeStamps,folderExtract);
                bpFlag = 1;
            catch err
                disp('Brain Products file not found or data could not be extracted from brain products file.');
                disp('Specific Error: ')
                disp(err);
                bpFlag = 0;
            end
    end

    % Step 2 - Save digital information in a common format.
    % This step creates digitalEvents.mat
%     saveDigitalData(digitalEvents,digitalTimeStamps,folderExtract);

    % Integrate digital information

    % Step 1 - Get Lablib LL Data
    % This step creates LL.mat

    try
        disp([char(10) 'Saving LL Data...'])        
        LLFileExistsFlag = saveLLDataGAV(subjectName,expDate,protocolName,folderSourceString,gridType); % Save stimulus information using Lablib data
        disp('LL Data saved')        
    catch err
        LLFileExistsFlag = 0;
        disp('No LL data file!!');
        disp('Specific Error: ')
        disp(err);
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
            if bpFlag
                figure; displayTSTEComparison(folderExtract);
                else
                    disp('Brain Products file not found or data could not be extracted from brain products file.');
                    disp('Hence TSTE comparison could not be done.');
            end
            if strncmpi(protocolName,'GAV',3)                
                [goodStimNums,goodStimTimes,side] = extractDigitalDataGAVLL(folderExtract,ignoreTargetStimFlag,frameRate);
            elseif strncmpi(protocolName,'GRF',3)
                [goodStimNums,goodStimTimes,side] = extractDigitalDataGRFLL(folderExtract,ignoreTargetStimFlag,frameRate);
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
    
    % Get Ainp data for realigning of trials

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
                timeStartFromBaseLine,deltaT,FsBR,hFile,getLFP,getSpikes,1);

        elseif strcmpi(deviceName,'BP') || strcmpi(deviceName,'BrainProducts')  % BrainProducts
            try
                getAuxDataLabjack(subjectName,expDate,protocolName,folderSourceString,gridType,goodStimTimes,timeStartFromBaseLine,deltaT,auxElectrodesToStore,1);
                LJData = 1;
            catch err
                disp('Labjack data could not be read or not available.');
                LJData = 0;
                disp('Specific Error: ')
                disp(err);
            end
        end

        % Step 2: Get time differences
        getStimStartTimes(dataLog,ainpSelect,6,1);
    end

    % Save Analog and Spike Data
    disp([char(10) 'Saving Analog and Spike Data...']);    
    disp('Saving Analog and Spike Data based on LL Data!!');   
    
    if strcmpi(deviceName,'BR') || strcmpi(deviceName,'Blackrock')        % Blackrock
        
        analogChannelsToStore = electrodesToStore;
        neuralChannelsToStore = analogChannelsToStore;
        getLFP=1;getSpikes=0;

        [electrodeNums,elecSampleRate,AinpSampleRate] = getLFPandSpikesBlackrock(dataLog,folderSourceString,analogChannelsToStore,neuralChannelsToStore,...
        timeStartFromBaseLine,deltaT,FsBR,hFile,getLFP,getSpikes,1);        
        if ~isempty(ainpSelect)
            getStimStartTimes(dataLog,ainpSelect,6,0);
        end
        
    elseif strcmpi(deviceName,'BP') || strcmpi(deviceName,'BrainProducts')  % BrainProducts   
        clear goodStimNums goodStimTimes side;
        load(fullfile(folderExtract,'goodStimNums.mat'));
        if bpFlag
            electrodesStored = getEEGDataBrainProducts(subjectName,expDate,protocolName,folderSourceString,gridType,goodStimTimes,timeStartFromBaseLine,deltaT,notchLineNoise,reRefFlag,refElec);
        else
            disp('Brain Products file not found or data could not be extracted from brain products file.');
        end
        if LJData
            try
                getAuxDataLabjack(subjectName,expDate,protocolName,folderSourceString,gridType,goodStimTimes,timeStartFromBaseLine,deltaT,auxElectrodesToStore,0);
                LJData = 1;
            catch err
                disp('Labjack data could not be read or not available.');
                LJData = 0;
                disp('Specific Error: ')
                disp(err);
            end
            if ~isempty(ainpSelect)
                getStimStartTimes(dataLog,ainpSelect,6,0);
            end
        end
    end
    
    % Save a log of the extraction for further analyses

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

    dataLog(9,1)=cellstr('elecSampleRate');
    dataLog(10,1)=cellstr('AinpSampleRate');
    
    if strcmp(deviceName,'BR')
        dataLog{7,2}=electrodeNums;
        dataLog(9,2)={elecSampleRate};
        dataLog(10,2)={AinpSampleRate};
    elseif strcmp(deviceName,'BP')
        dataLog{7,2}=electrodesStored;
        dataLog(9,2)={FsBP};
        if LJData
            dataLog(10,2)={FsLJ};
        else
            dataLog{10,2}=[];
        end
    end
    
    if (~isempty(dataLog{7,2})) && badTrialsFlag
        if isempty(Lims); Lims = [-100 100]; end
        [allBadTrials, badTrials, nameElec] = findBadTrialsEEG_GAV(dataLog,checkTheseElectrodesForBadTrials,thresholdBadTrials,Lims(2),Lims(1),saveBadTrialsFlag,showTrialsBadTrials);
        dataLog(8,2)={badTrials};
    else
        dataLog(8,2)={[]};
    end
    

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
    dataLog{15,1} = 'Montage';
    dataLog{15,2} = elecType;
    dataLog{16,1} = 'Re-Ref Elec';
    
    if reRefFlag
        dataLog{16,2} = ['elec' num2str(refElec)];
    else
        dataLog{16,2} = 'None';
    end

    save(fullfile(folderName,'dataLog.mat'), 'dataLog');

    dataLog

    elapsedTime = toc/60;
    disp([char(10) 'Total time taken for extraction: ' num2str(elapsedTime) ' min.']);
    disp(['dataLog saved to ' folderName '\dataLog.mat']);
    disp(['Extraction report saved to ' folderName '\ExtractionReport.txt']);
    diary('off');
    assignin('base','dataLog',dataLog);
end
    
end
