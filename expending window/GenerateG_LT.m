%Test Raptor
clc;
clear all;
%********************************SNR*************************************%
SNR=0:1:10;
err=zeros(3,length(SNR));
currentSNR=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = 64800;
M = 32400;
MaxN = 140000; %maximum N 29972
Base = 2; %base for codeword
CurrentN = MaxN*0.5;%LT coded symbols
% Method for creating LDPC matrix (0 = Evencol; 1 = Evenboth)
method = 1;
% Eliminate length-4 cycle
noCycle = 1;
% Number of 1s per column for LDPC matrix
onePerCol = 3;
% LDPC matrix reorder strategy (0 = First; 1 = Mincol; 2 = Minprod)
strategy = 2;
% Number of iteration;
iter = 20;
%LDPC check matrix
% H = makeLdpc(M, N, 1, 1, onePerCol);
tic
hEnc = comm.LDPCEncoder();
hDec = comm.LDPCDecoder();
fprintf('LDPC H matrix using time:');
toc
tic
%LT Fountain matrix with priority window
Window = [ceil(N*(1/4)), N];
G_LT = GenerateG(N, CurrentN, Window);
% save -v7.3 G_LT.mat G_LT;
load G_LT.mat;
fprintf('LT G matrix using time:');
toc
