
function spikeShape1(filebase, clu_file, clu_ID)
% function spikeShape1(filebase)
% description: calculate spike waveform and its parameters for multiunit data
% input: clu/det/dat files
% output: .shape (mean trace / its SD for each electrodes)
% output: .shapePar (nSpikes; rec_time(sec); freq(Hz); peak(mV); trough(mV); halfWidth(msec) for an electrode with the highest trough) 


%%%% Parameters
overwrite = 1; % skip (0) or overwrite (1) if already processed
original_rate = 20; % 20 (kHz, Datamax sampling rate)

% nSamples = 25;
nSamples = 36;
nElectrodes = 1;

limSpikes = 300;
pre = 1.5*20; % pt @ 20 kHz  30?
post = 2*20;%%% 40?
window = -pre:post;

%%%% Preparing directory
mkdir('spikeShape');

data = readmulti([filebase '.dat'], 1, 1);

det = load([filebase '.det']); % load Tetrode1.det: 1. time_resolution(usually 20kHzx50); 2... spike timing (det pts; 50*20kHz)
% det = det./original_rate; % ms

clu = load(['All.clu.' num2str(clu_file)]);
clu = clu(2:end,1);
clu = [det clu];
clu = clu(find(clu(:,2)==clu_ID),1);

rawShape = [];
for i=1:length(clu)
    if clu(i) > pre %%%pre=30
        rawShape = [rawShape data(round(window + clu(i)))];
    end
end

if FileExists(['./spikeShape/' filebase '_' num2str(clu_file) '_' num2str(clu_ID) '.shapePar']) ...
        && overwrite == 0
    fprintf(['./spikeShape/' filebase '_' num2str(clu_file) '_' num2str(clu_ID) '.shapePar: already exists. EXIT\n']);
    return;
end
fprintf('calculate and save spike shape data for clu %d-%d ...\n', clu_file, clu_ID);

if length(clu) < limSpikes
    fprintf('#spikes less than limSpikes (%d)\n', limSpikes);
    return;
end

% assuming range=8(+/-4V), unit=mV, 16bit, amp=x2000

stdEx = std(rawShape,0,2).*10*10^3/2^16/2000;
meanEx = mean(rawShape,2).*10*10^3/2^16/2000;
if abs(max(meanEx)) > abs(min(meanEx)) % reversing polarity in the case of positive spike
    rawShape = -rawShape;
    meanEx = -meanEx;
    stdEx = -stdEx;
end
trough = min(meanEx);
peak = max(meanEx(find(meanEx==trough):end));
halfWidth = [];
ptWidth = [];
for j = 1:size(rawShape, 2)
    halfWidth = [halfWidth size(find(rawShape(:,j)<min(rawShape(:,j)/2)),2)];
    trace = rawShape(:,j);
    troughTraceIdx = find(trace==min(trace),1,'first');
    for k = troughTraceIdx+1:length(trace)-1
        if trace(k) > trace(k+1)
            ptWidth = [ptWidth k-troughTraceIdx];
            break;
        end
    end
end
halfWidth = mean(halfWidth)./original_rate;
ptWidth = mean(ptWidth)./original_rate;
msave([filebase '_' num2str(clu_file) '_' num2str(clu_ID) '_' num2str(1) '.shape'], [meanEx'; stdEx']);
movefile([filebase '_' num2str(clu_file) '_' num2str(clu_ID) '_' num2str(1) '.shape'], './spikeShape');
shapePar = [peak trough peak-trough halfWidth ptWidth];


shapePar = sortrows(shapePar, 2); % sort according to the second column (trough)
shapePar = shapePar(end, :); % select an electrode with the largest trough                 

% mean firing rate (clu in 10kHz, det @ 20 kHz)
cluBuf = clu/original_rate;
nSpikes = size(cluBuf,1); % the number of spikes
rec_time = (clu(end)-cluBuf(1))/10^3; % sec
freq = nSpikes/rec_time; % mean firing rate (Hz)

% save shapePar (nSpikes; rec_time; freq; peak; trough; halfWidth) 
msave([filebase '_' num2str(clu_file) '_' num2str(clu_ID) '.shapePar'], [nSpikes rec_time freq shapePar]);
movefile([filebase '_' num2str(clu_file) '_' num2str(clu_ID) '.shapePar'], './spikeShape');






