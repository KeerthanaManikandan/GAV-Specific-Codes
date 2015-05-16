% runExtractAllDataGAVOld
% Original file modified by Murty V P S Dinavahi 13-09-2014
% newer modifications added by MD 17-04-2015
% BrainProducts code yet to be checked

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

electrodesToStore = [];
timeStartFromBaseLine = str2num(cell2mat(inputdlg('Time start from baseline:')));
deltaT = str2num(cell2mat(inputdlg('Total length:')));
    

[dataLog,folderName,elecSampleRate,AinpSampleRate] = extractAllDataGAVOld(subjectName,expDate,protocolName,folderSourceString,gridType,timeStartFromBaseLine,deltaT,electrodesToStore);
    
dataLog(8,1)=cellstr('badTrials');
if (~isempty(dataLog{7,2}))
    runFindBadTrials;
    dataLog(8,2)={badTrials};
else
    dataLog(8,2)={[]};
end
dataLog(9,1)=cellstr('elecSampleRate');
dataLog(9,2)={elecSampleRate};
dataLog(10,1)=cellstr('AinpSampleRate');
dataLog(10,2)={AinpSampleRate};

save([folderName 'dataLog.mat'], 'dataLog');

datFileName = [folderSourceString 'data\rawData\' subjectName expDate '\' subjectName expDate protocolName '.dat'];
