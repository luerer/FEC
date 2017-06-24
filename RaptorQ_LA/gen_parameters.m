function gen_parameters(layer,lay_num)
	
prime_N = zeros(layer,2);
for ijj = 1:layer
    prime_N(ijj,1) = rfc6330_K_prime(lay_num(ijj));
    prime_N(ijj,2) = 2*prime_N(ijj,1)-1;
end
para_v = zeros(layer,8);
for ijj = 1:layer
        [S_b,H_b,B_b,U_b,L_b,W_b,P_b,P1_b]=rfc6330_parameters(prime_N(ijj));
        para_v(ijj,:) = [S_b,H_b,B_b,U_b,L_b,W_b,P_b,P1_b];
end
ISIs = cell(1,layer);
ESIs = cell(1,layer);
for ijj = 1:layer
    ISIs{ijj} = 0:(prime_N(ijj,1)-1);
    temp = 0:(prime_N(ijj,1));
    ESIs{ijj} = temp(1:lay_num(ijj));
end
save parameters;