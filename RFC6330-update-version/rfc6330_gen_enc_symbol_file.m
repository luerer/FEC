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




function [flag K] = rfc6330_gen_enc_symbol_file(filename,K,N,str,outfile)
%
% Generates a set of encoding symbols either by default or by reading a
% file (*.enc) and writes the result in an output file (*.enc).
% str == 'r'
% Reads input from filename and feeds it into the encoder. The result is
% written in outfile. If outfile is not specified, the output file is
% filename.
% str == 'w'
% Creates a file that includes a number of encoding symbols along with the
% corresponding values. The generated file can be used for verification
% purposes.
% In both cases the generated ESIs are 0:(N-1).
%
% Input:
%  filename - initial file (to read for 'r', to write for 'w')
%         K - number of source symbols
%         N - number of encoding symbols
%       str - 'r' for read, 'w' for write
%   outfile - output file in 'r' operation. If not specified, the code
%             overwrites the initial file.
% Output:
%      flag - returns 0 if everything went well
%                     1 error while opening file
%                     2 error due to wrong input parameters
%                     3 error in writing to file
%

if ((K < 1)||(N < K))
    flag = 2;
    error('K,N must be integers and K < N!')
end

if ((nargin == 4)&&(str == 'r'))
    outfile = filename;
    disp('Output filename not specified! Input file will be overwritten!')
elseif ((nargin == 5)&&(str == 'w'))
    disp('Outfile parameter redundant in write mode and will be ignored!')
end

if (str == 'r')
    [fid,message] = fopen(filename, 'r');
    flag = 0;
    if fid == -1
        flag = 1;
        error(message)
    end
    % Input file contains only symbols. ESIs are 0..K-1
    [SourceSymbols,count] = fread(fid);
    if ( count < K )
        K = count;
        disp(['Only ',int2str(K),' entries read! This is the new K!'])
    elseif ( count > K )
        SourceSymbols = SourceSymbols(1:K);
        disp([int2str(count),' entries read! Excess entries will be ignored!'])
    end
    fclose(fid);
    SourceSymbols = SourceSymbols'
    % Compute the number of the extended source block
    K_prime = rfc6330_K_prime( K );
    % Zero pad source Symbols to create extended block
    ExtendedSymbols = [SourceSymbols zeros(1,K_prime-K)];
    % Assign Internal Symbol IDs
    ISIs = 0:(K_prime-1);
    % Compute matrix A for the computation of Intermediate Symbols
    A = rfc6330_A( K_prime, ISIs );
    % Zero-pad at the beginning to create the 'b' vector of the linear system -
    % according to the notation: Ax = b
    Sym = [ zeros(1,length(A)-length(ExtendedSymbols)) ExtendedSymbols(:).' ];
    % Solve the linear system to obtain the intermediate symbols
    [IntermediateSymbols] = rfc6330_inversion( A, Sym, K );
    % Combine appropriately the intermediate symbols to produce the encoding
    % symbols (source symbols-repair symbols)
    EncSymbols = rfc6330_gen_encoding_symbol( K_prime, IntermediateSymbols, 0:(N-1+K_prime-K) );
    EncSourceSymbols = EncSymbols(1:K);
    EncRepairSymbols = EncSymbols(K_prime+1:end);
    % Exclude the zero padding redundant symbols from the symbols sent
    genSyms = [EncSourceSymbols EncRepairSymbols];
    genESIs = 0:(N-1);
    outputArr = [genESIs; genSyms]
    [fid,message] = fopen(outfile, 'w');
    flag = 0;
    if fid == -1
        flag = 1;
        error(message)
    end
    if ( fwrite(fid,outputArr) ~= 2*N )
        flag = 3;
        fclose(fid);
        error('Error while writing to file!')
    end
elseif (str == 'w')
    [fid,message] = fopen(filename, 'w');
    flag = 0;
    if fid == -1
        flag = 1;
        error(message)
    end
    [genSyms genESIs] = rfc6330_generateNsymbols( N , K );
    outputArr = [genESIs; genSyms]
    if ( fwrite(fid,outputArr) ~= 2*N )
        flag = 3;
        fclose(fid);
        error('Error while writing to file!')
    end
end