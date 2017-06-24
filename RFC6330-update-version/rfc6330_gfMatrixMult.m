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


function A = rfc6330_gfMatrixMult( H, G )
%
% Matrix multiplication where both H, G matrices have elements in GF(256)
%
% Input: 
%  H,G - Input matrices
% Output: 
%    A - Output matrix - A = H*G
%
[HROWS HCOLS] = size(H);
[GROWS GCOLS] = size(G);
if ( HCOLS ~= GROWS )
    error('Matrix sizes do not fit!')
end

A = zeros(HROWS,GCOLS);
for ii = 1:HROWS
    for jj = 1:GCOLS
        for kk = 1:HCOLS
            if ((H(ii,kk) == 0)||(G(kk,jj) == 0))
                coeff = 0;
            elseif (H(ii,kk) == 1)
                coeff = G(kk,jj);
            elseif (G(kk,jj) == 1)
                coeff = H(ii,kk);
            else
                coeff = rfc6330_gfmult(H(ii,kk),G(kk,jj));
            end
            A(ii,jj) = bitxor(A(ii,jj),coeff);
        end
    end
end