function extractHumanDataGAV

close all; clear all; clc;
% tic;

timeStartFromBaseLineList(1) = -0.55; deltaTList(1) = 1.024; % in seconds
timeStartFromBaseLineList(2) = -1.148; deltaTList(2) = 2.048;
timeStartFromBaseLineList(3) = -1.5; deltaTList(3) = 4.096;
timeStartFromBaseLineList(4) = -1; deltaTList(4) = 3;
timeStartFromBaseLineList(5) = -0.524; deltaTList(5) = 2.048;

% FsEye=200; % This is set by Lablib, not by the Eye tracking system

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if ~exist('extractTheseIndices','var')
    extractTheseIndices = str2num(cell2mat(inputdlg('Index')));
% end

subjectName = 'Human'; gridType = 'EEG'; folderSourceString = 'D:';
[subjectNames,expDates,protocolNames,stimTypes,deviceNames] = eval(['allProtocols' upper(subjectName(1)) subjectName(2:end) gridType]);
clear subjectName

i = 1;

subjectName = subjectNames{extractTheseIndices(i)};
expDate = expDates{extractTheseIndices(i)};
protocolName = protocolNames{extractTheseIndices(i)};
deviceName = deviceNames{extractTheseIndices(i)};

type = stimTypes{extractTheseIndices(i)};
deltaT = deltaTList(type);
timeStartFromBaseLine = timeStartFromBaseLineList(type);

dataLog{1,2} = subjectName;
dataLog{2,2} = gridType;
dataLog{3,2} = expDate;
dataLog{4,2} = protocolName;
dataLog{14,2} = folderSourceString;

clear i;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display main options
% fonts
fontSizeSmall = 10; fontSizeMedium = 12; fontSizeLarge = 16; fontSizeTiny = 8;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Panels
edPanelStartX = 0.01; edPanelStartY = 0.65; edPanelWidth = 0.49; edPanelHeight = 0.3;
extdPanelStartX = 0.01; extdPanelStartY = 0.5; extdPanelWidth = 0.49; extdPanelHeight = 0.14;
SetupPanelStartX = 0.51; SetupPanelStartY = 0.5; SetupPanelWidth = 0.48; SetupPanelHeight = 0.45;
PrepPanelStartX = 0.01; PrepPanelStartY = 0.01; PrepPanelWidth = 0.49; PrepPanelHeight = 0.45;

labelStartX = 0.01; labelStartY = 0.01; labelWidth = 0.49; labelHeight = 0.2; setupLabelHeight = 0.1; prepLabelHeight = 0.075;

backgroundColor = 'w';

figure(879);

