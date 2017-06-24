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




function coeff = rfc6330_findcoeff( alpha1, alpha2 )
%
% This function returns the coefficient that some row must be multiplied
% with so that its first coefficient is eliminated. It is used during the
% Gaussian Elimination step of the decoding.
% coeff * alpha1 = alpha2
% To find the multiplicative inverse of alpha1:
% coeff * alpha1 = 1 => coeff = rfc6330_findcoeff( alpha1, 1 )
%
%
coeff = zeros(1,255);
for ii = 1:255
    if (alpha1 == 0)
        error('Trying to retrieve the multiplicative inverse of 0!')
    elseif (alpha1 == 1)
        coeff(ii) = ii;
    elseif (ii == 1)
        coeff(ii) = alpha1;
    else
        coeff(ii) = rfc6330_gfmult( ii, alpha1 );
    end
end
coeff = find( coeff == alpha2 );