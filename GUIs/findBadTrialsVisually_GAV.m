function findBadTrialsVisually_GAV(dataLog,checkTheseElectrodes,decimationFactor)
    
    % Initialise
    [dataLog,folderName] = getFolderDetails(dataLog);
    if ~exist('checkTheseElectrodes','var')
        checkTheseElectrodes = dataLog{7,2};
        disp('Checking bad trials for all electrodes');
    else disp(['Checking bad trials for electrodes: ' num2str(checkTheseElectrodes)]);
    end
    if ~exist('decimationFactor','var');             decimationFactor = 1;                          end

    folderSegment = fullfile(folderName,'segmentedData');
    folderLFP = fullfile(folderSegment,'LFP');

    [analogChannelsStored,timeVals] = loadlfpInfo(folderLFP);
    FsSig = dataLog{9,2};
    Fs = FsSig/decimationFactor;     
    
    numElectrodes = length(analogChannelsStored);
    numCheckElectrodes = length(checkTheseElectrodes);
    allBadTrials = cell(1,numElectrodes);
    nameElec = cell(1,numElectrodes);    
    
    
    for iC = 1:numCheckElectrodes
        analogDataOriginal(iC,:,:) = loadAnalogData(fullfile(folderSegment,'LFP',['elec' num2str(checkTheseElectrodes(iC)) '.mat']));
        for iTN = 1:size(analogDataOriginal,2);
            analogData(iC,iTN,:) = decimate(analogDataOriginal(iC,iTN,:),decimationFactor);
        end
    end
    
    numTrials = size(analogData,2);
    timeVals = decimate(timeVals,decimationFactor);
    N = length(timeVals);%((BLMin):BLMax));
    L = N/Fs;        
    fAxis = (0:1:(N-1))*(1/L);    
    
%     dataLogBadTrials = dataLog{8,2};
    [VisBadTrials,AlgBadTrials,totalBadTrials] = loadBadTrials(folderSegment);
    BadTrialsList = VisBadTrials;    
    assignin('base','BadTrialsList',BadTrialsList);
    assignin('base','totalBadTrials',totalBadTrials);
