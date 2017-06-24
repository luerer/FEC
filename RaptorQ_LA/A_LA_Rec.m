function RecInterSym = A_LA_Rec(RecSymbols,RecISIs)
%vector : lay_num(1xlayer)
%		  prime_N(layerx2)
%		  para_v(layerx8)
%cell   : ISIs{1,layer}
%		  ESIs{1,layer}
%[S H B U L W P P1] = rfc6330_parameters( K_prime );
% | | | | | | | |
%[1 2 3 4 5 6 7 8 ]
%----------parameters-----------------------------
load parameters.mat;
A = cell(1,layer);
B = cell(layer,layer);
for ii = 1:layer
	A{ii} = rfc6330_A(prime_N(ii,1),RecISIs{ii});
end
RecISIs_B = cell(layer,layer);
for ii = 2:layer
	for jj = 1:ii-1
		temp = prime_N(:,1)';
		RecISIs_B{ii,jj} = RecISIs{ii}+sum(temp(jj:ii-1));
	end
end
for ii = 2:layer
	for jj = 1:ii-1
%		row_t = (sum(para_v(1:ii-1,5))+1):sum(para_v(1:ii,5));
%		temp = [0 para_v(:,5)'];
%		column_t = (sum(temp(1:jj))+1):sum(temp(1:jj+1));
%		ISIs_t = ISIs_B{ii,jj};
		RecISIs_temp = RecISIs_B{ii,jj};
		B_temp = zeros(sum(para_v(ii,1:2))+length(RecISIs_temp),para_v(jj,5));
		G_temp = gen_G(prime_N(jj,1),RecISIs_temp);
		B_temp(sum(para_v(ii,1:2))+1:end,:) = G_temp;
%		A(sum(para_v(ii,1:2))+1:end,:) = G_temp;
%		A_LA(row_t,column_t) = A;
		B{ii,jj} = B_temp;
	end
end

Sym_t = cell(1,layer);
for ii = 1:layer
	temp = A{ii};
	Sym_t{ii} = [zeros(1,length(temp(:,1))-length(RecSymbols{ii})) RecSymbols{ii}];
end
RecInterSym = cell(1,layer);
for ii = 1:layer
	if ii == 1
		RecInterSym{ii} = rfc6330_inversion(A{ii},Sym_t{ii},lay_num(ii));
    elseif ii >= 2 
		temp = cell(1,ii);
		for jj = 1:ii-1
			temp{jj} = GF_multiply(B{ii,jj},RecInterSym{jj}');
			temp{jj} = temp{jj}';
		end
		temp{ii} = Sym_t{ii};
		result= 0;
		for jjj = 1:ii
			result = bitxor(result,temp{jjj});
		end
		RecInterSym{ii} = rfc6330_inversion(A{ii},result,lay_num(ii));

	end

end
