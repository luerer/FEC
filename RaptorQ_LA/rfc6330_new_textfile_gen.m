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



function filename = rfc6330_new_textfile_gen(file_original,start_line)

% Generates a new file whose text begins from the line which is mentioned
% as the start line in the specifications.

% Inputs:

% file_original: The material mentioned in the specification (Chapter 3
% Line 21 of the Conformance testing procedures)'bible.txt'.
% start_line: The line(in 'bible.txt') from which the text is to be selected for encoding 

% Output:

% filename: The new file where all text (beginning from the starting line)is copied onto.


% Open the file from which text is to be read.
fid = fopen(file_original,'r');

% Open the new file into which the text is be written.
fid2 = fopen('bible_new.txt','w');


if(start_line==0)
    start_line=start_line+1;
end

for present_line= 1: 30382
    tline = fgetl(fid); 
   
    if(present_line>=start_line)
       fprintf(fid2, '%s\n', tline);
    end
end


filename= 'bible_new.txt';
  
    