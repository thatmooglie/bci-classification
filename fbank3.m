function corrGuess = fbank3(data, Fs, n, rp, f, nCh)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

lowLim = 8;
highLim = 88;
y = genRef(1, f);
corrGuess = 0;
rho = zeros(40,40);
for numSB=1:10
    D = designfilt('bandpassiir', 'FilterOrder', n, ...
        'PassbandFrequency1', lowLim*numSB-2, 'PassbandFrequency2', ...
        highLim+2, 'PassbandRipple', rp, 'SampleRate', Fs);
    for nTrial=1:40
        dataFilt = zeros(nCh,1250);
        for ch=1:nCh
            dataFilt(ch, :) = filtfilt(D, data(:,ch,nTrial)');
        end
        for fIdx=1:40
            [~, ~, r] = canoncorr(dataFilt',reshape(y(fIdx,:,:), [1250 2]));
            w = numSB.^-0.8 + .5;
            rho(nTrial, fIdx) = rho(nTrial, fIdx) + max(w*r.^2);
        end 
    end
end
[~, idx] = max(rho, [], 2);
corrGuess = corrGuess + sum(f==f(idx));
end

