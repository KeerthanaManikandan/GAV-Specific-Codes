function [allBadTrials, badTrials, nameElec] = findBadTrialsEEG_GAV(dataLog,checkTheseElectrodes,threshold,maxLimit,minLimit,saveDataFlag,showTrials)

if ~exist('threshold','var') || isempty(threshold);                threshold = 6;                             end
if ~exist('minLimit','var') || isempty(minLimit);                minLimit = -100;                          end
if ~exist('maxLimit','var') || isempty(maxLimit);                maxLimit = 100;                          end

% Initialise
[dataLog,folderName] = getFolderDetails(dataLog);
Fs = dataLog{9,2};
if ~exist('checkTheseElectrodes','var')
    checkTheseElectrodes = (cell2mat(dataLog(7,2)));
    disp('Checking bad trials for all electrodes');
else disp(['Checking bad trials for electrodes: ' num2str(checkTheseElectrodes)]);
end

if ~exist('saveDataFlag','var');             saveDataFlag = 1;                          end
if ~exist('showTrials','var');             showTrials = 0;                          end

folderSegment = fullfile(folderName,'segmentedData');
folderLFP = fullfile(folderSegment,'LFP');

load(fullfile(folderLFP,'lfpInfo'));

numElectrodes = length(analogChannelsStored);
if isempty(checkTheseElectrodes); checkTheseElectrodes = analogChannelsStored; end;

numCheckElectrodes = length(checkTheseElectrodes);

allBadTrials = cell(1,numElectrodes);
nameElec = cell(1,numElectrodes);

hW1 = waitbar(0,['Processing electrode: ' num2str(analogChannelsStored(1))]);
for i=1:numElectrodes
    clear analogData
    electrodeNum=analogChannelsStored(i); % changed from checkTheseElectrodes
    % to calculate bad trials for each electrode irrespective of the
    % electrodes to be checked
%     disp(['Processing electrode: ' num2str(electrodeNum)]);
    waitbar(i/numElectrodes,hW1,['Processing electrode: ' num2str(electrodeNum)]);
    nameElec{i} = ['elec' num2str(electrodeNum)];
