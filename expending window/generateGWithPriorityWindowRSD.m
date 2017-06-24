function G = generateGWithPriorityWindowRSD(k,n,c,delta,numberOfPriorityBits,probablityForPriorityWindow)
%   产生LT Codes的生成矩阵
% k : 生成矩阵的列数,同时也是预编码后数据的长度
% n : LT Codes 编码后长度
% epsilon : LT编码的参数
% numberOfPriorityBits : 重要的比特数
% probablityForPriorityWindow : 选中重要比特窗的概率
% 前numberOfPriorityBits
% 作为重要窗，全部比特作为另一个窗。以probablityForPriorityWindow概率选中重要窗，其余概率选中全部窗，再根据度分布选中度
    G=zeros(k,n);
    kk=numberOfPriorityBits;
    S = c*log(kk/delta)*sqrt(kk);
        
    rho = zeros(1, kk);
    thu = zeros(1, kk);
    d = 1: kk;

    rho(1) = 1/kk;
    rho(2:kk) = 1 ./ (d(2:kk) .* (d(2:kk)-1));

    loc = floor(kk/S-1);
    thu(1: loc) = S/kk ./ d(1: loc);
    thu(loc+1) = S/kk*log(S/delta);

    Z = sum(rho + thu);
    mu = (rho + thu) / Z; 
    cumulativeOmegaForPriorityWindow=cumsum(mu);%cumulativeOmega(i)为d<=i的累计概率密度
    
    kk=k;
    S = c*log(kk/delta)*sqrt(kk);
        
    rho = zeros(1, kk);
    thu = zeros(1, kk);
    d = 1: kk;

    rho(1) = 1/kk;
    rho(2:kk) = 1 ./ (d(2:kk) .* (d(2:kk)-1));

    loc = floor(kk/S-1);
    thu(1: loc) = S/kk ./ d(1: loc);
    thu(loc+1) = S/kk*log(S/delta);

    Z = sum(rho + thu);
    mu = (rho + thu) / Z; 
    cumulativeOmegaForAllWindow=cumsum(mu);%cumulativeOmega(i)为d<=i的累计概率密度
    
    for i=1:n
        if(rand(1,1)<probablityForPriorityWindow)
            row=randperm(numberOfPriorityBits);
                                                                %算法的基本思想：为了得到随机变量d,首先得到(0到1)的随即变量r,然后找到cumulative(x-1)<=r<cumulative(x),则d=x
                                                                %为了加速运算，找到cumulative-r中第一个大于0的下标，即为度
            uniformRandomVariable=repmat(rand(1,1),1,numberOfPriorityBits);
            [useless,d]=max((cumulativeOmegaForPriorityWindow-uniformRandomVariable)>0);   %d为随机得到的度
            G(row(1:d),i)=1;
        else
            row=randperm(k);
                                                                %算法的基本思想：为了得到随机变量d,首先得到(0到1)的随即变量r,然后找到cumulative(x-1)<=r<cumulative(x),则d=x
                                                                %为了加速运算，找到cumulative-r中第一个大于0的下标，即为度
            uniformRandomVariable=repmat(rand(1,1),1,k);
            [useless,d]=max((cumulativeOmegaForAllWindow-uniformRandomVariable)>0);   %d为随机得到的度
            G(row(1:d),i)=1;
        end
         
    end
end