clear all, close all
addpath('C:\Users\Fabi\Desktop\Brain Computer Interface\Project\SSVEP-BCI-Data\')
warning ('off','all');
%Load data
numSub=10;
subInfo= importfile('subject_info_35_dataSets.txt',2,numSub+1);
chIdx = [48 54 55 56 57 58 61 62 63];
%data=importSubjectfile(subjectInfo(1,1));
data=zeros(numSub,length(chIdx),1500,40,6);

%Reference result
ref=reshape(linspace(1,40,40),5,8);
%Number of targets;
numTarget=40;
%Number of blocks
numBlock=6;
totalGuess=numTarget*numBlock;
%Frequency
Fs=250;
skipT = 1.5*Fs;
segL=2*Fs;
%Frequency vector
targetFreq=linspace(8,15.8,40);
%Filter
filtOrder=4;
numSubfilt=10;
tempRho=(zeros(numSubfilt,length(targetFreq)));
%Harmonics
numHar=3;
%Time vector
T=1/Fs;
L = segL;
time=(0:L-1)*T;
%Reference signal
Y=zeros(2*numHar,length(time));
%Weight components
a=.8;
b=.5;
%Feature for target identification
rIdx=zeros(length(targetFreq),1);
corrFeat=zeros(numSubfilt,1);
rho=zeros(length(targetFreq),1);
rhoSub=zeros(numSubfilt,1);
w=zeros(numSubfilt,1);
%Outputs
guessOut=zeros(5,8,numBlock);
acc=zeros(numSub,numBlock);

for sub=1:numSub
    fprintf('\nProcessing subject %.0f',sub)
    %Load subject file
    %Output data(channel,datapoint,target,block)
    load(subInfo(sub,1),'-mat')
    %Exclude channels
    data = data(chIdx,skipT+1:(skipT+segL),:,:);
    
    for block=1:numBlock %For each block...
        fprintf('\n\t Processing block %.0f',block)
        %blockData=data(:,:,:,numBlock);
        
        for trial=1:numTarget %For each target
            Xin=data(:,:,trial,block);
            %fprintf('\n\t\t Processing trial %.0f',trial)
            
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
                    [A,B,rt]=canoncorr(Xfk(:,:),Y');
                    
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
        acc(sub,block)=count/(totalGuess/numBlock);                    
    end
    fprintf('\n\tAccuracy subject %.0f: %.2f%',sub,mean(acc,2))
end

finAcc=mean(acc,'all');
fprintf('\nOverall accuracy: %.0f\n',finAcc)
                
                
            