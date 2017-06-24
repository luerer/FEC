function A = rfc6330_A_LA(K,base)
%
%To generate a matrix for LA_RaptorQ encoding
%
base_prime = rfc6330_K_prime(base);
enhance = K-base;
enhance_prime = rfc6330_K_prime(enhance);
N_base = 2*base_prime-1;

A1 = rfc6330_A(base_prime);
A2 = rfc6330_A(enhance_prime);
[R1 C1] = size(A1);
[R2 C2] = size(A2);
A = zeros(R1+R2,C1+C2);
A(1:R1,1:C1) = A1;
A(R1+1:end,C1+1:end) = A2;

ISI_LA = base_prime:(enhance_prime+base_prime-1);
%A3 = rfc6330_A(base_prime,ISI_LA)
A3=zeros(length(ISI_LA),C1);
for ii = 1:length(ISI_LA)
    % obtain (d,a,b) triple for given ISI
    [ d, a, b, d1, a1, b1 ] = rfc6330_tuple( base_prime, ISI_LA(ii) );
    [S H B U L W P P1] = rfc6330_parameters( base_prime );
    A3(ii,1+b) = 1;
    for jj = 1:(d-1)
        b = mod(b+a,W);
        A3(ii,1+b) = bitxor(A3(ii,1+b),1);
    end
    while (b1>=P)
        b1 = mod(b1+a1,P1);
    end
    A3(ii,1+b1+W) = bitxor(A3(ii,1+b1+W),1);
    for jj = 1:(d1-1)
        b1 = mod(b1+a1,P1);
        while (b1>=P)
            b1 = mod(b1+a1,P1);
        end
        A3(ii,1+b1+W) = bitxor(A3(ii,1+b1+W),1);
    end
end

[R3 C3] = size(A3);
[S H B U L W P P1] = rfc6330_parameters( enhance_prime );
A(R1+S+H+1:end,1:C1) = A3;