%     disp(nameElec{i});
    
    % Set the limits higher for frontal electrodes 1,2 & 61(for eyeblinks)
    if (electrodeNum == 1 || electrodeNum == 2 || electrodeNum == 61)
        maxLimitElec = 300; minLimitElec = -300;
    else
        maxLimitElec = maxLimit; minLimitElec = minLimit;
    end
    
    analogData = loadAnalogData(fullfile(folderSegment,'LFP',['elec' num2str(electrodeNum) '.mat']));
    
    if showTrials
        hAllTrials = figure(11);
        subplot(8,8,i); plot(timeVals,analogData);title(['elec' num2str(i)]);
        axis('tight');
    end
    
    numTrials = size(analogData,1); %#ok<*NODEF>
    meanData = mean(analogData,2)';    
    
    analogData = analogData - repmat(meanData',1,size(analogData,2)); % [MD]: DC correction by equating mean of the data to zero
    meanData = mean(analogData,2)'; % MD: Should be equal to zero after DC Correction
    
    stdData  = std(analogData,[],2)';
    maxData  = max(analogData,[],2)';
    minData  = min(analogData,[],2)';
    
    clear tmpBadTrials1 tmpBadTrials2 tmpBadTrials3 tmpBadTrials4 
    tmpBadTrials1 = unique([find(maxData > meanData + threshold * stdData) find(minData < meanData - threshold * stdData)]);
    % Vinay - Ideally set maxLimit and minLimit for the below criteria to
    % be quite high/low so that only the extremely noisy trials are
    % rejected by these
    tmpBadTrials2 = unique(find(maxData > maxLimitElec));
    tmpBadTrials3 = unique(find(minData < minLimitElec));
    
    % Vinay - Set another criterion based on the deviation of each trial
    % from the mean trial signal. This way even if the actual signal shows
    % high deflections, if those deflections are consistent then the trials
    % are not rejected purely on the max/min criteria above
    meanTrialData = mean(analogData,1); % mean trial trace
    stdTrialData = std(analogData,[],1); % std across trials
%     maxTrialData = max(analogData,[],1);
%     minTrialData = min(analogData,[],1);
    tDplus = (meanTrialData + (threshold)*stdTrialData); % upper boundary/criterion
    tDminus = (meanTrialData - (threshold)*stdTrialData); % lower boundary/criterion
    
    % Check for trials that cross these boundaries and mark them as bad
    tBoolTrials = zeros(1,numTrials);
    for tr = 1:numTrials
        
        trialDeviationHigh = tDplus - analogData(tr,:); % deviation from the upper boundary
        trialDeviationLow = analogData(tr,:) - tDminus; % deviation from the lower boundary
        
        tBool = zeros(size(meanTrialData,1),size(meanTrialData,2));
        tBool(trialDeviationHigh<0) = 1; % set if the upper boundary is crossed anywhere
        tBool1 = sum(tBool); % number of times the upper boundary was crossed
        
        tBool = zeros(size(meanTrialData,1),size(meanTrialData,2));
        tBool(trialDeviationLow<0) = 1; % set if the lower boundary is crossed anywhere
        tBool2 = sum(tBool); % number of times the lower boundary was crossed

        tBoolTrials(tr) = tBool1 + tBool2; % number of times the boundaries were crossed
        
    end
    
    tmpBadTrials4 = find(tBoolTrials>0);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % Added by MD
%     fftData = abs(fft(analogData,[],2));
%     NPoints = size(analogData,2);
%     lengthData = NPoints/Fs;
%     NyquistFreq = Fs/2;
%     fAxis = (0:1/lengthData:(NPoints-1)*1/lengthData);
%     filterMod = zeros(1,length(find(fAxis < NyquistFreq)));
%     filterMod(1,find(fAxis>20,1):end) = 1;
%     filterModFlip = fliplr(filterMod);
%     filterFinal = [filterMod,filterModFlip];
%     
%     fftDataFilt = fftData.*(repmat(filterFinal,size(fftData,1),1));
%     filtData = real(ifft(fftDataFilt,[],2));
%     
%     meanData = mean(filtData,2)';    
%     
%     filtData = filtData - repmat(meanData',1,size(filtData,2)); % [MD]: DC correction by equating mean of the data to zero
%     meanData = mean(filtData,2)'; % MD: Should be equal to zero after DC Correction
%     
%     stdData  = std(filtData,[],2)';
%     maxData  = max(filtData,[],2)';
%     minData  = min(filtData,[],2)';
%     
% %     clear tmpBadTrials1 tmpBadTrials2 tmpBadTrials3 tmpBadTrials4 
%     tmpBadTrials5 = unique([find(maxData > meanData + threshold * stdData) find(minData < meanData - threshold * stdData)]);




    
    
%     % Added by MD : to detect local increases in energy, keeping the
%     % analysis window small enables us to look at increase in power in the
%     % high frequency bands. There is a high detection rate and a high false
%     % positive rate as well. False positives could be dealt with when we
%     % take union of multiple electrodes.
%     clear rmsData iBin iBinIndex tmpBadTrials5
%     tmpBadTrials5 = [];
%     for trialNum = 1:numTrials
%         clear binData binMean binData rmsData rmsMean rmsKurt rmsSkew
%         rmsData = [];
%         winLength = 0.05;
%         winSize = Fs*winLength;
%         nBin = size(analogData,2)/winSize;
%         for iBin = 0:(nBin-1)
%             iBinIndex = (iBin*winSize+1):(iBin+1)*winSize;
%             binData = squeeze(analogData(trialNum,iBinIndex));
%             binMean = mean(binData);
%             binData = binData - binMean;
%             rmsData(iBin+1) = rms(binData);            
%         end
%         timeBar = 0:winLength:(size(analogData,2)/Fs)-(winLength);
%         timeBar = timeBar + timeVals(1);
%         rmsMean = mean(rmsData);
%         rmsData(timeBar>=0 & timeBar<=0.25) = rmsMean; % This negates the bias due to evoked responses from 0 to 0.25 s.
%         rmsKurt = kurtosis(rmsData,0)-3;
%         rmsSkew = skewness(rmsData,0);
%         if rmsKurt>3 || rmsSkew>1.5 % Leptokurtic or positively skewed distributions at their respective thresholds (3 and 1.5) are taken for rejection
%            tmpBadTrials5 = [tmpBadTrials5 trialNum];
%         end
%     end
    
    tmpBadTrials5 = [];

    allBadTrials{i} = unique([tmpBadTrials1 tmpBadTrials2 tmpBadTrials3 tmpBadTrials4 tmpBadTrials5]);
    
    goodTrials = 1:numTrials;
    goodTrials = setdiff(goodTrials,allBadTrials{i});
    
    clear meanData maxData minData stdData meanTrialData stdTrialData maxLimitElec minLimitElec
    clear trialDeviationHigh trialDeviationLow tBool tBool1 tBool2 tBoolTrials tDminus tDplus
%     clear binData binMean binData rmsData rmsMean rmsKurt rmsSkew rmsData iBin iBinIndex
    
    if showTrials && ~isempty(goodTrials)
        hGoodTrials = figure(12);
        subplot(8,8,i); plot(timeVals,analogData(goodTrials,:));title(['elec' num2str(i)]);
        axis('tight');
    end
end
close(hW1);

% badTrials=allBadTrials{checkTheseElectrodes(1)};
badTrials=allBadTrials{1};
for i=1:numCheckElectrodes
%     badTrials=union(badTrials,allBadTrials{checkTheseElectrodes(i)}); 
%     uniqueBadTrials=intersect(badTrials,allBadTrials{checkTheseElectrodes(i)}); % in the previous case we took the union
    badTrials=intersect(badTrials,allBadTrials{checkTheseElectrodes(i)}); % in the previous case we took the union
end

disp(['total Trials: ' num2str(numTrials) ', bad trials: ' num2str(badTrials)]);

% saveData = 1;
% for i=1:numElectrodes
%     if length(allBadTrials{i}) ~= length(badTrials)
%         disp(['Bad trials for electrode ' num2str(analogChannelsStored(i)) ': ' num2str(length(allBadTrials{i}))]);
%     else
%         disp(['Bad trials for electrode ' num2str(analogChannelsStored(i)) ': all (' num2str(length(badTrials)) ')']);
%     end
% end

if saveDataFlag
    disp(['Saving ' num2str(length(badTrials)) ' bad trials']);
    save(fullfile(folderSegment,'badTrials.mat'),'badTrials','allBadTrials','nameElec','checkTheseElectrodes','threshold','maxLimit','minLimit');
else
    disp('Bad trials will not be saved..'); %#ok<UNRCH>
end

end

function analogData = loadAnalogData(analogDataPath)
    load(analogDataPath);
end
