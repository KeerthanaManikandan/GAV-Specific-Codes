function batchExtractEEG_GAV(varargin)

    for iArg = 1:nargin

        extractTheseIndices = varargin{iArg};
        runBatchExtractBPHumanDataGAV(extractTheseIndices);

        if length(extractTheseIndices)>1
            appendSameProtocolDifferentRunsEEG_GAV(extractTheseIndices);
        end
    end
    
end