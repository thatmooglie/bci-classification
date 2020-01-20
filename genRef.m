function y = genRef(nH, f, N)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
y = zeros(40, N, 2*nH);
for i=1:40
    for k=1:nH
        y(i,:,2*k-1) = sin(2*pi*f(i)*k*(0:N-1)*1/250);
        y(i,:,2*k) = cos(2*pi*f(i)*k*(0:N-1)*1/250);
    end
end
end

