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

tic
% Number of source symbols
K = 600;
% Compute the number of the extended source block
K_prime = rfc6330_K_prime( K );
% Number of symbols to be sent
N = 2*K_prime-1;
% Generate source Symbols
%SourceSymbols = mod(1:K,256);
%SourceSymbols = floor(K_prime*rand(1,K))
filename = 'bible_tmp.txt';
fid = fopen(filename,'r');
myline = fgets(fid);
inputSyms = double(myline);
SourceSymbols = inputSyms(1:K);
fclose(fid);
%SourceSymbols = [73 110 32 116 104 101 32 98 101 103 105 110 110 105 110 103]
char(SourceSymbols)
% Zero pad source Symbols to create extended block
ExtendedSymbols = [SourceSymbols zeros(1,K_prime-K)];
% Assign Internal Symbol IDs
ISIs = 0:(K_prime-1);
% Assign Encoding Symbol IDs
ESIs = ISIs(1:K);
% Compute the corresponding rfc6330 parameters
[S H B U L W P P1] = rfc6330_parameters( K_prime );
% Compute matrix A for the computation of Intermediate Symbols
A = rfc6330_A( K_prime, ISIs );
% Zero-pad at the beginning to create the 'b' vector of the linear system -
% according to the notation: Ax = b
Sym = [ zeros(1,length(A)-length(ExtendedSymbols)) ExtendedSymbols(:).' ]
% % Solve the linear system to obtain the intermediate symbols
%IntermediateSymbols = rfc6330_gaussian( A, Sym );
[IntermediateSymbols] = rfc6330_inversion( A, Sym, K )
%char(rfc6330_gfMatrixMult(A,IntermediateSymbols.')')
%sum(bitxor(rfc6330_gfMatrixMult( A, IntermediateSymbols.'), Sym.'))
% Combine appropriately the intermediate symbols to produce the encoding
% symbols (source symbols-repair symbols)
%EncSymbols = rfc6330_gen_encoding_symbol( K_prime, IntermediateSymbols, 0:N-K+K_prime-1 )
EncSymbols = rfc6330_gen_encoding_symbol( K_prime, IntermediateSymbols, 0:N-1 );
EncSourceSymbols = EncSymbols(1:K)
EncRepairSymbols = EncSymbols(K_prime+1:end);
% Exclude the zero padding redundant symbols from the symbols sent
SentSymbols = [EncSourceSymbols EncRepairSymbols];
SentSymbols
char(SentSymbols)

RecAllESIs = 0:(length(SentSymbols)-1);
RecSourceESIs = 0:(K-1);
RecRepairESIs = K:(length(SentSymbols)-1);
% Specify the ESIs to be received.
% RecESIs = RecAllESIs;
% RecESIs = RecSourceESIs;
% RecESIs = RecRepairESIs;
% RecESIs = RecAllESIs(1:2:end);
% Receive the first K repair symbols
% RecESIs = RecRepairESIs(1:K);
% m = 7;
% RecESIs = [RecSourceESIs(1:K-m) RecRepairESIs(1:m)]
% Receive all but 2 of the source symbols and twice the first repair
% symbol. Decoding failure.
% RecESIs = [RecSourceESIs(1:K-2) RecRepairESIs(1) RecRepairESIs(1)]
errProb = 0.4;
RecESIs = [];
for ind = 0:(length(SentSymbols)-1)
    if (rand > errProb)
        RecESIs = [RecESIs ind];
    end
end
if (length(RecESIs) < K)
    disp('Insufficient number of collected symbols!')
    disp('Decoding will fail!')
end
% Receiving side
% Recover the ISIs -RecISIs- from the received ESIs -RecESIs.
indSource  = RecESIs(find(RecESIs < K));
indRepair  = RecESIs(find(RecESIs >= K));
if (~isempty(indRepair))
    indRepair = indRepair + K_prime - K;
end
indPadding = K:(K_prime-1);
RecISIs = [indSource indPadding indRepair];
% Recover the sent symbols from the received ESIs
RecSymbols = SentSymbols(indSource+1);
RecSymbols = [RecSymbols zeros(1,K_prime-K)];
RecSymbols = [RecSymbols SentSymbols(indRepair - K_prime + K + 1)];

% Create the matrix A for the linear system
RecA = rfc6330_A( K_prime, RecISIs );
% Zero-pad at the beginning to create the 'b' vector of the linear system -
% according to the notation: Ax = b
RecSym = [ zeros(1,length(RecA(:,1))-length(RecSymbols)) RecSymbols(:).' ];
% Solve the linear system to obtain the intermediate symbols
%RecIntermediateSymbols = rfc6330_gaussian( RecA, RecSym )
%sum(RecA,2)'
RecIntermediateSymbols = rfc6330_inversion( RecA, RecSym, K );
% Combine appropriately the intermediate symbols to produce the initial
% source symbols
RecoveredSymbols = rfc6330_gen_encoding_symbol( K_prime, RecIntermediateSymbols, ESIs )
char(RecoveredSymbols)
sum(abs(RecoveredSymbols-SourceSymbols))
toc