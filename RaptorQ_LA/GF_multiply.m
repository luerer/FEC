function result = GF_multiply(A,B)
[R1 C1] = size(A);
[R2 C2] = size(B);
if(C1~=R2)
	error('martix do not match in GF_multiply');
end;

result = zeros(R1,C2);

for ii = 1:R1
	for jj = 1:C2
		result(ii,jj) = GF_multiply_vector(A(ii,:),B(:,jj));
	end
end