%     params = defparams([0.4 2 0.6],Fs,[0 Fs/2],[],0);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure(251);
    hAllDataPlot = subplot('Position',[0.01 0.56 0.48 0.35],'Linewidth',0.1);
    hDataPlot = subplot('Position',[0.01 0.2 0.48 0.34]);
    hFftPlot = subplot('Position',[0.51 0.56 0.48 0.35]);
    hBinBarPlot = subplot('Position',[0.51 0.2 0.48 0.34]);
    
    uicontrol('Unit','Normalized','Position',[0.51 0.92 0.24 0.04], ...
        'Style','text','string','FFT Type','FontSize',14);
    hFFTType = uicontrol('Unit','Normalized','Position',[0.75 0.92 0.24 0.04], ...
        'Style','popup','string','Trend|Raw','FontSize',14,'Callback',{@updatePlot_Callback});
    
    uicontrol('Unit','Normalized','Position',[0.01 0.12 0.48 0.04], ...
        'Style','text','String',['Total trials: ' num2str(numTrials)],'FontSize',14);
    uicontrol('Unit','Normalized','Position',[0.01 0.08 0.11 0.04], ...
        'Style','text','String','Trial Number: ','FontSize',14);
    uicontrol('Unit','Normalized','Position',[0.12 0.08 0.12 0.04], ...
        'Style','pushbutton','String','<','FontSize',14,'Callback',{@previous_Callback});
    hTrialNum = uicontrol('Unit','Normalized','Position',[0.24 0.08 0.12 0.04], ...
        'Style','edit','String','1','FontSize',14,'BackgroundColor','w','Callback',{@updatePlot_Callback});
    uicontrol('Unit','Normalized','Position',[0.36 0.08 0.13 0.04], ...
        'Style','pushbutton','String','>','FontSize',14,'Callback',{@next_Callback});
    
    uicontrol('Unit','Normalized','Position',[0.51 0.08 0.13 0.04], ...
        'Style','pushbutton','String','Add to bad trials','FontSize',14,'Callback',{@Add_Callback});
    uicontrol('Unit','Normalized','Position',[0.65 0.08 0.13 0.04], ...
        'Style','pushbutton','String','Remove from bad trials','FontSize',14,'Callback',{@Remove_Callback});
    uicontrol('Unit','Normalized','Position',[0.79 0.08 0.13 0.04], ...
        'Style','pushbutton','String','Save and exit','FontSize',14,'Callback',{@Save_Callback});
    
    hTrialInd = uicontrol('Unit','Normalized','Position',[0.51 0.12 0.24 0.04], ...
        'Style','text','FontSize',14);
    hTrialState = uicontrol('Unit','Normalized','Position',[0.75 0.12 0.24 0.04], ...
        'Style','text','FontSize',14);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    updatePlot_Callback;
    
    function previous_Callback(~,~)
        trialNum = str2num(get(hTrialNum,'string'));
        if trialNum>1
            trialNum = trialNum-1;
            set(hTrialNum,'string',num2str(trialNum));
            updatePlot_Callback;
        end
    end

    function next_Callback(~,~)
        trialNum = str2num(get(hTrialNum,'string'));
        if trialNum<numTrials
            trialNum = trialNum+1;
            set(hTrialNum,'string',num2str(trialNum));
            updatePlot_Callback;
        end
    end

    function updatePlot_Callback(~,~)
        FFTType = get(hFFTType,'val');
        trialNum = str2num(get(hTrialNum,'string'));
        trialData = squeeze(analogData(:,trialNum,:));
        if length(checkTheseElectrodes) == 1
            trialData = trialData';
        end
        plot(hAllDataPlot,timeVals,trialData','Linewidth',0.1);        
        plot(hDataPlot,timeVals,mean(trialData',2)','Linewidth',0.1);
        
        if FFTType == 2
        plot(hFftPlot,fAxis,conv2Log(mean(abs(fft(trialData,[],2)),1)),'Linewidth',0.1); xlim(hFftPlot,[0 100]'); ylim(hFftPlot,[1 5]);
%         [SubTin] = mtspectrumc(trialData,params);
%         plot(hFftPlot,fAxis,conv2Log(mean(SubTin,1)),'Linewidth',0.1); xlim([0 Fs/2]');
        elseif FFTType == 1
        fftCurve = conv2Log(mean(abs(fft(trialData,[],2)),1));
        [LocMax,LocMin,tMax,tMin]=findSignalExtrema(fftCurve,fAxis);
        NSamp=length(fftCurve);
        MaxEnv= spline([fAxis(1) tMax fAxis(NSamp)],[fftCurve(1) LocMax fftCurve(NSamp)],fAxis) ;
        MinEnv= spline([fAxis(1) tMin fAxis(NSamp)],[fftCurve(1) LocMin fftCurve(NSamp)],fAxis) ;
        MeanEnv=bsxfun(@plus,MaxEnv/2,MinEnv/2);
        plot(hFftPlot,fAxis,MeanEnv,'Linewidth',0.1); xlim(hFftPlot,[0 100]'); ylim(hFftPlot,[1 5]);
        end
        
        % Added by MD
        for irC = 1:numCheckElectrodes
            rmsData = [];
            winLength = 0.04;
            winSize = Fs*winLength;
            nBin = size(trialData,2)/winSize;
            for iBin = 0:(nBin-1)
                iBinIndex = (iBin*winSize+1):(iBin+1)*winSize;
                binData = squeeze(analogData(irC,trialNum,iBinIndex));
                binMean = mean(binData);
                binData = binData - binMean;
                rmsData(iBin+1) = rms(binData);
%                 fftBin(iBin+1,:) = abs(fft(binData))';
            end
            timeBar = 0:winLength:(size(analogData,3)/Fs)-(winLength);
            timeBar = timeBar + timeVals(1);
            
%             fftMean = mean(fftBin,1);
%             fftStdHigh = fftMean + 6*std(fftBin,[],1);
%             fftStdLow = fftMean - 6*std(fftBin,[],1);
            rmsStd = std(rmsData);
            rmsMean = mean(rmsData);
            rmsData(timeBar>=0 & timeBar<=0.25) = rmsMean; 
            rmsKurt = kurtosis(rmsData,0)-3
            rmsSkew = skewness(rmsData,0)
    %         rmsKurt = ((mean((rmsData - repmat(rmsMean,size(rmsData))).^4))/((mean((rmsData - repmat(rmsMean,size(rmsData))).^2)).^2))-3
    %         rmsSkew = (mean((rmsData - repmat(rmsMean,size(rmsData))).^3))/(mean((rmsData - repmat(rmsMean,size(rmsData))).^2).^(3/2))
            bar(hBinBarPlot,timeBar,rmsData); axis(hBinBarPlot,'tight');
%             figure; plot(fftMean); hold on; plot(fftStdHigh); hold on; plot(fftStdLow)
            if rmsKurt>3 || rmsSkew>1.5 % Leptokurtic or positively skewed distributions taken for rejection
                Add_Callback;
            end
%             assignin('base','rmsData',rmsData);
        end
        
        paintState;
    end

    function Add_Callback(~,~)
        trialNum = str2num(get(hTrialNum,'string'));
        BadTrialsList = union(BadTrialsList,trialNum);
        totalBadTrials = union(totalBadTrials,trialNum);
        assignin('base','BadTrialsList',BadTrialsList);
        assignin('base','totalBadTrials',totalBadTrials);
        paintState;
    end

    function Remove_Callback(~,~)
        trialNum = str2num(get(hTrialNum,'string'));
        BadTrialsList = sort(setdiff(BadTrialsList,trialNum));
        totalBadTrials = sort(setdiff(totalBadTrials,trialNum));
        assignin('base','BadTrialsList',BadTrialsList);
        assignin('base','totalBadTrials',totalBadTrials);
        paintState;
    end

    function Save_Callback(~,~)
%         dataLogBadTrials = dataLog{8,2};
        totalBadTrials = union(totalBadTrials,BadTrialsList);
        dataLog{8,2} = totalBadTrials;
        assignin('base','dataLog',dataLog);
        
        saveBadTrials(folderSegment,totalBadTrials,BadTrialsList,AlgBadTrials,checkTheseElectrodes);
        save(fullfile(folderName,'dataLog.mat'),'dataLog');
    end

    function paintState
        trialNum = str2num(get(hTrialNum,'string'));
        trialStatusUnion = find(union(AlgBadTrials,BadTrialsList) == trialNum);
        trialStatusBTL = find(BadTrialsList == trialNum);
        trialStatusBTAlg = find(AlgBadTrials == trialNum);
        trialStatus = find(totalBadTrials == trialNum);
        
        if isempty(trialStatusUnion)            
            set(hTrialInd,'string','Good Trial','backgroundcolor','g');
        else
            if ~isempty(trialStatusBTL) && ~isempty(trialStatusBTAlg)
                set(hTrialInd,'string','Bad Trial, Visually and algorithmically','backgroundcolor','m');
            else
                if ~isempty(trialStatusBTL)
                    set(hTrialInd,'string','Bad Trial, Visually','backgroundcolor','c');
                elseif ~isempty(trialStatusBTAlg)
                    set(hTrialInd,'string','Bad Trial, Algorithmically','backgroundcolor','y');
                end
            end
        end
        
        if isempty(trialStatus)
            set(hTrialState,'string','Good Trial','backgroundcolor','g');
        else
            set(hTrialState,'string','Bad Trial','backgroundcolor','r');
        end
    end

end

function analogData = loadAnalogData(analogDataPath)
    load(analogDataPath);
end

function saveBadTrials(folderSegment,totalBadTrials,VisBadTrials,AlgBadTrials,checkTheseElectrodesVisually)
    load(fullfile(folderSegment,'badTrials.mat'));
    badTrials = totalBadTrials;
    
    save(fullfile(folderSegment,'badTrials.mat'),'allBadTrials','badTrials','AlgBadTrials','checkTheseElectrodes',...
        'maxLimit','minLimit','nameElec','threshold','VisBadTrials','checkTheseElectrodesVisually');
end

function [VisBadTrials,AlgBadTrials,badTrials] = loadBadTrials(folderSegment)
    try
        load(fullfile(folderSegment,'badTrials.mat'));
    catch
        badTrials = [];
    end
    
    if ~(exist('VisBadTrials','var')); VisBadTrials = []; end;
    if ~(exist('AlgBadTrials','var')); AlgBadTrials = badTrials; end;
end

function [LocalMax,LocalMin,tVMax,tVMin]=findSignalExtrema(Sig,TimeV)
xBar=Sig;
tVal=TimeV;
NSamP=length(xBar);
LocalMax=[];
tVMax=[];
LocalMin=[];
tVMin=[];

for i=1:NSamP-1
    Diff(i) = bsxfun(@minus,xBar(i+1),xBar(i));
end

for j=1:NSamP-2
    DiffR=Diff(j)/Diff(j+1);
    if DiffR<0
        if Diff(j)>Diff(j+1)
            LocalMax=[LocalMax xBar(j+1)];
            tVMax=[tVMax tVal(j+1)];
        elseif Diff(j)<Diff(j+1)
            LocalMin=[LocalMin xBar(j+1)];
            tVMin=[tVMin tVal(j+1)];
        end
    end
end
end