function [outputArg1,outputArg2] = CanCorr(subIdx,chIdx)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

warning ('off','all');

%% Load data info
numSub = length(subIdx);
subInfo = importfile('subject_info_35_dataSets.txt',subIdx);

%% Setup variables
%Frequency
Fs=250;
segL=2*Fs;
skipT = 1.5*Fs;
targetFreq=linspace(8,15.8,40);
%Filter
filtOrder=4;
numSubfilt=10;
%Harmonics
numHar=3;
%Weight components
a=.8;
b=.5;
%Time vector
T=1/Fs;
L = segL;
time=(0:L-1)*T;
%Reference signal
Y=zeros(2*numHar,length(time));
%Feature for target identification
rIdx=zeros(length(targetFreq),1);
rho=zeros(length(targetFreq),1);
w=zeros(numSubfilt,1);
%Reference result
ref=reshape(linspace(1,40,40),5,8);

%% Running canonical correlation
fprintf('\n ----- Running canonical correlation -----')
fprintf('\nNumber of subjects: %.0f',numSub)
fprintf('\nChannel index: %s',num2str(chIdx))
fprintf('\nNumber of subfilter: %.0f',numSubfilt)
fprintf('\nNumber of harmonics: %.0f',numHar)
fprintf('\nProcessing subject: XXX')
for sub=1:numSub
    fprintf('\b\b\b%s',subInfo(subIdx(sub),1))
    %Load subject file
    load(subInfo(subIdx(sub),1),'-mat');
    data = data(chIdx,skipT+1:(skipT+segL),:,:);
    numTarget=size(data,3);
    numBlock=size(data,4);

    %Outputs
    guessOut=zeros(5,8,numBlock);
    acc=zeros(numSub,numBlock);
    missC=zeros(numSub,numBlock);
    
    for block=1:numBlock %For each block...
        
        for trial=1:numTarget %For each target
            Xin=data(:,:,trial,block);
            
            for subfilt=1:numSubfilt %For each subfilter...
                %Setup subfilter with specific range
                d = designfilt('bandpassiir','FilterOrder',filtOrder, ...
                    'PassbandFrequency1',8*subfilt-2,'PassbandFrequency2',8*numSubfilt+2, ...
                    'PassbandRipple',3,'SampleRate',250);
                Xfk = filtfilt(d,Xin'); %[data, channel]
                
                for j=1:length(targetFreq) %For each reference signal
                    
                    for i=1:numHar % For each number of harmonics
                        %Setup reference signals
                        Y(2*i-1,:)= sin(2*pi*targetFreq(j)*i*time);
                        Y(2*i,:)= cos(2*pi*targetFreq(j)*i*time);
                    end
                    
                    %Run canonical correlation
                    [~,~,rt]=canoncorr(Xfk(:,:),Y');
                    
                    %Pick maximum correlation corresponding to
                    %reference signal
                    rho(j,subfilt)=max(rt);
                end
                
                %Calculate the weights feature for target identification
                w(subfilt)=subfilt^(-a)+b;
            end
            
            %Calculate the weighted feature for target identification
            corrFeat=w'*(rho.^2)';
            [~,rIdx(trial)]=max(corrFeat);
            
        end
        guessOut(:,:,block)=reshape(rIdx,[8,5])';
        count=0;
        for i=1:5
            for j=1:8
                if ref(i,j)==guessOut(i,j,block)
                    count=count+1;
                end
            end
        end
        acc(sub,block)=count/numTarget;
        missC(sub,block)=numTarget-count;
    end
end
%fprintf('\n\tAccuracy subject %.0f: %.2f%',subIdx(sub),mean(acc,2))

outputArg1 = acc;
outputArg2 = missC;
end

