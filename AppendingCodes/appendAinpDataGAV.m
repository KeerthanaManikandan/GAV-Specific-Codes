function appendAinpDataGAV(totAinpNum,extractTheseIndices)

subjectName = 'Human'; gridType = 'EEG'; folderSourceString = 'D:';
[subjectNames,expDates,protocolNames,stimTypes,deviceNames] = eval(['allProtocols' upper(subjectName(1)) subjectName(2:end) gridType]);
clear subjectName

hWElec = waitbar(0,'Concatenating data for electrode 1');
for iAC = 1:totAinpNum
    waitbar(iAC/totAinpNum,hWElec,['Concatenating data for Ainp ' num2str(iAC)]);
    
    analogDataFinal = [];
    for iV = 1:length(extractTheseIndices)
        
        clear iIndex
        iIndex = extractTheseIndices(iV);

        clear subjectName expDate protocolName dataLog folderName folderExtract folderLFP analogChannelsStored
        subjectName = subjectNames{iIndex};
        expDate = expDates{iIndex};
        protocolName = protocolNames{iIndex};
        dataLog{1,2} = subjectName; dataLog{2,2} = gridType; dataLog{3,2} = expDate; dataLog{4,2} = protocolName; dataLog{14,2} = folderSourceString;
        [~,folderName,folderNameDate]=getFolderDetails(dataLog);
        
        folderLFP = fullfile(folderName,'segmentedData','LFP');

        [analogChannelsStored,timeVals,goodStimPos,analogInputNums,electrodesStored] = loadlfpInfo(folderLFP);

        clear analogDataPath analogData 
        analogDataPath = fullfile(folderLFP,['ainp' num2str(analogChannelsStored(iAC)) '.mat']);
        try
            analogData = loadAnalogData(analogDataPath);
        catch
            disp(['Total analog channels: ' num2str(iAC-1)]);
            close(hWElec);
            return
        end
        analogDataFinal = [analogDataFinal;analogData];
    end
    
    folderConcatenated = fullfile(folderNameDate,'GAV_concatenatedData');
    folderConcLFP = fullfile(folderConcatenated,'segmentedData','LFP');    
    makeDirectory(folderConcatenated);
    makeDirectory(folderConcLFP);
    
    clear analogData
    analogData = analogDataFinal;
    save(fullfile(folderConcLFP,['ainp' num2str(analogChannelsStored(iAC)) '.mat']),'analogData');
end
close(hWElec);
end