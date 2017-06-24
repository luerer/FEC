function result = encodeLT(source,G)
%   LT编码
% source 输入的比特，其中每一列是一个符号，每一个符号作为一个整体进行编码
% G 编码矩阵
% result 输出的比特
result=mod(source*G,2); %注意这是矩阵乘


end

