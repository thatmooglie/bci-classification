function y = genRef(nH, f, N)
%genref Generates sine and cosine reference signal
%   This function generates nH pairs of sine and cosine with len(f) 
%   different fundamental frequencies f and nH-1 harmonics with length N
%   -----------------------------INPUT-------------------------------------
%   nH      Number of harmonics to include minus 1, nH=1 is just the
%           fundamental frequency
%   f       vector containing the fundamental frequencies of the reference
%           signals to be generated
%   N       Length of the reference signals to be generated
%   Initialize reference matrix
y = zeros(length(f), N, 2*nH);

for i=1:length(f)  % Loop through frequencies
    for k=1:nH  % Loop through each harmoinic
        y(i,:,2*k-1) = sin(2*pi*f(i)*k*(0:N-1)*1/250);
        y(i,:,2*k) = cos(2*pi*f(i)*k*(0:N-1)*1/250);
    end
end
end