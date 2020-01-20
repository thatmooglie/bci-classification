clear all, close all
addpath('C:\Users\Fabi\Desktop\Brain Computer Interface\Project\SSVEP-BCI-Data\')
warning ('off','all');
%Load data
sub = 1;
numBlock = 6;

%Output
acc=zeros(length(sub),numBlock);
missC=zeros(length(sub),numBlock);

inputCh = [48 54 55 56 57 58 61 62 63];
chosCh = [];
maxCh=5;
for j=1:maxCh
    accCh=[];
    for i = 1:length(inputCh)
        [acc,missC] = CanCorr(sub,[chosCh inputCh(i)]);
        accCh(i) = mean(acc,'all');
        fprintf('\nAccuracy: %f',mean(acc,'all'))
    end
    [val,pos]=max(accCh);
    chosCh(j)=inputCh(pos);
    inputCh(pos)=[];    
end
                
            