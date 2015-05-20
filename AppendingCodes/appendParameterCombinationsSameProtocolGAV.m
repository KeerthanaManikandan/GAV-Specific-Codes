function dataLog = appendParameterCombinationsSameProtocolGAV(extractTheseIndices)

[subjectNames,expDates,protocolNames,stimType,deviceName] = allProtocolsHumanEEG;
gridType = 'EEG'; folderSourceString = 'D:';

% Parameters index
parameters{1} = 'azimuth';
parameters{2} = 'elevation';
parameters{3} = 'sigma';
parameters{4} = 'spatialFrequency';
parameters{5} = 'orientation';
parameters{6} = 'contrast';
parameters{7} = 'temporalFrequency'; %#ok<NASGU>
parameters{8} = 'auditoryAzimuth';
parameters{9} = 'auditoryElevation';
parameters{10} = 'rippleFrequency';
parameters{11} = 'ripplePhase';
parameters{12} = 'auditoryVolume';
parameters{13} = 'rippleVelocity';

trialAdvance = 0;
badTrialsFinal = 0;

for iV = 1:length(extractTheseIndices)

    clear iIndex
    iIndex = extractTheseIndices(iV);

    clear subjectName expDate protocolName dataLog folderName folderExtract folderLFP
    subjectName = subjectNames{iIndex};
    expDate = expDates{iIndex};
    protocolName = protocolNames{iIndex};

    dataL{1,2} = subjectName;
    dataL{2,2} = gridType;
    dataL{3,2} = expDate;
    dataL{4,2} = protocolName;
    dataL{14,2} = folderSourceString;

    [~,folderName,folderNameDate]=getFolderDetails(dataL);
    clear dataLog
    load(fullfile(folderName,'dataLog.mat'));
    folderExtract = fullfile(folderName,'extractedData');
    folderSegment = fullfile(folderName,'segmentedData');

    [parameterCombinations,aValsUnique,eValsUnique,sValsUnique,fValsUnique,oValsUnique,cValsUnique,tValsUnique,aaValsUnique,...
        aeValsUnique,asValsUnique,aoValsUnique,avValsUnique,atValsUnique] = loadParameterCombinations(folderExtract);
    if ~exist('parameterCombinationsFinal','var')
        parameterCombinationsFinal = cell(size(parameterCombinations));
    end
    
    load(fullfile(folderExtract,'goodStimNums.mat'));
 
    aLen = length(aValsUnique);
    eLen = length(eValsUnique);
    sLen = length(sValsUnique);
    fLen = length(fValsUnique);
    oLen = length(oValsUnique);
    cLen = length(cValsUnique);
    tLen = length(tValsUnique);
    aaLen = length(aaValsUnique);
    aeLen = length(aeValsUnique);
    asLen = length(asValsUnique);
    aoLen = length(aoValsUnique);
    avLen = length(avValsUnique);
    atLen = length(atValsUnique);
    
    if (aLen > 1)           ;        aLen=aLen+1;                        end
    if (eLen > 1)           ;        eLen=eLen+1;                        end
    if (sLen > 1)           ;        sLen=sLen+1;                        end
    if (fLen > 1)           ;        fLen=fLen+1;                        end
    if (oLen > 1)           ;        oLen=oLen+1;                        end
    if (cLen > 1)           ;        cLen=cLen+1;                        end
    if (tLen > 1)           ;        tLen=tLen+1;                        end
    if (aaLen > 1)          ;        aaLen=aaLen+1;                      end
    if (aeLen > 1)          ;        aeLen=aeLen+1;                      end
    if (asLen > 1)          ;        asLen=asLen+1;                      end
    if (aoLen > 1)          ;        aoLen=aoLen+1;                      end
    if (avLen > 1)          ;        avLen=avLen+1;                      end
    if (atLen > 1)          ;        atLen=atLen+1;                      end
    
    for a=1:aLen
        for e=1:eLen
            for s=1:sLen
                for f=1:fLen
                    for o=1:oLen
                        for c=1:cLen
                            for t=1:tLen
                                for aa=1:aaLen
                                    for ae=1:aeLen
                                        for as=1:asLen
                                            for ao=1:aoLen
                                                for av=1:avLen
                                                    for at=1:atLen
                                                        trialNum=parameterCombinations{a,e,s,f,o,c,t,aa,ae,as,ao,av,at};
                                                        trialNum = trialNum + trialAdvance;
                                                        parameterCombinationsFinal{a,e,s,f,o,c,t,aa,ae,as,ao,av,at} = [parameterCombinationsFinal{a,e,s,f,o,c,t,aa,ae,as,ao,av,at},trialNum];
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
    end
    
    % Bad trials
    try
        load(fullfile(folderSegment,'badTrials.mat'));
    catch
        allBadTrials = {};
        badTrials = [];
    end
    if ~exist('allBadTrialsFinal','var')
        allBadTrialsFinal = cell(1,size(allBadTrials,2));
    end
    
    clear allBadTrialsNew;
    for iBT = 1:size(allBadTrials,2);
        allBadTrialsNew{1,iBT} = allBadTrials{1,iBT} + trialAdvance;
        allBadTrialsFinal{1,iBT} = [allBadTrialsFinal{1,iBT},allBadTrialsNew{1,iBT}];
    end
    
    clear badTrialsNew;
    badTrialsNew = badTrials + trialAdvance;
    badTrialsFinal = [badTrialsFinal,badTrialsNew];
    
    
    trialAdvance = trialAdvance + size(goodStimNums,2);    
