function A = gen_G(K_prime,ISIs)

[S H B U L W P P1] = rfc6330_parameters( K_prime );
A = zeros(length(ISIs),L);
for ii = 1:length(ISIs)
    % obtain (d,a,b) triple for given ISI
    [ d, a, b, d1, a1, b1 ] = rfc6330_tuple( K_prime, ISIs(ii) );
    A(ii,1+b) = 1;
    for jj = 1:(d-1)
        b = mod(b+a,W);
        A(ii,1+b) = bitxor(A(ii,1+b),1);
    end
    while (b1>=P)
        b1 = mod(b1+a1,P1);
    end
    A(ii,1+b1+W) = bitxor(A(ii,1+b1+W),1);
    for jj = 1:(d1-1)
        b1 = mod(b1+a1,P1);
        while (b1>=P)
            b1 = mod(b1+a1,P1);
        end
        A(ii,1+b1+W) = bitxor(A(ii,1+b1+W),1);
    end
end