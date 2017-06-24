function A = rfc6330_A_LA3(K,B,E1,E2)
%
%To generate a matrix for LA_RaptorQ encoding
%
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

A1 = rfc6330_A(B_prime);
A2 = rfc6330_A(E1_prime);
A3 = rfc6330_A(E2_prime);
[R1 C1] = size(A1);
[R2 C2] = size(A2);
[R3 C3] = size(A3);
A = zeros(R1+R2+R3,C1+C2+C3);
A(1:R1,1:C1) = A1;
A(R1+1:R1+R2,C1+1:C1+C2) = A2;
A(R1+R2+1:end,C1+C2+1:end) = A3;

ISI_LA_11 = B_prime:(B_prime+E1_prime-1);
ISI_LA_12 = (B_prime+E1_prime):(B_prime+E1_prime+E2_prime-1);
ISI_LA_21 = E1_prime:(E1_prime+E2_prime-1);
%A3 = rfc6330_A(base_prime,ISI_LA)
%B11-----------------
for ii = 1:length(ISI_LA_11)
    % obtain (d,a,b) triple for given ISI
    [ d, a, b, d1, a1, b1 ] = rfc6330_tuple( B_prime, ISI_LA_11(ii) );
%   [S H B U L W P P1] = rfc6330_parameters( base_prime );
    A(R1+S_e+H_e+ii,1+b) = 1;
    for jj = 1:(d-1)
        b = mod(b+a,W_b);
        A(R1+S_e+H_e+ii,1+b) = bitxor(A(R1+S_e+H_e+ii,1+b),1);
    end
    while (b1>=P_b)
        b1 = mod(b1+a1,P1_b);
    end
    A(R1+S_e+H_e+ii,1+b1+W_b) = bitxor(A(R1+S_e+H_e+ii,1+b1+W_b),1);
    for jj = 1:(d1-1)
        b1 = mod(b1+a1,P1_b);
        while (b1>=P_b)
            b1 = mod(b1+a1,P1_b);
        end
        A(R1+S_e+H_e+ii,1+b1+W_b) = bitxor(A(R1+S_e+H_e+ii,1+b1+W_b),1);
    end
end
%B12--------------------
for ii = 1:length(ISI_LA_12)
    % obtain (d,a,b) triple for given ISI
    [ d, a, b, d1, a1, b1 ] = rfc6330_tuple( B_prime, ISI_LA_12(ii) );
%   [S H B U L W P P1] = rfc6330_parameters( base_prime );
    A(R1+R2+S_e2+H_e2+ii,1+b) = 1;
    for jj = 1:(d-1)
        b = mod(b+a,W_b);
        A(R1+R2+S_e2+H_e2+ii,1+b) = bitxor(A(R1+R2+S_e2+H_e2+ii,1+b),1);
    end
    while (b1>=P_b)
        b1 = mod(b1+a1,P1_b);
    end
    A(R1+R2+S_e2+H_e2+ii,1+b1+W_b) = bitxor(A(R1+R2+S_e2+H_e2+ii,1+b1+W_b),1);
    for jj = 1:(d1-1)
        b1 = mod(b1+a1,P1_b);
        while (b1>=P_b)
            b1 = mod(b1+a1,P1_b);
        end
        A(R1+R2+S_e2+H_e2+ii,1+b1+W_b) = bitxor(A(R1+R2+S_e2+H_e2+ii,1+b1+W_b),1);
    end
end
%B21-------------------
for ii = 1:length(ISI_LA_21)
    % obtain (d,a,b) triple for given ISI
    [ d, a, b, d1, a1, b1 ] = rfc6330_tuple( E1_prime, ISI_LA_21(ii) );
%   [S H B U L W P P1] = rfc6330_parameters( base_prime );
    A(R1+R2+S_e2+H_e2+ii,1+b+C1) = 1;
    for jj = 1:(d-1)
        b = mod(b+a,W_e);
        A(R1+R2+S_e2+H_e2+ii,1+b+C1) = bitxor(A(R1+R2+S_e2+H_e2+ii,1+b+C1),1);
    end
    while (b1>=P_e)
        b1 = mod(b1+a1,P1_e);
    end
    A(R1+R2+S_e2+H_e2+ii,1+b1+W_e+C1) = bitxor(A(R1+R2+S_e2+H_e2+ii,1+b1+W_e+C1),1);
    for jj = 1:(d1-1)
        b1 = mod(b1+a1,P1_e);
        while (b1>=P_e)
            b1 = mod(b1+a1,P1_e);
        end
        A(R1+R2+S_e2+H_e2+ii,1+b1+W_e+C1) = bitxor(A(R1+R2+S_e2+H_e2+ii,1+b1+W_e+C1),1);
    end
end
