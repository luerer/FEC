function [InterSym_B InterSym_E1 InterSym_E2] = rfc6330_A_LA3_inversion(A_LA_3,sourceSymbols,K,B,E1,E2)

B_prime = rfc6330_K_prime(B);
N_B = 2*B_prime-1;
E1_prime = rfc6330_K_prime(E1);
N_E1 = 2*E1_prime-1;
E2_prime = rfc6330_K_prime(E2);
N_E2 = 2*E2_prime-1;
ISIs_B = 0:(B_prime-1);
ESIs_B = ISIs_B(1:B);
ISIs_E1 = 0:(E1_prime-1);
ESIs_E1 = ISIs_E1(1:E1);
ISIs_E2 = 0:(E2_prime-1);
ESIs_E2 = ISIs_E2(1:E2);
[S_b H_b B_b U_b L_b W_b P_b P1_b] = rfc6330_parameters( B_prime );
[S_e H_e B_e U_e L_e W_e P_e P1_e] = rfc6330_parameters( E1_prime );
[S_e2 H_e2 B_e2 U_e2 L_e2 W_e2 P_e2 P1_e2] = rfc6330_parameters( E2_prime );

Sys_B = [zeros(1,S_b+H_b) sourceSymbols(1:B) zeros(1,B_prime-B)];
Sys_E1 = [zeros(1,S_e+H_e) sourceSymbols(B+1:B+E1) zeros(1,E1_prime-E1)];
Sys_E2 = [zeros(1,S_e2+H_e2) sourceSymbols(B+E1+1:end) zeros(1,E2_prime-E2)];
len_A1 = S_b+H_b+B_prime;
len_A2 = S_e+H_e+E1_prime;
len_A3 = S_e2+H_e2+E2_prime;

A1=A_LA_3(1:len_A1,1:len_A1);
A2=A_LA_3(len_A1+1:len_A1+len_A2,len_A1+1:len_A1+len_A2);
A3=A_LA_3(len_A1+len_A2+1:end,len_A1+len_A2+1:end);
B11=A_LA_3(len_A1+1:len_A1+len_A2,1:len_A1);
B12=A_LA_3(len_A1+len_A2+1:end,1:len_A1);
B21=A_LA_3(len_A1+len_A2+1:end,len_A1+1:len_A1+len_A2);

[Inter_BSym] = rfc6330_inversion(A1,Sys_B,B);
[Inter_E1Sym] = rfc6330_inversion(A2,Sys_E1,E1);
[Inter_E2Sym] = rfc6330_inversion(A3,Sys_E2,E2);
B11A1base=GF_multiply(B11,Inter_BSym');
X1base = rfc6330_inversion(A2,B11A1base',E1);
temp1=zeros(1,length(X1base));
for ii = 1:length(X1base)
	temp1(ii)=bitxor(X1base(ii),Inter_E1Sym(ii));

end

B21_temp = GF_multiply(B21,temp1');
part1 = rfc6330_inversion(A3,B21_temp',E2);

B12_temp = GF_multiply(B12,Inter_BSym');
part2 = rfc6330_inversion(A3,B12_temp',E2);

temp2=zeros(1,length(Inter_E2Sym));
for ii = 1:length(Inter_E2Sym)
	temp2(ii) = bitxor(part1(ii),part2(ii));
    temp2(ii) = bitxor(temp2(ii),Inter_E2Sym(ii));
end

InterSym_B = Inter_BSym;
InterSym_E1 = temp1;
InterSym_E2 = temp2;

