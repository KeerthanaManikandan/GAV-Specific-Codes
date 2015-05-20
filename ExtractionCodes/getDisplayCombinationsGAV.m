% This program generates the parameterCombinations variable from the
% stimResults
%
% Murty V P S Dinavahi:
% Right now, as we are presenting only full screen gratings and auditory
% stimulus is mapped to only one visual grating, we need only one set of visual
% parameters and auditory parameters each (plaids are also not necessary, 
% as none of the protocols involve plaids), though LL and stimResults files are 
% programmed to carry info from all valid gabors. These could come independently
% from right or left gabors.
% Hence, in future, if we want to add info from all gabors, changes need to
% be done from this program onwards.

function parameterCombinations = getDisplayCombinationsGAV(folderOut)

folderOut = appendIfNotPresent(folderOut,'\');
load(fullfile(folderOut,'stimResults.mat'));
load(fullfile(folderOut,'goodStimNums.mat'));


% 12 parameters are chosen:
% 1. Azimuth
% 2. Elevation
% 3. Sigma, Radius 
% 4. Spatial Frequency
% 5. Orientation
% 6. Contrast
% 7. Temporal Frequency
% 8. Audio Volume
% 9. Audio TF
% 10. Audio SF
% 11. Audio Ori
% 12. Audio Azi
% 13. Audio Elev

% Initialise (MD 27-10-2014)
aLen=0;
eLen=0;
sLen=0;
fLen=0;
oLen=0;
cLen=0;
tLen=0;
aaLen=0;
aeLen=0;
asLen=0;
aoLen=0;
avLen=0;
atLen=0;

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

if ~exist('goodStimNums','var')
    goodStimNums = getGoodStimNumsGAV(folderOut);
end

for i=1:length(stimResults.side)
    switch stimResults.side(i)
        case 1
            azimuth = stimResults.(['azimuth' num2str(i)]);
            elevation = stimResults.(['elevation' num2str(i)]);
            sigma = stimResults.(['sigma' num2str(i)]);
            spatialFrequency = stimResults.(['spatialFrequency' num2str(i)]);
            orientation = stimResults.(['orientation' num2str(i)]);
            contrast = stimResults.(['contrast' num2str(i)]);
            temporalFrequency = stimResults.(['temporalFrequency' num2str(i)]);
        case 6
            auditoryAzimuth = stimResults.(['auditoryAzimuth' num2str(i)]);
            auditoryElevation = stimResults.(['auditoryElevation' num2str(i)]);
            rippleFrequency = stimResults.(['rippleFrequency' num2str(i)]);
            ripplePhase = stimResults.(['ripplePhase' num2str(i)]);
            auditoryContrast = stimResults.(['auditoryContrast' num2str(i)]);
            rippleVelocity = stimResults.(['rippleVelocity' num2str(i)]);
        case 7
            if i==1
                disp('Visual and Auditory stimuli mapped to the LEFT gabor. Hence taking parameter combinations from same gabor...');
            elseif i==2
                disp('Visual and Auditory stimuli mapped to the RIGHT gabor. Hence taking parameter combinations from same gabor...');
            end
%             azimuth = stimResults.(['azimuth' num2str(i)]);
%             elevation = stimResults.(['elevation' num2str(i)]);
%             sigma = stimResults.(['sigma' num2str(i)]);
%             spatialFrequency = stimResults.(['spatialFrequency' num2str(i)]);
%             orientation = stimResults.(['orientation' num2str(i)]);
%             contrast = stimResults.(['contrast' num2str(i)]);
%             temporalFrequency = stimResults.(['temporalFrequency' num2str(i)]);
            auditoryAzimuth = stimResults.(['auditoryAzimuth' num2str(i)]);
            auditoryElevation = stimResults.(['auditoryElevation' num2str(i)]);
            rippleFrequency = stimResults.(['rippleFrequency' num2str(i)]);
            ripplePhase = stimResults.(['ripplePhase' num2str(i)]);
            auditoryContrast = stimResults.(['auditoryContrast' num2str(i)]);
            rippleVelocity = stimResults.(['rippleVelocity' num2str(i)]);
    end
end

if exist('azimuth','var')
    aValsAll  = azimuth;
    aValsGood = aValsAll(goodStimNums);
    aValsUnique = unique(aValsGood); aLen = length(aValsUnique);
    disp(['Number of unique azimuths: ' num2str(aLen)]);
end

if exist('elevation','var') 
    eValsAll  = elevation;
    eValsGood = eValsAll(goodStimNums);
    eValsUnique = unique(eValsGood); eLen = length(eValsUnique);
    disp(['Number of unique elevations: ' num2str(eLen)]);
end

if exist('sigma','var')
    sValsAll  = sigma;
    sValsGood = sValsAll(goodStimNums);
    sValsUnique = unique(sValsGood); sLen = length(sValsUnique);
    disp(['Number of unique sigmas: ' num2str(sLen)]);
end

if exist('spatialFrequency','var')
    fValsAll  = spatialFrequency;
    fValsGood = fValsAll(goodStimNums);
    fValsUnique = unique(fValsGood); fLen = length(fValsUnique);
    disp(['Number of unique Spatial freqs: ' num2str(fLen)]);
end

if exist('orientation','var')
    oValsAll  = orientation;
    oValsGood = oValsAll(goodStimNums);
    oValsUnique = unique(oValsGood); oLen = length(oValsUnique);
    disp(['Number of unique orientations: ' num2str(oLen)]);
end

if exist('contrast','var')
    cValsAll  = contrast;
    cValsGood = cValsAll(goodStimNums);
    cValsUnique = unique(cValsGood); cLen = length(cValsUnique);
    disp(['Number of unique contrasts: ' num2str(cLen)]);
end
    
if exist('temporalFrequency','var')
    tValsAll  = temporalFrequency;
    tValsGood = tValsAll(goodStimNums);
    tValsUnique = unique(tValsGood); tLen = length(tValsUnique);
    disp(['Number of unique temporal freqs: ' num2str(tLen)]);
end
    
if exist('auditoryAzimuth','var')
    aaValsAll = auditoryAzimuth;
    aaValsGood = aaValsAll(goodStimNums);   
    aaValsUnique = unique(aaValsGood); aaLen = length(aaValsUnique);
    disp(['Number of unique auditory Azimuths: ' num2str(aaLen)]);
end

if exist('auditoryElevation','var')
    aeValsAll = auditoryElevation;
    aeValsGood = aeValsAll(goodStimNums);   
    aeValsUnique = unique(aeValsGood); aeLen = length(aeValsUnique);
    disp(['Number of unique auditory Elevations: ' num2str(aeLen)]);
end

if exist('rippleFrequency','var')
    asValsAll = rippleFrequency;
    asValsGood = asValsAll(goodStimNums);   
    asValsUnique = unique(asValsGood); asLen = length(asValsUnique);
    disp(['Number of unique ripple Frequencies: ' num2str(asLen)]);
end

if exist('ripplePhase','var')
    aoValsAll = ripplePhase;
    aoValsGood = aoValsAll(goodStimNums);   
    aoValsUnique = unique(aoValsGood); aoLen = length(aoValsUnique);
    disp(['Number of unique ripple Phases: ' num2str(aoLen)]);
end

if exist('auditoryContrast','var')
    avValsAll = auditoryContrast;
    avValsGood = avValsAll(goodStimNums);
    avValsUnique = unique(avValsGood); avLen = length(avValsUnique);
    disp(['Number of unique auditory Contrasts: ' num2str(avLen)]);
end
    
if exist('rippleVelocity','var')
    atValsAll = rippleVelocity;
    atValsGood = atValsAll(goodStimNums);   
    atValsUnique = unique(atValsGood); atLen = length(atValsUnique);
    disp(['Number of unique ripple Velocities: ' num2str(atLen)]);
end

% If more than one value, make another entry with all values
if (aLen > 1)           aLen=aLen+1;                    end
if (eLen > 1)           eLen=eLen+1;                    end
if (sLen > 1)           sLen=sLen+1;                    end
if (fLen > 1)           fLen=fLen+1;                    end
if (oLen > 1)           oLen=oLen+1;                    end
if (cLen > 1)           cLen=cLen+1;                    end
if (tLen > 1)           tLen=tLen+1;                    end
if (aaLen > 1)           aaLen=aaLen+1;                    end
if (aeLen > 1)           aeLen=aeLen+1;                    end
if (asLen > 1)           asLen=asLen+1;                    end
if (aoLen > 1)           aoLen=aoLen+1;                    end
if (avLen > 1)           avLen=avLen+1;                    end
if (atLen > 1)           atLen=atLen+1;                    end

% Added by MD to include 'no codes' from gabors 27-10-2014
if (aLen==0); aLen=1; aValsUnique=-999; end
if (eLen==0); eLen=1; eValsUnique=-999; end
if (sLen==0); sLen=1; sValsUnique=-999; end
if (fLen==0); fLen=1; fValsUnique=-999; end
if (oLen==0); oLen=1; oValsUnique=-999; end
if (cLen==0); cLen=1; cValsUnique=-999; end
if (tLen==0); tLen=1; tValsUnique=-999; end
if (aaLen==0); aaLen=1; aaValsUnique=-999; end
if (aeLen==0); aeLen=1; aeValsUnique=-999; end
if (asLen==0); asLen=1; asValsUnique=-999; end
if (aoLen==0); aoLen=1; aoValsUnique=-999; end
if (avLen==0); avLen=1; avValsUnique=-999; end
if (atLen==0); atLen=1; atValsUnique=-999; end

allPos = 1:length(goodStimNums);
disp(['total combinations: ' num2str((aLen)*(eLen)*(sLen)*(fLen)*(oLen)*(cLen)*(tLen)*(aaLen)*(asLen)*(aoLen)*(avLen)*(atLen))]);

for a=1:aLen
    if a==aLen
        aPos = allPos;
    else
        aPos = find(aValsGood == aValsUnique(a));
    end

    for e=1:eLen
        if e==eLen
            ePos = allPos;
        else
            ePos = find(eValsGood == eValsUnique(e));
        end

        for s=1:sLen
            if s==sLen
                sPos = allPos;
            else
                sPos = find(sValsGood == sValsUnique(s));
            end

            for f=1:fLen
                if f==fLen
                    fPos = allPos;
                else
                    fPos = find(fValsGood == fValsUnique(f));
                end

                for o=1:oLen
                    if o==oLen
                        oPos = allPos;
                    else
                        oPos = find(oValsGood == oValsUnique(o));
                    end

                    for c=1:cLen
                        if c==cLen
                            cPos = allPos;
                        else
                            cPos = find(cValsGood == cValsUnique(c));
                        end

                        for t=1:tLen
                            if t==tLen
                                tPos = allPos;
                            else
                                tPos = find(tValsGood == tValsUnique(t));
                            end
                                for aa=1:aaLen
                                    if aa==aaLen
                                        aaPos = allPos;
                                    else
                                        aaPos = find(aaValsGood == aaValsUnique(aa));
                                    end 
                                    for ae=1:aeLen
                                        if ae==aeLen
                                            ae2Pos = allPos;
                                        else
                                            ae2Pos = find(aeValsGood == aeValsUnique(ae));
                                        end  
                                        for as=1:asLen
                                        if as==asLen
                                            asPos = allPos;
                                        else
                                            asPos = find(asValsGood == asValsUnique(as));
                                        end

                                            for ao=1:aoLen
                                                if ao==aoLen
                                                    aoPos = allPos;
                                                else
                                                    aoPos = find(aoValsGood == aoValsUnique(ao));
                                                end
                                                for av=1:avLen
                                                    if av==avLen
                                                        avPos = allPos;
                                                    else
                                                        avPos = find(avValsGood == avValsUnique(av));
                                                    end
                                                        for at=1:atLen
                                                            if at==atLen
                                                                atPos = allPos;
                                                            else
                                                                atPos = find(atValsGood == atValsUnique(at));
                                                            end

                                                                aePos = intersect(aPos,ePos);
                                                                aesPos = intersect(aePos,sPos);
                                                                aesfPos = intersect(aesPos,fPos);
                                                                aesfoPos = intersect(aesfPos,oPos);
                                                                aesfocPos = intersect(aesfoPos,cPos);
                                                                aesfoctPos = intersect(aesfocPos,tPos);
                                                                aesfoctaaPos = intersect(aesfoctPos,aaPos); 
                                                                aesfoctaaaePos = intersect(aesfoctaaPos,ae2Pos);
                                                                aesfoctaaaeasPos = intersect(aesfoctaaaePos,asPos);
                                                                aesfoctaaaeasaoPos = intersect(aesfoctaaaeasPos,aoPos);
                                                                aesfoctaaaeasaoavPos = intersect(aesfoctaaaeasaoPos,avPos);
                                                                aesfoctaaaeasaoavatPos = intersect(aesfoctaaaeasaoavPos,atPos);
                                                                parameterCombinations{a,e,s,f,o,c,t,aa,ae,as,ao,av,at} = aesfoctaaaeasaoavatPos; %#ok<AGROW>
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

% save

save([folderOut 'parameterCombinations.mat'],'parameters','parameterCombinations', ...
    'aValsUnique','eValsUnique','sValsUnique','fValsUnique','oValsUnique','cValsUnique',...
    'tValsUnique','aaValsUnique','aeValsUnique','asValsUnique','aoValsUnique','avValsUnique','atValsUnique');

end