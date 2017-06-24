function A_LA = A_LA_encode(layer)
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
rr = sum(para_v(:,5));
A_LA = zeros(rr,rr);
for ii = 1:layer
	temp = [0 para_v(:,5)'];
	row_temp = sum(temp(1:ii))+1:sum(temp(1:ii+1));
	A_LA(row_temp,row_temp) = rfc6330_A(prime_N(ii,1));
end
ISIs_B = cell(layer,layer);
for ii = 2:layer
	for jj = 1:ii-1
		temp = prime_N(:,1)';
		ISIs_B{ii,jj} = ISIs{ii}+sum(temp(jj:ii-1));
	end
end
%-----------generate B------------
%B = cell(layer,layer);
for ii = 2:layer
	for jj = 1:ii-1
		row_t = (sum(para_v(1:ii-1,5))+1):sum(para_v(1:ii,5));
		temp = [0 para_v(:,5)'];
		column_t = (sum(temp(1:jj))+1):sum(temp(1:jj+1));
		ISIs_t = ISIs_B{ii,jj};
		A = zeros(length(row_t),length(column_t));
		G_temp = gen_G(prime_N(jj,1),ISIs_t);
		A(sum(para_v(ii,1:2))+1:end,:) = G_temp;
%		SH = sum(para_v(ii,1:2));
% 		S = para_v(jj,1);
% 		H = para_v(jj,2);
% 		W = para_v(jj,6);
% 		P = para_v(jj,7);
% 		P1 = para_v(jj,8);
% 		for iii = 1:length(ISIs_t)
% 		    % obtain (d,a,b) triple for given ISI
%  		   [ d, a, b, d1, a1, b1 ] = rfc6330_tuple( prime_N(jj,1), ISIs_t(ii) );
%   		   A(iii+S+H,1+b) = 1;
%  		   for jjj = 1:(d-1)
%  		       b = mod(b+a,W);
%  		       A(iii+S+H,1+b) = bitxor(A(iii+S+H,1+b),1);
% 		    end
%  		   while (b1>=P)
% 		        b1 = mod(b1+a1,P1);
% 		    end
%   		   A(iii+S+H,1+b1+W) = bitxor(A(iii+S+H,1+b1+W),1);
%  		   for jjj = 1:(d1-1)
%  		       b1 = mod(b1+a1,P1);
%    		     while (b1>=P)
%   		          b1 = mod(b1+a1,P1);
%   		      end
%    		     A(iii+S+H,1+b1+W) = bitxor(A(iii+S+H,1+b1+W),1);
%  		   end
% 		end
		A_LA(row_t,column_t) = A;
	end
end

%for ii = 2:layer 
%	for jj = 1:ii-1
%		row_t = sum(para_v(1:ii-1,5))+1:sum(para_v(1:ii,5));
%		temp = [0 para_v(:,5)'];
%		column_t = sum(temp(1:jj))+1:sum(temp(1:jj+1));
%		A_LA(row_t,column_t) = B{ii,jj};
%	end
%end
%-----------------------------------------------------
%for iii = 1:length(ISIs)
%    		% obtain (d,a,b) triple for given ISI
%    		[ d, a, b, d1, a1, b1 ] = rfc6330_tuple( prime_N(jj,1), ISIs(ii) );
% 		    B_temp(iii+SH,1+b) = 1;
%   		 for jjj = 1:(d-1)
%  		      b = mod(b+a,para_v(jj,6));
%  		      B_temp(iii+SH,1+b) = bitxor(B_temp(iii+SH,1+b),1);
% 		   end
%		    while (b1>=para_v(jj,7))
% 		       b1 = mod(b1+a1,para_v(jj,8));
% 		   end
% 		   B_temp(iii+SH,1+b1+para_v(jj,6)) = bitxor(B_temp(iii+SH,1+b1+para_v(jj,6)),1);
% 		   for jjj = 1:(d1-1)
% 		       b1 = mod(b1+a1,para_v(jj,8));
% 		       while (b1>=para_v(jj,7))
%		           b1 = mod(b1+a1,para_v(jj,8));
% 		       end
% 		       B_temp(iii+SH,1+b1+para_v(jj,6)) = bitxor(B_temp(ii+S+H,1+b1+para_v(jj,6)),1);
% 		   end
%		end