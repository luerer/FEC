function EncSym = A_LA_gen_encodesymbol(layer_t,InterSym)
%vector : lay_num(1xlayer)
%		  prime_N(layerx2)
%		  para_v(layerx8)
%cell   : ISIs{1,layer}
%		  ESIs{1,layer}
%[S H B U L W P P1] = rfc6330_parameters( K_prime );
% | | | | | | | |
%[1 2 3 4 5 6 7 8 ]
%----------parameters-----------------------------
%EncSym = cell(1,layer);
load parameters.mat;
Ite = 0:prime_N(layer_t,2)-1;
encode_temp = [];
index = layer_t-[1:layer_t-1];%[n-1 n-2 ... 1]
for ii = 1:layer_t
	if ii == 1
		ISI = Ite;
	elseif ii>1 
		ISI = Ite;
		for jj = 1:ii-1
			ISI = ISI+prime_N(index(jj),1);
		end
    end
%     disp (index)
    G_temp = gen_G(prime_N(layer_t+1-ii,1),ISI);
% 	G_temp = zeros(length(ISIs),para_v(layer+1-ii,5));

% 	for jj = 1:length(ISIs)
%         
% 	% obtain (d,a,b) triple for given ISI
% 		[ d, a, b, d1, a1, b1 ] = rfc6330_tuple( prime_N(layer+1-ii,1), ISIs(ii) );
% 		[S H B U L W P P1] = rfc6330_parameters( prime_N(layer+1-ii,1) );
% 		G_temp(jj,1+b) = 1;
% 		for jjj = 1:(d-1)
% 			b = mod(b+a,W);
% 			G_temp(jj,1+b) = bitxor(G_temp(jj,1+b),1);
% 		end
% 		while (b1>=P)
% 			b1 = mod(b1+a1,P1);
% 		end
% 		G_temp(jj,1+b1+W) = bitxor(G_temp(jj,1+b1+W),1);
% 		for jjj = 1:(d1-1)
% 			b1 = mod(b1+a1,P1);
% 			while (b1>=P)
% 			b1 = mod(b1+a1,P1);
% 			end
% 			G_temp(jj,1+b1+W) = bitxor(G_temp(jj,1+b1+W),1);
% 		end
%     end
   
	encode_temp = [G_temp encode_temp];
end

% [row1 col1] = size(encode_temp)
% [row2 col2] = size(InterSym(:).'')
EncSym = GF_multiply(encode_temp,InterSym(:).'');


EncSym = EncSym';
%encode_temp = [G_temp encode_temp];