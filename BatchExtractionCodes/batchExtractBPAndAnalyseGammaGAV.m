function batchExtractBPAndAnalyseGammaGAV(varargin)

for iArg = 1:nargin

    extractTheseIndices = varargin{iArg};
    runBatchExtractBPHumanDataGAV(extractTheseIndices);
    
    if length(extractTheseIndices)>1
        dataLog = appendSameProtocolDifferentRunsEEG_GAV(extractTheseIndices);
    else 
        subjectName = 'Human'; gridType = 'EEG'; folderSourceString = 'D:';
        [subjectNames,expDates,protocolNames] = eval(['allProtocols' upper(subjectName(1)) subjectName(2:end) gridType]);
        clear subjectName
        
        subjectName = subjectNames{extractTheseIndices};
        expDate = expDates{extractTheseIndices};
        protocolName = protocolNames{extractTheseIndices};

        dataL{1,2} = subjectName;
        dataL{2,2} = gridType;
        dataL{3,2} = expDate;
        dataL{4,2} = protocolName;
        dataL{14,2} = folderSourceString;

        [~,folderName]=getFolderDetails(dataL);
        clear dataLog
        load(fullfile(folderName,'dataLog.mat'));
    end
    
    disp('Bipolar Referencing...');
    compareBandPowerPerProtocol(dataLog,[],[],[],[],[],'Bipolar');
    
    disp('Hemisphere Referencing...');
    compareBandPowerPerProtocol(dataLog,[],[],[],[],[],'Hemisphere');
    
end
    
end