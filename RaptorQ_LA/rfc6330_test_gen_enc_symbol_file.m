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



function K = rfc6330_test_gen_enc_symbol_file(filename,K,N,str,outfile,T)
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
%         T - Size of Each Symbol
%

if ((K < 1)||(N < K))
    error('K,N must be integers and K < N!')
end

if ((nargin == 4)&&(str == 'r'))
    outfile = filename;
    disp('Output filename not specified! Input file will be overwritten!')
elseif ((nargin == 5)&&(str == 'w'))
    disp('Outfile parameter redundant in write mode and will be ignored!')
end

if (str == 'r')
    K_new=K*T;      %K_new number of Symbols of 1 byte each are read from the Source file
    SerialSymbols = rfc6330_fread(filename,K_new); % Reading the source symbols from the file
    char(SerialSymbols)
    val=0;
    
    %Converting the K_new 1 byte symbols into K symbols of T bytes  
    for i=1:K
       SourceSymbols(i,1:T)=SerialSymbols((((i-1)*T)+1):(i*T));
    end
%     SourceSymbols
    for i=1:K
        val= val+sum(SourceSymbols(i,:));
    end;
    val
    SourceSymbols_new=[SourceSymbols]';
    
    for i=1:T
        
    K_prime = rfc6330_K_prime( K ) ; % Compute the number of the symbols in extended source block
   
    % Zero pad source Symbols to create extended block
    ExtendedSymbols = [SourceSymbols_new(i,1:K) zeros(1,K_prime-K)];
    % Assign Internal Symbol IDs
    ISIs = 0:(K_prime-1);
    % Compute matrix A for the computation of Intermediate Symbols
    %L x L matrix A over GF(256)of octet such that A*C = D
    A = rfc6330_A( K_prime, ISIs );
    % Zero-pad at the beginning to create the D vector of the linear system -
    Sym = [ zeros(1,length(A)-length(ExtendedSymbols)) ExtendedSymbols(:).' ];
    % obtain the intermediate symbols
    [IntermediateSymbols] = rfc6330_inversion( A, Sym, K );
    clear SourceSymbols_new(i,1:K);  
    clear ExtendedSymbols; 
    clear A;
    clear Sym; 
    %Generate the Encoding symbols using the Intermediate symbols and the
    %Tuple Generator
    EncSymbols = rfc6330_gen_encoding_symbol( K_prime, IntermediateSymbols, 0:(N-1+K_prime-K) );
    clear IntermediateSymbols;
    EncSourceSymbols = EncSymbols(1:K);
    EncRepairSymbols = EncSymbols(K_prime+1:end);
    % Exclude the zero padding redundant symbols from the symbols sent
    genSyms(1:N,i) = [EncSourceSymbols EncRepairSymbols]';
    end

    clear EncSourceSymbols;
    clear EncRepairSymbols ;
    %Encoding Symbol ID (ESI), (24 bits): An, unsigned integer): A nonnegative integer identifier for the
    %encoding symbols within the packet.
    genESIs = 0:(N-1);
    char(genSyms(1:K,1:T))
    char(genSyms)
     [genESIs' genSyms]
    
   %Writing the Encoding symbols and there ESIs in the outfile
    dlmwrite( outfile, [genESIs' genSyms], ' ' )
elseif (str == 'w') %Generate the random source symbols and encoding symbols 
    [genSyms genESIs] = rfc6330_generateNsymbols( N , K );
    dlmwrite(filename, [genESIs' genSyms'], ' ' )
end
clear genSyms;
clear genESIs;