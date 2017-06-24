% Copyright (c) 2013, Ravichandran
% All rights reserved.
% 
% Redistribution and use in the source code, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
%     * Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%           
% THIS SOURCE CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED 
% TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
% WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN 
% IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.




clear all
close all
clc

% Generate a number N of encoding symbols
N = 1024;
% Source block size in symbols
K = 10;
% Generate the encoding symbols
[genSyms genESIs] = rfc6330_generateNsymbols( N , K );
disp('Encoding symbols calculated!')
% Pick n number of symbols and perform decoding
n = K;
% Statistics
successful_attempts = zeros(1,N);
iters = 1000;
ind_iters = 0;
decoding_failure = 0;
while (ind_iters < iters)
    decoding_success = false;           % Flag to mark correct decoding
    esis2choose = genESIs;              % Symbols left to choose from
    % Choose initially K symbols and update syms2choose
    [chosenESIs esis2choose] = pickESIs(esis2choose,n)
    chosenSyms = genSyms(chosenESIs + 1)
    while ((~decoding_success)&&(~isempty(esis2choose)))
        val = rfc6330_receiveSymbols( chosenESIs, genSyms, K);
        if (val ~= 0)
            decoding_success = true;
            successful_attempts(length(chosenESIs)) = successful_attempts(length(chosenESIs)) + 1;
            disp(['Iteration: ',int2str(ind_iters+1)])
            disp(['Successful decoding! Number of Symbols: ',int2str(length(chosenESIs))])
%             disp(['ESI set: ',mat2str(chosenESIs)])
        else
            [cESIs esis2choose] = pickESIs(esis2choose,1);
            chosenESIs = [chosenESIs cESIs];
            chosenSyms = genSyms(chosenESIs + 1);
        end
    end
    if (~decoding_success)
        decoding_failure = decoding_failure + 1;
    end
    ind_iters = ind_iters + 1;
end
non_zero_ind = find(successful_attempts);
x_values = [non_zero_ind(1)-1 non_zero_ind min(non_zero_ind(length(non_zero_ind))+1,N)];
stem(x_values, successful_attempts(x_values))
xlabel('Number of required symbols')
ylabel('Frequency of successful decoding')
title(['Encoding Symbols = ',int2str(N),', Source Symbols = ',int2str(K),', Iterations = ',int2str(iters)])
disp(['Number of decoding failures: ',int2str(decoding_failure)])
figure
stem(x_values, log(successful_attempts(x_values)))
xlabel('Number of required symbols')
ylabel('ln of frequency of successful decoding')
title(['Encoding Symbols = ',int2str(N),', Source Symbols = ',int2str(K),', Iterations = ',int2str(iters)])