end

clear parameterCombinations badTrials allBadTrials;
badTrials = badTrialsFinal;
allBadTrials = allBadTrialsFinal;
parameterCombinations = parameterCombinationsFinal;
dataLog{8,2} = badTrials;
dataLog{4,2} = 'GAV_concatenatedData';

load(fullfile(folderExtract,'stimResults'));
stimResultsNew.side = stimResults.side;
clear stimResults;
stimResults = stimResultsNew;

folderConcatenated = fullfile(folderNameDate,'GAV_concatenatedData');
folderConcExtract = fullfile(folderConcatenated,'extractedData'); 
folderConcSegment = fullfile(folderConcatenated,'segmentedData'); 
makeDirectory(folderConcatenated);
makeDirectory(folderConcExtract);
makeDirectory(folderConcSegment);

save(fullfile(folderConcExtract,'parameterCombinations.mat'),'parameters','parameterCombinations', ...
    'aValsUnique','eValsUnique','sValsUnique','fValsUnique','oValsUnique','cValsUnique',...
    'tValsUnique','aaValsUnique','aeValsUnique','asValsUnique','aoValsUnique','avValsUnique','atValsUnique');

save(fullfile(folderConcSegment,'badTrials.mat'),'allBadTrials','badTrials',...
    'checkTheseElectrodes','maxLimit','minLimit','nameElec','threshold');

save(fullfile(folderConcExtract,'stimResults.mat'),'stimResults');

save(fullfile(folderConcatenated,'dataLog.mat'),'dataLog');
end

% aValsNew = []; eValsNew = []; sValsNew = []; fValsNew = []; oValsNew = []; cValsNew = [];
% tValsNew = []; aaValsNew = []; aeValsNew = []; asValsNew = []; aoValsNew = []; avValsNew = [];
% atValsNew = [];

% aPosNew = []; ePosNew = []; sPosNew = []; fPosNew = []; oPosNew = []; cPosNew = []; tPosNew = []; 
% aaPosNew = []; aePosNew = []; asPosNew = []; aoPosNew = []; avPosNew = []; atPosNew = []; 

%     aValsNew = unique(aValsNew,aValsUnique);
%     eValsNew = unique(eValsNew,eValsUnique);
%     sValsNew = unique(sValsNew,sValsUnique);
%     fValsNew = unique(fValsNew,fValsUnique);
%     oValsNew = unique(oValsNew,oValsUnique);
%     cValsNew = unique(cValsNew,cValsUnique);
%     tValsNew = unique(tValsNew,tValsUnique);
%     aaValsNew = unique(aaValsNew,aaValsUnique);
%     aeValsNew = unique(aeValsNew,aeValsUnique);
%     asValsNew = unique(asValsNew,asValsUnique);
%     aoValsNew = unique(aoValsNew,aoValsUnique);
%     avValsNew = unique(avValsNew,avValsUnique);
%     atValsNew = unique(atValsNew,atValsUnique);