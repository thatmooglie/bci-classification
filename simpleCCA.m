function [c, r, rIdx] = simpleCCA(x,t,f,Nh)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
r = zeros(40,1);
rIdx = zeros(40,1);
y = zeros(length(t), Nh*2);
for i=1:40
    data = x(:,:,i)';
    tempRho = zeros(40,1);
    for j=1:40
        for k=1:Nh
            y(:,2*k-1) = sin(2*pi*f(j)*k*t);
            y(:,2*k) = cos(2*pi*f(j)*k*t);
        end
        [A, B, rt] = canoncorr(data,y);
        tempRho(j) = max(rt);
    end
    [r, rIdx(i)] = max(tempRho);
end
c = sum(f==f(rIdx));
end

