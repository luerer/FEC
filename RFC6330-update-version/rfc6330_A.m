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




function A = rfc6330_A( K_prime, ISIs )
%
% Calculates matrix A from section 5.3.3.3.
%
% Input:
%  K_prime - number of symbols in the extended source block
%     ISIs - internal symbol IDs
% Output:
%  A - matrix A for the calculation of the intermediate symbols

%The addition of two octets u and v defined as the XOR operation, i.e.,u + v = u ^ v.
%
%
%
if nargin==1,
    ISIs = 0:(K_prime-1);
end;

% compute the rfc6330 code parameters
[S H B U L W P P1] = rfc6330_parameters( K_prime );

% allocate space for decoding matrix
A = zeros(S+H+length(ISIs),L);

% LDPC Symbols
% See section 5.3.3.3 Pre-coding relationships
for ii = 0:(B-1)
    a           = 1 + floor(ii/S);
    b           = mod(ii,S);
    A(b+1,ii+1) = bitxor(A(b+1,ii+1),1);
    b           = mod( (a+b), S );
    A(b+1,ii+1) = bitxor(A(b+1,ii+1),1);
    b           = mod((a+b),S);
    A(b+1,ii+1) = bitxor(A(b+1,ii+1),1);
end
% Obsolete in Version of November 2009
% if (U > 0)
%     for ii =  0:(S-1)
%         m             = mod(ii,U);
%         A(ii+1,m+1+B+S) = bitxor(A(ii+1,m+1+B+S),1);
%     end
% end
% Replaces previous code
for ii = 0:(S-1)
    a = mod(ii,P);
    b = mod(ii+1,P);
    A(ii+1,W+a+1) = bitxor(A(ii+1,W+a+1),1);
    A(ii+1,W+b+1) = bitxor(A(ii+1,W+b+1),1);
%     A(mod(ii,S)+1,W+a+1) = bitxor(A(mod(ii,S)+1,W+a+1),1);
%     A(mod(ii,S)+1,W+b+1) = bitxor(A(mod(ii,S)+1,W+b+1),1);
end

% insert SxS identity matrix
A(1:S,B+1:B+S) = eye(S);%     A(ii+1,W+a+1) = bitxor(A(ii+1,W+a+1),1);
%     A(ii+1,W+b+1) = bitxor(A(ii+1,W+b+1),1);

% HDPC Symbols
% See section 5.3.3.3 Pre-coding relationships
% MT denote an H x (K' + S) matrix of octets,
% Matrix MT generation
for jj = 1:(K_prime + S - 1)
    ii = rfc6330_rand( jj, 6, H );
    A(S+ii+1,jj) = bitxor(A(S+ii+1,jj),1);
    %A(S+ii+1,jj) = 1;
    ii = mod(rfc6330_rand( jj, 6, H )+rfc6330_rand( jj, 7, H-1 )+1, H);
    A(S+ii+1,jj) = bitxor(A(S+ii+1,jj),1);
    %A(S+ii+1,jj) = 1;
end


A((S + 1):(S + H),K_prime + S) = rfc6330_gfpower(0:(H-1)); %Formation of the last coloumn of matrix MT
% GAMMA denote the a (K'+S ) x (K'+S ) matrix of octets
% G_HDPC=MT*GAMMA; the multiplication is not normal matrix multiplication
% but GF matrix multiplication
A((S + 1):(S + H),1:(K_prime + S)) = ...
    rfc6330_gfMatrixMult( A((S + 1):(S + H),1:(K_prime + S)), ...
    rfc6330_gamma( K_prime, S ) );

% insert HxH identity matrix
A(S+1:S+H,B+S+U+1:B+S+U+H) = eye(H);

% rows which are ISI-specific
% See section 5.3.5.3. LT Encoding Symbol Generator
for ii = 1:length(ISIs)
    % obtain (d,a,b) triple for given ISI
    [ d, a, b, d1, a1, b1 ] = rfc6330_tuple( K_prime, ISIs(ii) );
    A(ii+S+H,1+b) = 1;
    for jj = 1:(d-1)
        b = mod(b+a,W);
        A(ii+S+H,1+b) = bitxor(A(ii+S+H,1+b),1);
    end
    while (b1>=P)
        b1 = mod(b1+a1,P1);
    end
    A(ii+S+H,1+b1+W) = bitxor(A(ii+S+H,1+b1+W),1);
    for jj = 1:(d1-1)
        b1 = mod(b1+a1,P1);
        while (b1>=P)
            b1 = mod(b1+a1,P1);
        end
        A(ii+S+H,1+b1+W) = bitxor(A(ii+S+H,1+b1+W),1);
    end
end

% SB = A(1:S,1:B)
% SS = A(1:S,(B+1):(B+S))
% SU = A(1:S,(B+S+1):(B+S+U))
% SH = A(1:S,(B+S+U+1:B+U+S+H))
% HH = A((S+1):S+H,(B+S+U+1:B+U+S+H))