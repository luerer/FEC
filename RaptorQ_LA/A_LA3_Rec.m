function RecIntermediateSymbols = A_LA3_Rec(B,E1,E2,RecISIs_B,RecISIs_E1,RecISIs_E2,RecSymbols_B,RecSymbols_E1,RecSymbols_E2)

K = B+E1+E2;
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

A1 = rfc6330_A(B_prime,RecISIs_B);
RecSym_B = [zeros(1,length(A1(:,1))-length(RecSymbols_B)) RecSymbols_B(:).'];
RecInt_B = rfc6330_inversion(A1,RecSym_B,B);

A2 = rfc6330_A(E1_prime,RecISIs_E1);
RecSym_E1 = [zeros(1,length(A2(:,1))-length(RecSymbols_E1)) RecSymbols_E1(:).'];
RecInt_E1 = rfc6330_inversion(A2,RecSym_E1,E1);

A3 = rfc6330_A(E2_prime,RecISIs_E2);
RecSym_E2 = [zeros(1,length(A3(:,1))-length(RecSymbols_E2)) RecSymbols_E2(:).'];
RecInt_E2 = rfc6330_inversion(A3,RecSym_E2,E2);


B11 = zeros(S_e+H_e+length(RecISIs_E1),L_b);
RecISIs_LA_11 = RecISIs_E1+B_prime;
for ii = 1:length(RecISIs_LA_11)
    % obtain (d,a,b) triple for given ISI
    [ d, a, b, d1, a1, b1 ] = rfc6330_tuple( B_prime, RecISIs_LA_11(ii) );
    B11(S_e+H_e+ii,1+b) = 1;
    for jj = 1:(d-1)
        b = mod(b+a,W_b);
        B11(S_e+H_e+ii,1+b) = bitxor(B11(S_e+H_e+ii,1+b),1);
    end
    while (b1>=P_b)
        b1 = mod(b1+a1,P1_b);
    end
    B11(S_e+H_e+ii,1+b1+W_b) = bitxor(B11(S_e+H_e+ii,1+b1+W_b),1);
    for jj = 1:(d1-1)
        b1 = mod(b1+a1,P1_b);
        while (b1>=P_b)
            b1 = mod(b1+a1,P1_b);
        end
        B11(S_e+H_e+ii,1+b1+W_b) = bitxor(B11(S_e+H_e+ii,1+b1+W_b),1);
    end
end
B11_temp = GF_multiply(B11,RecInt_B');
part = rfc6330_inversion(A2,B11_temp',E1);
temp1=zeros(1,length(RecInt_E1));
for ii = 1:length(RecInt_E1)
	temp1(ii)=bitxor(part(ii),RecInt_E1(ii));
end

B12 = zeros(S_e2+H_e2+length(RecISIs_E2),L_b);
RecISIs_LA_12 = RecISIs_E2+E1_prime+B_prime;
for ii = 1:length(RecISIs_LA_12)
    % obtain (d,a,b) triple for given ISI
    [ d, a, b, d1, a1, b1 ] = rfc6330_tuple( B_prime, RecISIs_LA_12(ii) );
    B12(S_e2+H_e2+ii,1+b) = 1;
    for jj = 1:(d-1)
        b = mod(b+a,W_b);
        B12(S_e2+H_e2+ii,1+b) = bitxor(B12(S_e2+H_e2+ii,1+b),1);
    end
    while (b1>=P_b)
        b1 = mod(b1+a1,P1_b);
    end
    B12(S_e2+H_e2+ii,1+b1+W_b) = bitxor(B12(S_e2+H_e2+ii,1+b1+W_b),1);
    for jj = 1:(d1-1)
        b1 = mod(b1+a1,P1_b);
        while (b1>=P_b)
            b1 = mod(b1+a1,P1_b);
        end
        B12(S_e2+H_e2+ii,1+b1+W_b) = bitxor(B12(S_e2+H_e2+ii,1+b1+W_b),1);
    end
end
B12_temp = GF_multiply(B12,RecInt_B');
part1 = rfc6330_inversion(A3,B12_temp',E2);

B21 = zeros(S_e2+H_e2+length(RecISIs_E2),L_e);
RecISIs_LA_21 = RecISIs_E2+E1_prime;
for ii = 1:length(RecISIs_LA_21)
    % obtain (d,a,b) triple for given ISI
    [ d, a, b, d1, a1, b1 ] = rfc6330_tuple( E1_prime, RecISIs_LA_21(ii) );
    B21(S_e2+H_e2+ii,1+b) = 1;
    for jj = 1:(d-1)
        b = mod(b+a,W_e);
        B21(S_e2+H_e2+ii,1+b) = bitxor(B21(S_e2+H_e2+ii,1+b),1);
    end
    while (b1>=P_e)
        b1 = mod(b1+a1,P1_e);
    end
    B21(S_e2+H_e2+ii,1+b1+W_e) = bitxor(B21(S_e2+H_e2+ii,1+b1+W_e),1);
    for jj = 1:(d1-1)
        b1 = mod(b1+a1,P1_e);
        while (b1>=P_e)
            b1 = mod(b1+a1,P1_e);
        end
        B21(S_e2+H_e2+ii,1+b1+W_e) = bitxor(B21(S_e2+H_e2+ii,1+b1+W_e),1);
    end
end
B21_temp = GF_multiply(B21,temp1');
part2 = rfc6330_inversion(A3,B21_temp',E2);

temp2=zeros(1,length(RecInt_E2));
for ii = 1:length(RecInt_E2)
	temp2(ii)=bitxor(part1(ii),part2(ii));
    temp2(ii)=bitxor(temp2(ii),RecInt_E2(ii));
end

RecIntermediateSymbols = zeros(1,length(RecInt_B)+length(RecInt_E1)+length(RecInt_E2));
RecIntermediateSymbols(1:length(RecInt_B)) = RecInt_B(:).';

RecIntermediateSymbols(length(RecInt_B)+1:length(RecInt_E1)) = temp1(:).';
RecIntermediateSymbols(length(RecInt_E1)+1:end) = temp2(:).';
