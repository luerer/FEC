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



function [returnSymbols A] = rfc6330_gaussian( A, Symbol )
%
% Implements the Gaussian Elimination as needed for the second phase of
% the decoding algorithm for rfc6330, described in RFC6330. See section
% 5.4.2.3. Second Phase.

[ROWS COLS] = size(A);

if ROWS~=length(Symbol),
    error('Invalid number of symbols');
end
rowexchanges = 0;
% Reduce matrix in row echelon form
for col = 1:COLS
    row = col;
    % search for a pivot
    ind = find(A(row:end,col)) + row - 1;
    if (isempty(ind))
        % If cannot find any non zero row decoding failed!
        disp('Decoding failed in Gaussian Elimination!')      % Always?
        returnSymbols = 0;
        return
    else
        pivot_row = ind(1);
    end
    % Exchange pivot row with the first row of matrix A
    % Exchange symbols
    if (pivot_row ~= row)
        temp           = A(row,:);
        A(row,:)       = A(pivot_row,:);
        A(pivot_row,:) = temp;
        TmpSymbol         = Symbol(col);
        Symbol(col)       = Symbol(pivot_row);
        Symbol(pivot_row) = TmpSymbol;
        rowexchanges = rowexchanges + 1;
    end
    if (A(row,col) ~= 1)
        % Normalize first coefficient of the chosen row
        coeff    = rfc6330_findcoeff( A(row,col), 1 );
        A(row,:) = rfc6330_gfmult_elementwise(coeff*ones(1,COLS),A(row,:));
        % Perform the same action to the corresponding symbol
        %disp(['Normalizing! Initially symbol at ',int2str(row),' = ',int2str(Symbol(row))])
        %disp(['Normalizing coefficient = ',int2str(coeff)])
        if (coeff == 1)
        elseif (Symbol(row) == 1)
            Symbol(row) = coeff;
        else
            Symbol(row) = rfc6330_gfmult(coeff,Symbol(row));
        end
        %disp(['After the normalization symbol at ',int2str(row),' = ',int2str(Symbol(row))])
    end
    % Eliminate rows
    for irow = (row+1):ROWS
        if (A(irow,col) ~= 0)
            %disp(['Symbol at position ',int2str(irow),' is ',int2str(Symbol(irow))])
            if (A(irow,col) == 1)
                coeff = Symbol(row);
            elseif (Symbol(row) == 1)
                coeff = A(irow,col);
            else
                coeff = rfc6330_gfmult(A(irow,col),Symbol(row));
            end
            Symbol(irow) = bitxor(coeff,Symbol(irow));
            mult_row     = rfc6330_gfmult_elementwise(A(irow,col)*ones(1,COLS),A(row,:));
            A(irow,:)    = bitxor(A(irow,:),mult_row);
        end
    end
end
A = A(1:COLS,1:COLS);
% Back-substitution
%disp('B A C K s u b s t i t u t i o n!')
for row = COLS-1:-1:1
    for col = (row+1):COLS
        if (A(row,col) ~= 0)
            if (Symbol(col) == 0)
                coeff = 0;
            elseif (Symbol(col) == 1)
                coeff = A(row,col);
            elseif (A(row,col) == 1)
                coeff = Symbol(col);
            else
                coeff = rfc6330_gfmult(A(row,col),Symbol(col));
            end
            Symbol(row) = bitxor(Symbol(row),coeff);
            A(row,:) = bitxor(A(row,:),...
                rfc6330_gfmult_elementwise(A(row,col)*ones(1,COLS),A(col,:)));
            %disp(['Symbol at position ',int2str(col),' is ',int2str(Symbol(col))])
        end
    end
end
%rowexchanges
returnSymbols = Symbol(1:COLS);