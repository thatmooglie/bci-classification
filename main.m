load S20

chIdx = [48 54 55 56 57 58 61 62 63];
Fs = 250;
T = 1/Fs;
L = 1500;
t = (0:L-1)*T;

x = reshape(data(chIdx,:,:,1), [length(chIdx) 1500 40]);
[r, rIdx] = simpleCCA(x,t,4);
f = zeros(5,8);
for i = 1:5
    for j=1:8
        f(i,j) = 8+0.2*((j-1)*5+(i-1));
    end
end
f = [f(1,:) f(2,:) f(3,:) f(4,:) f(5,:)];
stem(f,f(rIdx))
ylim([7 16])
%[~, mIdx] = max(r, [], 2);