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



function [recESIs recSyms] = rfc6330_test_bec_channel(K, infile, outfile, pattern, errProb)
%
% Passes a number of encoding symbols that are found in infile through a
% channel. Encoding symbols are lost according to some loss pattern and the
% received symbols are written in outfile.
%
% Input:
%        K - number of initial source symbols
%   infile - input file
%  outfile - output file
%  pattern - specific loss pattern
%
% Output:
%  recESIs - surviving through the channel ESIs
%  recSyms - corresponding encoding symbol values
%
if (nargin<5)
    errProb = 0.5;
    disp('No error probability given! Default: 0.5')
end
if (nargin<4)
    pattern = 0;
end
inputArr = dlmread(infile);
recESIs = inputArr(:,1);
recSyms = inputArr(:,2);
switch pattern
    case 1,
        disp('Select only source symbols!')
        recESIs = recESIs(1:K);
        recSyms = recSyms(1:K);
    case 2,
        disp('Select only repair symbols!')
        recESIs = recESIs((K+1):end);
        recSyms = recSyms((K+1):end);
    otherwise,
        disp('Select uniformly at random a number of encoding symbols!')
        RecESIs = [];
        for ind = 0:(length(recESIs)-1)
            if (rand > errProb)
                RecESIs = [RecESIs; ind];
            end
        end
        recESIs = RecESIs;
        recSyms = recSyms(recESIs+1);
        if (length(RecESIs) < K)
            disp('Insufficient number of collected symbols!')
            disp('Decoding will fail!')
        end
end
dlmwrite(outfile,[recESIs recSyms], ' ')