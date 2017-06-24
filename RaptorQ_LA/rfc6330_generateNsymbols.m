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



function [genSyms genESIs] = rfc6330_generateNsymbols( N , K )
%
% Generate N symbols from a source block of K source symbols.
%


% Compute the number of the extended source block
K_prime = rfc6330_K_prime( K );
% Generate source Symbols
SourceSymbols = mod(1:K,256);
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