function result = GF_multiply_vector(A,B)
if length(A) ~= length(B)
	error('vector do not match in GF_multiply_vector');
end

result_temp = 0;
temp = zeros(1,length(A));
for ii = 1:length(A)
	temp(ii)=rfc6330_gfmult(A(ii),B(ii));
end

for ii = 1:length(A)
	result_temp = bitxor(result_temp,temp(ii));
end

result = result_temp;
