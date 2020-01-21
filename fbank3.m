function corrGuess = fbank3(data, Fs, n, rp, f, nCh, nSub)
%fbank3 Implementation of the filter bank canonical correlation analysis
%done previously by Chen et al (2015)
%   This function applies FBCCA on EEG signals, with multi-channel SSVEP
%   response and reference signals including 4 harmonics
%   -----------------------------INPUTS------------------------------------
%   data    multidimensional matrix with size of (samples, channels,
%           trials)
%   Fs      Sampling frequency  of the recorded data
%   n       Chebyshev filter order
%   rp      Amount of ripple in the passband of the filter
%   f       Correct frequencies of each trial
%   nCh     Number of channels in data
%   nSub    Number of subbands in the filterbank
%   -----------------------------OUTPUT------------------------------------
%   corrGuess   Number of correct "guesses" by the algorithm
%   -----------------------------------------------------------------------

%   Initialize total number of Harmonics
nH = 4;
%   Set lower limit on sub-bands
lowLim = 8;
%   Set high limit on sub-bands
highLim = (nSub+1)*8;
%   Create the reference signals
y = genRef(nH+1, f, length(data));
%   Initialize the correct number of guesses
corrGuess = 0;
%   Initialize the correlation matrix for 40 trials and 40 reference
%   frequencies
rho = zeros(40,40);
%   Loop through the sub-bands
for numSB=1:nSub
    %   Design filter for the sub-band
    D = designfilt('bandpassiir', 'FilterOrder', n, ...
        'PassbandFrequency1', lowLim*numSB-2, 'PassbandFrequency2', ...
        highLim+2, 'PassbandRipple', rp, 'SampleRate', Fs);
    %   Calculate the weigth for the sub-band
    w = numSB^(-0.8) + 0.5;
    %   Run through each trial in the data
    for nTrial=1:40
        %   Initialize matrix for the filtered signals
        dataFilt = zeros(nCh,length(data));
        %   Loop through each channel
        for ch=1:nCh
            %   Filter the channel
            dataFilt(ch, :) = filtfilt(D, data(:,ch, nTrial)');
        end
        %   Loop through each possible frequency
        for fIdx=1:40
            %   Perform the canonical correlation and store the canonical
            %   correlation
            [~, ~, r] = canoncorr(dataFilt',reshape(y(fIdx,:,:), ...
                [length(data) 2*(nH+1)]));
            %   Calculate the weighted correlation for the frequency
            rho(nTrial, fIdx) = rho(nTrial, fIdx) + max(w*r.^2);
        end 
    end
end
%   Find maximum correlation and store the frequency location
[~, idx] = max(rho, [], 2);
%   Calculate how many frequencies were correctly identified
corrGuess = corrGuess + sum(f==f(idx));
end