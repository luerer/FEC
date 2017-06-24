function G = GenerateG(K, N, WindowSize,WindowSelectionProbability, ColTH, TryNum)
%function G = GenerateG(K, N, MinRowTH, ColTH, TryNum)
%
%Decription:
% This function generates the binary matrix for Fountain codes
%
%Input:
% K - number of rows
% N - number of columns
% MinRowTH - lower bound for number of 1's per row
% ColTH - lower bound for number of 1's per col (multiple of K/S)
% TryNum - number of tests to choose from
%
%Output:
% G - a K X N binary matrix
%
%Formed by: Roee Diamant, UBC, July 2012

% if nargin < 4
%     MinRowTH = 7;
% end
if nargin < 5
    ColTH = 1.3; %bound for number of 1's in each column
end
if nargin < 6
    TryNum = 10;
end

TryG = {};
MeanSummerRow = zeros(1, TryNum);
MinSummerRow = zeros(1, TryNum);
WindowNum = length(WindowSelectionProbability);

WindowSelectionCDF = cumsum(WindowSelectionProbability)/sum(WindowSelectionProbability);

c = 0.1;
delta = 0.5;
%-----------------
%create pdf
%         d = [1,2,3,4,5,8,9,19,65,66];%Raptor的度分布
%         mu=[0.0080,0.4936,0.1662, 0.0726, 0.0826,0.0561,0.0372,0.0556,0.0250,0.0031];
%Window function added by Chenhao/Luerer

S = c*log(K/delta)*sqrt(K);

rho = zeros(1, K);
thu = zeros(1, K);
d = 1: K;

rho(1) = 1/K;
rho(2:K) = 1 ./ (d(2:end) .* (d(2:end)-1));

loc = floor(K/S-1);
thu(1: loc) = S/K ./ d(1: loc);
thu(loc+1) = S/K*log(S/delta);

Z = sum(rho + thu);
mu = (rho + thu) / Z;
%-----------------
%threshold for maximum number of ones per column
MaxColTH = K/S * ColTH;

for TryInd = 1: TryNum
    while(1)
        G = zeros(K, N);
        
        for n = 1: N
            while(1)
                %-----------------
                %Window function added by Chenhao/Luerer
                WindowSelectionRand = rand(1,1);
                [useless,WindowNo] = max((WindowSelectionCDF-WindowSelectionRand)>0);
                %draw a number
                Cmu = cumsum(mu)/sum(mu);
                u = rand(1,1);
                [useless,loc] = max((Cmu-u)>0);
                Num = d(loc);
                %-----------------
                if Num <= MaxColTH
                    break;
                end
            end
            %Window function added by Chenhao/Luerer
            row = randperm(WindowSize(WindowNo));%将1到Ki打乱顺序排列
            %row = randperm(K);
            G(row(1: Num), n) = 1;
        end
        
        if WindowNum == 1
            SummerRow = sum(G, 2);
        else
            SummerRow = sum(G(1:WindowSize(1),:), 2);
        end
        if min(SummerRow) > 0  %一个矩阵中行里的1不能有特别少的，少的就不要了%行为0代表某个元素没有参与编码
            MeanSummerRow(TryInd) = mean(SummerRow);%一个矩阵中平均有1的个数
            MinSummerRow(TryInd) = min(SummerRow);
            TryG{TryInd} = sparse(G); %#ok<AGROW>
            break;
        end
    end
end
%maximize weight per row and minimize weight per col
[V, loc] = max(MeanSummerRow);%选择含有1最多的那个矩阵
G = TryG{loc};
G = full(G);