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




%Precoding Relations Check using the Intermediate Symbols
%LDPC Relations

clc,
clear all;
close all;

K_prime=6;
C=[ 192, 163, 59, 37, 252, 175, 141, 89, 234, 16, 2, 78, 117, 179, 174, 3, 76, 184, 203, 222, 85 ];


[S H B U L W P P1] = rfc6330_parameters( K_prime )

for i=0:(S-1)
    A(i+1)=C(B+i+1);
    A(i+1)
end

disp('--------------------------------------------------------------')

for i=0:(B-1)
    a=1+floor(i/S);
    b=mod(i,S);
   	A(b+1)=bitxor(A(b+1),C(i+1));
    b=mod(b+a, S);
    A(b+1)=bitxor(A(b+1),C(i+1));
    b=mod(b+a, S);
    A(b+1)=bitxor(A(b+1),C(i+1));
end
for i=0:S-1
    a=mod(i,P);
    b=mod((i+1),P);
    k=bitxor(C(W+a+1),C(W+b+1));
    A(i+1)=bitxor(A(i+1),k);
end

A
disp('HDPC RELATIONS NOW')
%HDPC Relations
for i=0:H-1
   D(i+1)=C(K_prime+S+i+1);
   D(i+1)
end
disp('--------------------------------------------------------------')
u=C(1);
for j=1:(K_prime+S-1)
    pos1=rfc6330_rand(j,6,H);
   D(pos1+1)=bitxor(D(pos1+1),u);
    pos2=mod((pos1+rfc6330_rand(j,7,H-1)+1), H);
    D(pos2+1)=bitxor(D(pos2+1),u);
     z=rfc6330_gfmult( 2,u);
     u=bitxor(z, C(j+1));
end
 for i=0:H-1
     D(i+1)=bitxor(D(i+1),u);
     u=rfc6330_gfmult( 2,u);
 end
 
D
 