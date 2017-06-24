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



function flag = rfc6330_generate_dec_output(K,infile,outfile)
%
% Generates the decoding output based on some file that contains the
% received symbols. K is the number of the source symbols and is essential
% to the decoding process. The inout file format is a matrix 2 column
% matrix, where the first column is the ESIs and the second the actual
% symbol values.
%
% Input:
%        K - number of source symbols
%   infile - input filename
%  outfile - output filename
%
% Output:
%     flag - returns 0 if everything went well
%                    1 error while opening file
%                    2 error in writing to file
%
%
if (nargin < 3)
    outfile = infile;
    disp('No output file specified! Input file will be overwritten!')
end
[fid,message] = fopen(infile, 'r');
flag = 0;
if fid == -1
    flag = 1;
    error(message)
end
[inputArr,count] = fread(fid);
fclose(fid);
recESIs = inputArr(1:count/2)';
recSyms = inputArr(count/2+1:count)';
[val RecoveredSymbols] = rfc6330_receiveSymbols( recESIs, recSyms, K )
[fid,message] = fopen(outfile, 'w');
flag = 0;
if fid == -1
    flag = 1;
    error(message)
end
if ( fwrite(fid,RecoveredSymbols) ~= K )
    flag = 2;
    fclose(fid);
    error('Error while writing to file!')
end
fclose(fid);