function [InterSym] = A_LA_inversion(layer,A_LA,ExtendedSymbols)
%vector : lay_num(1xlayer)
%		  prime_N(layerx2)
%		  para_v(layerx8)
%cell   : ISIs{1,layer}
%		  ESIs{1,layer}
%[S H B U L W P P1] = rfc6330_parameters( K_prime );
% | | | | | | | |
%[1 2 3 4 5 6 7 8 ]-------para_v
%----------parameters-----------------------------
load parameters.mat;
B = cell(layer,layer);
for ii = 2:layer
	for jj = 1:ii-1
		row_t = sum(para_v(1:ii-1,5))+1:sum(para_v(1:ii,5));
		temp = [0 para_v(:,5)'];
		column_t = sum(temp(1:jj))+1:sum(temp(1:jj+1));
		B{ii,jj} = A_LA(row_t,column_t) ;
	end
end
A = cell(1,layer);
for ii = 1:layer
	temp = [0 para_v(:,5)'];
	row_temp = sum(temp(1:ii))+1:sum(temp(1:ii+1));
	A{ii} = A_LA(row_temp,row_temp);
end
Sys = cell(1,layer);
for ii = 1:layer
	Sys{ii} = [zeros(1,sum(para_v(ii,1:2))) ExtendedSymbols{ii}];
end
InterSym = cell(1,layer);
for ii = 1:layer
	if ii == 1
		InterSym{ii} = rfc6330_inversion(A{ii},Sys{ii},lay_num(ii));
    elseif ii >= 2 
		temp = cell(1,ii);
		for jj = 1:ii-1
			temp{jj} = GF_multiply(B{ii,jj},InterSym{jj}');
			temp{jj} = temp{jj}';
		end
		temp{ii} = Sys{ii};
		result= 0;
		for jjj = 1:ii
			result = bitxor(result,temp{jjj});
		end
		InterSym{ii} = rfc6330_inversion(A{ii},result,lay_num(ii));
% 		InterSym{ii} = result;
	end

end

%save temp A B;