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



function [val RecoveredSymbols] = rfc6330_receiveSymbols( RecESIs, SentSymbols, K, T )
% Receiving side
RecESIs;
K_prime = rfc6330_K_prime( K );
% Recover the ISIs -RecISIs- from the received ESIs -RecESIs.
disp('Recovering symbols')
indSource = find(RecESIs < K);
sourceESIs  = RecESIs(find(RecESIs < K));
indRepair = find(RecESIs >= K);
repairESIs  = RecESIs(find(RecESIs >= K));
repairISIs = [];
if (~isempty(repairESIs))
    repairISIs = repairESIs + K_prime - K;
end
paddingISIs = K:(K_prime-1);
RecISIs = [sourceESIs paddingISIs repairISIs];
% Recover the sent symbols from the received ESIs
SentSymbols=(SentSymbols)';
for i=1:T
    RecSymbols = SentSymbols(i,indSource);
    RecSymbols = [RecSymbols zeros(1,K_prime-K)];
    RecSymbols = [RecSymbols SentSymbols(i,indRepair)];


% Compute matrix A for the computation of Intermediate Symbols
%L x L matrix A over GF(256)of octet such that A*C = D
RecA = rfc6330_A( K_prime, RecISIs );
% Zero-pad at the beginning to create the D vector of the linear system -
% according to the notation A*C = D
RecSym = [ zeros(1,length(RecA(:,1))-length(RecSymbols)) RecSymbols(:).' ];
% Solve the linear system to obtain the intermediate symbols
clear RecSymbols;
RecIntermediateSymbols = rfc6330_inversion( RecA, RecSym, K );
clear RecA;
clear RecSym;

% Combine appropriately the intermediate symbols to produce the initial
% source symbols
RecoveredSymbols(1:K,i) = [rfc6330_gen_encoding_symbol( K_prime, RecIntermediateSymbols, 0:(K-1) )]';
end
val=0;
for i=1:K
    val=val+sum(RecoveredSymbols(i,:)); 
end
