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



function syms = rfc6330_fread(filename,K)
% Reads the K Source symbols from the file which is passed onto the
% function
fid = fopen(filename,'r'); %Open the file for reading
syms = [];
len = 0;
while ( K - len  > 0 )
    myline = fgets(fid); %Reads the next line of the specified file, including the newline characters
    if myline == -1  %End of the file marker
        break;
    end
    inputSyms = double(myline);
    if (length(inputSyms) > K - len)
        syms = [syms inputSyms(1:(K-len))];
        len = length(syms);
    else
        syms = [syms inputSyms];
        len = len + length(inputSyms);
    end
end
count = length(syms);
if ( count < K )
    K = count;
    disp(['Only ',int2str(K),' entries read! This is the new K!'])
elseif ( count > K )
    syms = syms(1:K);
    disp([int2str(count),' entries read! Excess entries will be ignored!'])
end
fclose(fid);