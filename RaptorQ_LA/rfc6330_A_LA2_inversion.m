function IntermediateSymbols = rfc6330_A_LA_inversion(A_LA,sourceSymbols,K,base)

enhance = K-base;
base_prime = rfc6330_K_prime(base);
enhance_prime = rfc6330_K_prime(K-base);
[S_b H_b B_b U_b L_b W_b P_b P1_b] = rfc6330_parameters( base_prime );
[S_e H_e B_e U_e L_e W_e P_e P1_e] = rfc6330_parameters( enhance_prime );
Sys_base = [zeros(1,S_b+H_b) sourceSymbols(1:base) zeros(1,base_prime-base)];
Sys_enhance = [zeros(1,S_e+H_e) sourceSymbols(base+1:end) zeros(1,enhance_prime-enhance)];
len_A1 = S_b+H_b+base_prime;
len_A2 = S_e+H_e+enhance_prime;

A1=A_LA(1:len_A1,1:len_A1);
A2=A_LA(len_A1+1:end,len_A1+1:end);
B=A_LA(len_A1+1:end,1:len_A1);

[Inter_baseSym] = rfc6330_inversion(A1,Sys_base,base);
[Inter_enhanceSym] = rfc6330_inversion(A2,Sys_enhance,enhance);
BA1base=GF_multiply(B,Inter_baseSym');
part = rfc6330_inversion(A2,BA1base',enhance);
temp=zeros(1,length(part));
for ii = 1:length(part)
	temp(ii)=bitxor(part(ii),Inter_enhanceSym(ii));

end
IntermediateSymbols = zeros(1,length(Inter_baseSym)+length(Inter_enhanceSym));
IntermediateSymbols(1:length(Inter_baseSym)) = Inter_baseSym(:).';
IntermediateSymbols(length(Inter_baseSym)+1:end) = temp(:).';


