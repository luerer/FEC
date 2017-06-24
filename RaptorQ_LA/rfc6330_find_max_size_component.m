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



function ind_max = rfc6330_find_max_size_component( mat )
%
% This function finds the maximum size component in a matrix and
% returns the index of the first row that constitutes this component.
% For the input matrix, mat, a graph can be derived. Every column
% is a node in the graph. Every row that has exactly two '1' is an
% edge that connects the corresponding rows. A component is a set
% of edges and nodes, such that there is a path between every pair
% of nodes in it. Maximum component is the component that is consisted
% by the largest number of nodes. For the computation of the maximum
% size component a depth-first search is executed into the given graph.
%
weights = sum(mat,2);               % find weights of rows of input matrix
indices = find(weights == 2);       % Pick only the weight-2 rows
if (length(indices) == 1)
%     disp('Only one edge!')
    ind_max = indices;
    return;
end
mat = mat(indices,:);
mat = mat(:,find(sum(mat,1)));      % Drop all the all-zero columns, these
[ROWS COLS] = size(mat);            % nodes are disconnected.
adj_mat = zeros(COLS);              % Create the adjacency matrix
for ii = 1:ROWS
    r = find(mat(ii,:));
    adj_mat(r(1),r(2)) = 1;
    adj_mat(r(2),r(1)) = 1;
end
% Keep track of the nodes that have NEVER been visited!
remaining = zeros(1,COLS);
ind_max = 1;
max_comp_length = 0;
while (sum(remaining) < COLS)
    % Keep track of the nodes that are visited on THIS iteration.
    % They constitute the current component.
    visited = zeros(1,COLS);
    ii = find(remaining == 0 );
    ii = ii(1);
%     disp(['New component search. I start at node ',int2str(ii)])
    visited = rfc6330_explore( ii, adj_mat, visited );
    if (sum(visited) > max_comp_length)
%         disp(['I found a bigger component starting at node ',int2str(ii)])
        ind_max = ii;
        max_comp_length = sum(visited);
%         disp(['It has ',int2str(max_comp_length),' nodes!'])
    end
    remaining = bitor(visited,remaining);
end
ind_max = find(mat(:,ind_max));
ind_max = ind_max(1);
% Tranform the result into the initial matrix indices
ind_max = indices(ind_max);