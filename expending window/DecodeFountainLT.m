function Decoded = DecodeFountainLT(G, Code, ErasureVec, Base)
%function Decoded = DecodeFountainLT(G, Code, ErasureVec, Base)
%
%Decription:
% This function decodes Fountain LT code
%
%Input:
% G - binary matrix (K X N)
% Code - code word to decode (vector size of N)
% ErasureVec - binary erasures (erasure = '1').  Vector size of N
% Base - base of codeword
%
%Output:
% Decoded - vector of K decoded symbols (-1 indicates unseccesfull decoding)
% 
%Formed by: Roee Diamant, UBC, July 2012

K = size(G, 1);
N = length(Code);
GTag = G;
Decoded = -ones(1, K);
Summer = zeros(1, K);
while(1)
    loc = find(sum(GTag,1) == 1);
    if isempty(loc)
        %code fails
        break;
    end
    for ind = 1: length(loc)
        pos = find(GTag(:, loc(ind)) == 1);
        if(isempty(pos)) %有可能在上一次for循环中，loc(i)已经被清零了。
            continue; %不用判断也可以，下面程序对空index不会产生影响，但浪费时间
        end
        loc2 = find(GTag(pos, :) == 1);
        GTag(pos, :) = 0;
        Summer(pos) = 1;
        Decoded(pos) = Code(loc(ind));
        Code(loc2) = mod(Code(loc2)-Decoded(pos), 2^(Base)); 
    end
    if sum(Summer) == K %现在不需要让它等于K了，也就是矩阵式一个固定长度的，全部译码后就行，未译码出的交给LDPC
        break;          %如果已经解码出K个序列，就不需要再进行了
    end
end
