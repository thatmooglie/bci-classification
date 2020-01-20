function corrGuess = fbank3(data, Fs, n, rp, f, nCh, a, b)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
nH = 4;
lowLim = 8;
highLim = 88;
y = genRef(nH, f, length(data));
corrGuess = 0;
rho = zeros(40,40);
for numSB=1:10
    D = designfilt('bandpassiir', 'FilterOrder', n, ...
        'PassbandFrequency1', lowLim*numSB-2, 'PassbandFrequency2', ...
        highLim+2, 'PassbandRipple', rp, 'SampleRate', Fs);
    for nTrial=1:40
        dataFilt = zeros(nCh,length(data));
        for ch=1:nCh
            dataFilt(ch, :) = filtfilt(D, data(:,ch, nTrial)');
        end
        for fIdx=1:40
            [~, ~, r] = canoncorr(dataFilt',reshape(y(fIdx,:,:), ...
                [length(data) 2*nH]));
            w = numSB.^-a + b;
            rho(nTrial, fIdx) = rho(nTrial, fIdx) + max(w*r.^2);
        end 
    end
end
[~, idx] = max(rho, [], 2);
corrGuess = corrGuess + sum(f==f(idx));
end

