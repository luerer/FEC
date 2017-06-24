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



function [ IL, IS, JL, JS ] = rfc6330_partition( I, J )
%function Partition[] takes a pair of positive integers (I, J) as
%input and derives four non-negative integers (IL, IS, JL, JS) as
%output.

% Partions a source block of size I into a number of J equal sized blocks
% Section: 4.3.1.2.  Source block and sub-block partitioning
%
% Input:
%   I - size of block to be partitioned
%   J - number of sub-blocks
% Output:
%  IL - number of large sub-blocks
%  IS - size of each large sub-block
%  JL - number of small sub-blocks
%  JS - size of each small sub-block
%
%
if (( I <= 0 )||( J <= 0 ))
    error('Input arguments must be positive integers!');
end
IL = ceil( I/J );
IS = floor( I/J );
JL = I - IS*J;
JS = J - JL;