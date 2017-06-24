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



function [ K, Z, T, N ] = rfc6330_subblocks( F, Al, T, Z, N )
%
% CAVEAT!: Z,N are overwritten at the end of this call!!!
%
%
% Partitions a source object of size F, symbol alignment parameter Al, symbol
% size T, number of source blocks Z and number of sub-blocks in each source
% block N, initially into source block and after that into subblocks.
% Section: 4.3.1.2.  Source block and sub-block partitioning
%
% Input:
%   F - size of source object
%  Al - symbol alignment parameter
%   T - symbol size
%   Z - number of source blocks
%   N - number of sub-block in each source block
% Output:
%   K - lengths of source blocks
%   Z - number of source blocks
%   T - lengths of sub-blocks
%   N - number of sub-blocks
%
%
Kt = ceil(F/T);
[ KL, KS, ZL, ZS ] = rfc6330_partition(Kt, Z);
[ TL, TS, NL, NS ] = rfc6330_partition(T/Al, N);
K = [ KL KS ];
Z = [ ZL ZS ];
T = [ TL TS ];
N = [ NL NS ];