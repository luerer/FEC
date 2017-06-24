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



function Gamma = rfc6330_gamma( K_prime, S )
%
% Calculates matrix Gamma needed for the GF(256) arithmetic.
% The construction is described in section 5.3.3.3.
% Field : GF(256)
% Irreducible polynomial: 
%        f(x) = x^8 + x^4 + x^3 + x^2 + 1 = 0x100011101b
% Primitive Elment: alpha = x = 0x10b
%
% Input:
%  K_prime - number of symbols in the extended source block
%        S - number of LDPC symbols
% Output:
%    Gamma - (K_prime + S)x(K_prime + S) matrix with elements from GF(256)
%
%
%Gamma = zeros( K_prime + S );
for jj = 1:(K_prime + S)
    for ii = jj:(K_prime + S)
        Gamma(ii,jj) = rfc6330_gfpower(ii-jj);
    end
end