uicontrol('Unit','Normalized', ...
        'Position',[0.01 0.96 0.98 0.04],...
        'Style','text','String','Extract human EEG data','FontSize',fontSizeLarge);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% Experiment Details Panel %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hEDPanel = uipanel('Title','Exp. Details','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[edPanelStartX edPanelStartY edPanelWidth edPanelHeight]);

uicontrol('Parent',hEDPanel,'Unit','Normalized', ...
    'Position',[labelStartX labelStartY+3*labelHeight labelWidth labelHeight],...
    'Style','text','String','Subject Name:','FontSize',fontSizeMedium);
uicontrol('Parent',hEDPanel,'Unit','Normalized', ...
    'BackgroundColor',backgroundColor,'Position',[labelStartX+labelWidth labelStartY+3*labelHeight labelWidth labelHeight],...
    'Style','text','String',subjectName,'FontSize',fontSizeMedium);

uicontrol('Parent',hEDPanel,'Unit','Normalized', ...
    'Position',[labelStartX labelStartY+2*labelHeight labelWidth labelHeight],...
    'Style','text','String','Experiment Date:','FontSize',fontSizeMedium);
uicontrol('Parent',hEDPanel,'Unit','Normalized', ...
    'BackgroundColor',backgroundColor,'Position',[labelStartX+labelWidth labelStartY+2*labelHeight labelWidth labelHeight],...
    'Style','text','String',expDate,'FontSize',fontSizeMedium);

uicontrol('Parent',hEDPanel,'Unit','Normalized', ...
    'Position',[labelStartX labelStartY+1*labelHeight labelWidth labelHeight],...
    'Style','text','String','Protocol Name:','FontSize',fontSizeMedium);
uicontrol('Parent',hEDPanel,'Unit','Normalized', ...
    'BackgroundColor',backgroundColor,'Position',[labelStartX+labelWidth labelStartY+1*labelHeight labelWidth labelHeight],...
    'Style','text','String',protocolName,'FontSize',fontSizeMedium);

uicontrol('Parent',hEDPanel,'Unit','Normalized', ...
    'Position',[labelStartX labelStartY labelWidth labelHeight],...
    'Style','text','String','Montage:','FontSize',fontSizeMedium);
hMontage = uicontrol('Parent',hEDPanel,'Unit','Normalized', ...
    'BackgroundColor',backgroundColor,'Position',[labelStartX+labelWidth labelStartY labelWidth labelHeight],...
    'Style','popup','String','actiCap64|easyCap64|others','FontSize',fontSizeMedium,'Callback',{@resetMontage_Callback});



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% Extraction Details Panel %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hExtDPanel = uipanel('Title','Extraction Details','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[extdPanelStartX extdPanelStartY extdPanelWidth extdPanelHeight]);

uicontrol('Parent',hExtDPanel,'Unit','Normalized', ...
    'Position',[labelStartX labelStartY+labelHeight*3 labelWidth labelHeight*2],...
    'Style','text','String','Start Time from Stimulus Onset (s):','FontSize',fontSizeMedium);
uicontrol('Parent',hExtDPanel,'Unit','Normalized', ...
    'BackgroundColor',backgroundColor,'Position',[labelStartX+labelWidth labelStartY+labelHeight*3 labelWidth labelHeight*2],...
    'Style','text','String',timeStartFromBaseLine,'FontSize',fontSizeMedium);

uicontrol('Parent',hExtDPanel,'Unit','Normalized', ...
    'Position',[labelStartX labelStartY labelWidth labelHeight*2],...
    'Style','text','String','Total Length (s):','FontSize',fontSizeMedium);
uicontrol('Parent',hExtDPanel,'Unit','Normalized', ...
    'BackgroundColor',backgroundColor,'Position',[labelStartX+labelWidth labelStartY labelWidth labelHeight*2],...
    'Style','text','String',deltaT,'FontSize',fontSizeMedium);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Setup Panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hSetupPanel = uipanel('Title','Rig Setup','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[SetupPanelStartX SetupPanelStartY SetupPanelWidth SetupPanelHeight]);

uicontrol('Parent',hSetupPanel,'Unit','Normalized', ...
    'Position',[labelStartX labelStartY+8*setupLabelHeight labelWidth setupLabelHeight],...
    'Style','text','String','Eye tracker Fs (Hz):','FontSize',fontSizeMedium);
hFsEye = uicontrol('Parent',hSetupPanel,'Unit','Normalized', ...
    'BackgroundColor',backgroundColor,'Position',[labelStartX+labelWidth labelStartY+8*setupLabelHeight labelWidth setupLabelHeight],...
    'Style','edit','String','200','FontSize',fontSizeMedium);

uicontrol('Parent',hSetupPanel,'Unit','Normalized', ...
    'Position',[labelStartX labelStartY+7*setupLabelHeight labelWidth setupLabelHeight],...
    'Style','text','String','Frame Rate (Hz):','FontSize',fontSizeMedium);
hFrameRate = uicontrol('Parent',hSetupPanel,'Unit','Normalized', ...
    'BackgroundColor',backgroundColor,'Position',[labelStartX+labelWidth labelStartY+7*setupLabelHeight labelWidth setupLabelHeight],...
    'Style','edit','String','100','FontSize',fontSizeMedium);

uicontrol('Parent',hSetupPanel,'Unit','Normalized', ...
    'Position',[labelStartX labelStartY+5*setupLabelHeight labelWidth setupLabelHeight],...
    'Style','text','String','Device Name:','FontSize',fontSizeMedium);
hDeviceName = uicontrol('Parent',hSetupPanel,'Unit','Normalized', ...
    'BackgroundColor',backgroundColor,'Position',[labelStartX+labelWidth labelStartY+5*setupLabelHeight labelWidth setupLabelHeight],...
    'Style','text','String',deviceName,'FontSize',fontSizeMedium);

uicontrol('Parent',hSetupPanel,'Unit','Normalized', ...
    'Position',[labelStartX labelStartY+4*setupLabelHeight labelWidth setupLabelHeight],...
    'Style','text','String','Device Fs (Hz):','FontSize',fontSizeMedium);

if strcmp(deviceName,'BR')
    hDeviceFs = uicontrol('Parent',hSetupPanel,'Unit','Normalized', ...
        'BackgroundColor',backgroundColor,'Position',[labelStartX+labelWidth labelStartY+4*setupLabelHeight labelWidth setupLabelHeight],...
        'Style','edit','String','2000','FontSize',fontSizeMedium);
elseif strcmp(deviceName,'BP')   
    hDeviceFs = uicontrol('Parent',hSetupPanel,'Unit','Normalized', ...
        'BackgroundColor',backgroundColor,'Position',[labelStartX+labelWidth labelStartY+4*setupLabelHeight labelWidth setupLabelHeight],...
        'Style','edit','String','2500','FontSize',fontSizeMedium);

    uicontrol('Parent',hSetupPanel,'Unit','Normalized', ...
        'Position',[labelStartX labelStartY+2*setupLabelHeight labelWidth setupLabelHeight],...
        'Style','text','String','LabJack Data:','FontSize',fontSizeMedium);
    hLJData = uicontrol('Parent',hSetupPanel,'Unit','Normalized', ...
        'BackgroundColor',backgroundColor,'Position',[labelStartX+labelWidth labelStartY+2*setupLabelHeight labelWidth setupLabelHeight],...
        'Style','popup','String','Yes|No','FontSize',fontSizeMedium);

    uicontrol('Parent',hSetupPanel,'Unit','Normalized', ...
        'Position',[labelStartX labelStartY+1*setupLabelHeight labelWidth setupLabelHeight],...
        'Style','text','String','LabJack Channels:','FontSize',fontSizeMedium);
    hLJChannels = uicontrol('Parent',hSetupPanel,'Unit','Normalized', ...
        'BackgroundColor',backgroundColor,'Position',[labelStartX+labelWidth labelStartY+1*setupLabelHeight labelWidth setupLabelHeight],...
        'Style','edit','String','1:3','FontSize',fontSizeMedium);

    uicontrol('Parent',hSetupPanel,'Unit','Normalized', ...
        'Position',[labelStartX labelStartY labelWidth setupLabelHeight],...
        'Style','text','String','LabJack Fs (Hz):','FontSize',fontSizeMedium);
    hLJFs = uicontrol('Parent',hSetupPanel,'Unit','Normalized', ...
        'BackgroundColor',backgroundColor,'Position',[labelStartX+labelWidth labelStartY labelWidth setupLabelHeight],...
        'Style','edit','String','2500','FontSize',fontSizeMedium);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Prepocessing Panel %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hPrepPanel = uipanel('Title','Preprocessing','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[PrepPanelStartX PrepPanelStartY PrepPanelWidth PrepPanelHeight]);

uicontrol('Parent',hPrepPanel,'Unit','Normalized', ...
        'Position',[labelStartX labelStartY+12*prepLabelHeight labelWidth prepLabelHeight],...
        'Style','text','String','Re-allign data to stimulus onset:','FontSize',fontSizeSmall);
hReallign = uicontrol('Parent',hPrepPanel,'Unit','Normalized', ...
    'BackgroundColor',backgroundColor,'Position',[labelStartX+labelWidth labelStartY+12*prepLabelHeight labelWidth prepLabelHeight],...
    'Style','popup','String','Yes|No','FontSize',fontSizeSmall);

uicontrol('Parent',hPrepPanel,'Unit','Normalized', ...
        'Position',[labelStartX labelStartY+11*prepLabelHeight labelWidth prepLabelHeight],...
        'Style','text','String','Reallign using analog electrode:','FontSize',fontSizeSmall);
hReallignElec = uicontrol('Parent',hPrepPanel,'Unit','Normalized', ...
    'BackgroundColor',backgroundColor,'Position',[labelStartX+labelWidth labelStartY+11*prepLabelHeight labelWidth prepLabelHeight],...
    'Style','edit','FontSize',fontSizeSmall);

uicontrol('Parent',hPrepPanel,'Unit','Normalized', ...
        'Position',[labelStartX labelStartY+9*prepLabelHeight labelWidth prepLabelHeight],...
        'Style','text','String','Apply Notch Filter:','FontSize',fontSizeSmall);
hNotchFilter = uicontrol('Parent',hPrepPanel,'Unit','Normalized', ...
    'BackgroundColor',backgroundColor,'Position',[labelStartX+labelWidth labelStartY+9*prepLabelHeight labelWidth prepLabelHeight],...
    'Style','popup','String','No|Yes','FontSize',fontSizeSmall);

uicontrol('Parent',hPrepPanel,'Unit','Normalized', ...
        'Position',[labelStartX labelStartY+7*prepLabelHeight labelWidth prepLabelHeight],...
        'Style','text','String','Re-reference data:','FontSize',fontSizeSmall);
hReRef = uicontrol('Parent',hPrepPanel,'Unit','Normalized', ...
    'BackgroundColor',backgroundColor,'Position',[labelStartX+labelWidth labelStartY+7*prepLabelHeight labelWidth prepLabelHeight],...
    'Style','popup','String','Yes|No','FontSize',fontSizeSmall);

uicontrol('Parent',hPrepPanel,'Unit','Normalized', ...
        'Position',[labelStartX labelStartY+6*prepLabelHeight labelWidth prepLabelHeight],...
        'Style','text','String','Electrode for Re-referencing:','FontSize',fontSizeSmall);
hReRefElec = uicontrol('Parent',hPrepPanel,'Unit','Normalized', ...
    'BackgroundColor',backgroundColor,'Position',[labelStartX+labelWidth labelStartY+6*prepLabelHeight labelWidth prepLabelHeight],...
    'Style','edit','FontSize',fontSizeSmall);

uicontrol('Parent',hPrepPanel,'Unit','Normalized', ...
        'Position',[labelStartX labelStartY+4*prepLabelHeight labelWidth prepLabelHeight],...
        'Style','text','String','Reject Bad Trials:','FontSize',fontSizeSmall);
hRejectBT = uicontrol('Parent',hPrepPanel,'Unit','Normalized', ...
    'BackgroundColor',backgroundColor,'Position',[labelStartX+labelWidth labelStartY+4*prepLabelHeight labelWidth prepLabelHeight],...
    'Style','popup','String','Yes|No','FontSize',fontSizeSmall);

uicontrol('Parent',hPrepPanel,'Unit','Normalized', ...
        'Position',[labelStartX labelStartY+3*prepLabelHeight labelWidth prepLabelHeight],...
        'Style','text','String','Check Electrodes for Bad Trials:','FontSize',fontSizeSmall);
hCheckElecsBT = uicontrol('Parent',hPrepPanel,'Unit','Normalized', ...
    'BackgroundColor',backgroundColor,'Position',[labelStartX+labelWidth labelStartY+3*prepLabelHeight labelWidth prepLabelHeight],...
    'Style','edit','FontSize',fontSizeSmall);

uicontrol('Parent',hPrepPanel,'Unit','Normalized', ...
        'Position',[labelStartX labelStartY+2*prepLabelHeight labelWidth prepLabelHeight],...
        'Style','text','String','Threshold for Bad Trials:','FontSize',fontSizeSmall);
hThresholdBT = uicontrol('Parent',hPrepPanel,'Unit','Normalized', ...
    'BackgroundColor',backgroundColor,'Position',[labelStartX+labelWidth labelStartY+2*prepLabelHeight labelWidth prepLabelHeight],...
    'Style','edit','String','6','FontSize',fontSizeSmall);

uicontrol('Parent',hPrepPanel,'Unit','Normalized', ...
        'Position',[labelStartX labelStartY+1*prepLabelHeight labelWidth prepLabelHeight],...
        'Style','text','String','Save Bad Trials:','FontSize',fontSizeSmall);
hSaveBT = uicontrol('Parent',hPrepPanel,'Unit','Normalized', ...
    'BackgroundColor',backgroundColor,'Position',[labelStartX+labelWidth labelStartY+1*prepLabelHeight labelWidth prepLabelHeight],...
    'Style','popup','String','Yes|No','FontSize',fontSizeSmall);

uicontrol('Parent',hPrepPanel,'Unit','Normalized', ...
        'Position',[labelStartX labelStartY labelWidth prepLabelHeight],...
        'Style','text','String','Show Bad Trials:','FontSize',fontSizeSmall);
hShowBT = uicontrol('Parent',hPrepPanel,'Unit','Normalized', ...
    'BackgroundColor',backgroundColor,'Position',[labelStartX+labelWidth labelStartY labelWidth prepLabelHeight],...
    'Style','popup','String','No|Yes','FontSize',fontSizeSmall);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Electrode Locations %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gridStartX = SetupPanelStartX; gridStartY = 0.1; gridWidth = SetupPanelWidth; gridHeight = PrepPanelStartY + PrepPanelHeight - gridStartY;
electrodeGridPos = [gridStartX gridStartY gridWidth gridHeight];

montage = get(hMontage,'val');
gridLayout = getGridLayout(montage);
hElectrodes = showElectrodeLocations(electrodeGridPos,[], ...
    'y',[],1,0,gridType,subjectName,gridLayout);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Extract button %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pushStartX = SetupPanelStartX; pushStartY = PrepPanelStartY; pushWidth = gridWidth; pushHeight = 0.08;
uicontrol('Unit','Normalized', ...
    'Position',[pushStartX pushStartY pushWidth pushHeight], ...
    'Style','pushbutton','String','Start Extraction','FontSize',fontSizeMedium, ...
    'Callback',{@extractData_Callback});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function extractData_Callback (~,~)
        tic;
        FsEye = str2double(get(hFsEye,'string'));
        electrodesToStore = []; % If left empty, all electrodes are stored
        
        ignoreTargetStimFlag=1; % For GaborRFMap stimuli, set this to 1 if the program is run in the fixation mode. 
        frameRate=str2double(get(hFrameRate,'string'));
        
        if strcmp(deviceName,'BR')
            FsBR=str2double(get(hDeviceFs,'string'));
        elseif strcmp(deviceName,'BP')
            FsBP=str2double(get(hDeviceFs,'string'));
        end
        
        LJData = get(hLJData,'val');
        if LJData ~= 1; LJData = 0; end;
        auxElectrodesToStore = str2num(get(hLJChannels,'string')); % only for Labjack data
        FsLJ = str2double(get(hLJFs,'string'));

        elecTypeVal = get(hMontage,'val');
        gridLayout = getGridLayout(elecTypeVal);
        if gridLayout == 1             
            elecType = 'easyCap64';
        elseif gridLayout == 2
            elecType = 'actiCap64';
        else
            elecType = 'others';
        end
        
        reallignElec = get(hReallignElec,'string');
        if ~isempty(reallignElec)
            ainpSelect = ['ainp' reallignElec];
        else
            ainpSelect = '';
        end
        reallignFlag = get(hReallign,'val'); if reallignFlag ~= 1; reallignFlag = 0; end;
        
        badTrialsFlag = get(hRejectBT,'val'); if badTrialsFlag ~= 1; badTrialsFlag = 0; end;
        checkTheseElectrodesForBadTrials = str2num(get(hCheckElecsBT,'string')); 
        thresholdBadTrials=str2num(get(hThresholdBT,'string')); 
        saveBadTrialsFlag = get(hSaveBT,'val'); if saveBadTrialsFlag ~= 1; saveBadTrialsFlag = 0; end;
        showTrialsBadTrials = get(hShowBT,'val')-1;
        notchLineNoise = get(hNotchFilter,'val')-1;

        reRefFlag = get(hReRef,'val'); if reRefFlag ~= 1; reRefFlag = 0; end;
        refElec = str2num(get(hReRefElec,'string')); 
        
        [~,folderName]=getFolderDetails(dataLog);
        folderExtract = fullfile(folderName,'extractedData');
        makeDirectory(folderName)
        diary(fullfile(folderName,'ExtractionReport.txt'));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         %% Get Digital Data

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

    %% Save Analog and Spike Data
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
            getAuxDataLabjack(subjectName,expDate,protocolName,folderSourceString,gridType,goodStimTimes,timeStartFromBaseLine,deltaT,auxElectrodesToStore,0);
            if ~isempty(ainpSelect)
                getStimStartTimes(dataLog,ainpSelect,6,0);
            end
        end
    end
    
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
        Lims = str2num(cell2mat(inputdlg('Checking for bad trials. Please input [minLimit maxLimit]')));
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function resetMontage_Callback(~,~)
        clear montage;
        montage = get(hMontage,'val');
        gridLayout = getGridLayout(montage);
        cla(hElectrodes);
        hElectrodes = showElectrodeLocations(electrodeGridPos,[], ...
            'y',[],1,0,gridType,subjectName,gridLayout);

    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function gridLayout = getGridLayout(montage)
        if montage == 1
            gridLayout = 2; % actiCap 64 electrodes
        else
            gridLayout = 1; % easyCap 64 electrodes
        end
    end
end