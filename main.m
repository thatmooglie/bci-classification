%% Load Subject Information and channel indices and load the data
%-------------------------------------------------------------------------%
clear all, close all
addpath('E:\Data\SSVEP-BCI-Data\')
% Initialize recording parameters
Fs = 250;
T = 1/Fs;
skipT = 0.5*Fs;
L = 1500-2*skipT;
t = (0:L-1)*T;

% Initialize target frequency matrix
f = zeros(5,8);
for i = 1:5
    for j=1:8
        f(i,j) = 8+0.2*((j-1)*5+(i-1));
    end
end
f = [f(1,:) f(2,:) f(3,:) f(4,:) f(5,:)];

% Load subject information
subjectInfo = readcell('subject_info_35_dataSets.txt');
subjectIdx = cat(1, subjectInfo{2:end,1});
subjectIdx = erase(string(subjectIdx), '0')+".mat";
chIdx = [48 54 55 56 57 58 61 62 63];

%%  Run simple Canonical Correlation Analysis on subjects
corrGuess = zeros(1,11);
totalTrials = 40*6*35;
%nH = 5;
for nH=1:1
    fprintf('Running with %.0f harmonics \n', nH-1)
    for subj=1:1
        fprintf('Processing subject %.0f of 35 subjects(%.2f%%)\n', subj, (subj/35)*100)
        load(subjectIdx(subj));
        for blk=1:6
            blkdata = data(chIdx,skipT+1:end-skipT,:,blk);
            [c,~, ~] = simpleCCA(blkdata,t,f, nH);
            corrGuess(nH) = corrGuess(nH)+c;
        end
    end
    fprintf('Accuracy: %.2f \n', corrGuess(nH)/(totalTrials/35))
end
fprintf('Accuracy: %.2f \n', corrGuess/(totalTrials/35))

%%  Run FBCCA with filter bank 3
corrGuess = 0;
totalTrials = 40*6*35;
nH = 4;
ch = chIdx(end-2:end);
for subj=1:35
        fprintf('Processing subject %.0f/35 subjects(%.2f%%)\n', subj, (subj/35)*100)
        load(subjectIdx(subj));
        for blk=1:6
            fprintf('Processing Block %.0f/6\n', blk)
            r = zeros(10,40);
            blkdata = data(ch,skipT+1:end-skipT,:,blk);
            corrGuess = corrGuess + fbank3(permute(blkdata, [2 1 3]), 250, 4, 3, f, length(ch));
        end
end
fprintf('Accuracy: %.2f \n', corrGuess/(totalTrials))

    
