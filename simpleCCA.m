function [r, rIdx] = simpleCCA(x,t,Nh)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
f = zeros(5,8);
for i = 1:5
    for j=1:8
        f(i,j) = 8+0.2*((j-1)*5+(i-1));
    end
end
f = [f(1,:) f(2,:) f(3,:) f(4,:) f(5,:)];
r = zeros(40,1);
rIdx = zeros(40,1);
y = zeros(1500, Nh*2);
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
    [r(i), rIdx(i)] = max(tempRho);
end

