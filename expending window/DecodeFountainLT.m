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
        if(isempty(pos)) %�п�������һ��forѭ���У�loc(i)�Ѿ��������ˡ�
            continue; %�����ж�Ҳ���ԣ��������Կ�index�������Ӱ�죬���˷�ʱ��
        end
        loc2 = find(GTag(pos, :) == 1);
        GTag(pos, :) = 0;
        Summer(pos) = 1;
        Decoded(pos) = Code(loc(ind));
        Code(loc2) = mod(Code(loc2)-Decoded(pos), 2^(Base)); 
    end
    if sum(Summer) == K %���ڲ���Ҫ��������K�ˣ�Ҳ���Ǿ���ʽһ���̶����ȵģ�ȫ���������У�δ������Ľ���LDPC
        break;          %����Ѿ������K�����У��Ͳ���Ҫ�ٽ�����
    end
end
