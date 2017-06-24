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




clear all
close all
clc

%Profile function helps you debug and optimize MATLAB code files by tracking their execution time, close the proviously started profiler
profile off

%The Profiler uses wall-clock time 
profile -timer 'real' 
profile on

% This is a script that verifies the validity of the tools that generate
% the encoding symbols from the encoder and the decoder.
%--------------------------------------------------------------------------
% General encoding parameters
K = 1024;                                        % Number of source symbols
N = 3072;                                       % Number of encoding symbols
T = 256;                                       %Size of Each Symbol
str = 'r';                                   % Read/Write operation
start_line=2;                                % Starting line of the input file(here bible.txt)    

%--------------------------------------------------------------------------
if (str == 'w')
    % 1a. Generate K source symbols and feed them into the encoder. The symbols
    % are generated from scratch and are written in some output file.
    filename = '1a_1_out_enc_syms_test.txt';
%     K = rfc6330_test_gen_enc_symbol_file(filename,K,N,str);
    K = rfc6330_test_gen_enc_symbol_file(filename,K,N,T);
else if (str == 'r')
        % 1b. Generate a new file with starting line of the original file as its first line.
        %Read K source symbols from a new file and feed them into the encoder. The
        % encoding symbols are written in some output file. Comment it if you want
        % to write to file.
        filename=  rfc6330_new_textfile_gen('bible.txt',start_line);
        outfile  = 'K=1024_N=3072_T=256.txt';
        K        = rfc6330_test_gen_enc_symbol_file(filename,K,N,str,outfile,T);
    end
end

%--------------------------------------------------------------------------
% 2. Pass the encoding symbols from the channel having parameters k, seed
infile  = 'K=1024_N=3072_T=256.txt';
outfile = 'A001_K=1024_N=3072_T=256.txt';
k = 1025;     %total k Symbol out of N Symbols must reach the receiver. k is a channel parameter, in order to have successful decoding k>=K
seed  = 0;  % Another Channel parameter
[recESIs recSyms] = rfc6330_pick_k_N(infile, outfile, seed, k, N, K);
clear recESIs;
clear recSyms;
% % %--------------------------------------------------------------------------
% % 3. Pass the received encoding symbols though the decoder.
% % infile  = 'in_dec_syms.txt';
% infile  = outfile;                   %The file in which the recieved symbols are stored
% outfile = '4_out_dec_syms.txt';        %The file in which the the decoded symbols are stored
% flag = rfc6330_test_generate_dec_output(K,infile,outfile,T);

S = profile('status') %Gives the status of the profiler in use and its other details
profile viewer        %Displays the profiler                                          