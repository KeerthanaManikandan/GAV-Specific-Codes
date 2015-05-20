function dataLog = appendSameProtocolDifferentRunsEEG_GAV(extractTheseIndices,totElecNum,totAinpNum)

if ~exist('totElecNum','var') || isempty(totElecNum); totElecNum = 64; end; % set default
if ~exist('totAinpNum','var') || isempty(totAinpNum); totAinpNum = 6; end; % set default

disp('Appending EEG data...');
appendEEGDataGAV(totElecNum,extractTheseIndices);
disp('Appending Ainp data...');
appendAinpDataGAV(totAinpNum,extractTheseIndices);
disp('Appending Parameter combinations...');
dataLog = appendParameterCombinationsSameProtocolGAV(extractTheseIndices);

end