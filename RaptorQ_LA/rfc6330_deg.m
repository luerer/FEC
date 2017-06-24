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



function val = rfc6330_deg( v, W )
%
% Implements the degree generator as described in the RFC6330
% Section 5.3.5.2. Degree Generator
%
% Input:
%   v - some non-negative integer such that 0<=v<=1048576
%   W - W is derived from K' as described in Section 5.3.3.3.
% Output:
% val - Given v find index d in table1 such that f[d-1] <= v < f[d]
%       % and set Deg[v] = d obsolete since November 2009
%       and set Deg[v] = min(d, W-2)
%

if (nargin < 1)
    error('Insufficient -less than 1- number of input arguments!');
end

if (v < 0)
    error('Input argument must be a non-negative integer!');
end

if (v > 2^20-1)
    error('Input argument must be less than 2^20!');
end

table1 = [
    0
    5243
    529531
    704294
    791675
    844104
    879057
    904023
    922747
    937311
    948962
    958494
    966438
    973160
    978921
    983914
    988283
    992138
    995565
    998631
    1001391
    1003887
    1006157
    1008229
    1010129
    1011876
    1013490
    1014983
    1016370
    1017662
    1048576];

val = find(v < table1) - 1;
if (length(val) > 1)
    val = val(1);
end
%disp(['(val,W-2) = (',int2str(val),',',int2str(W-2),')'])
val = min( val, W-2 );
%disp(['val = ',int2str(val)])