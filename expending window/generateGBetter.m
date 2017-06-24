function G = generateGBetter(k,n,epsilon,WindowSize, WindowSelectionProbability)
%   产生LT Codes的生成矩阵
% k 生成矩阵的列数,同时也是预编码后数据的长度
% n LT Codes 编码后长度
% epsilon 参数
    G=zeros(k,n);
    D=4*(1+epsilon)/epsilon;
    D=round(D);
    u=epsilon/2+(epsilon/2)^2;

    %omega(i) 为度为i的概率
    omega=zeros(1,round(D)+1);
    j=2:D;
    omega(1)=u/(u+1);
    omega(2:D)=(1./j./(j-1))/(u+1);
    omega(D+1)=1/(u+1)/D;
    sum((1:D+1).*omega);   %平均度
    cumulativeOmega=cumsum(omega);%cumulativeOmega(i)为d<=i的累计概率密度
    WindowSelectionCDF = cumsum(WindowSelectionProbability)/sum(WindowSelectionProbability);
    for i=1:n
        WindowSelectionRand = rand(1,1);
        [useless,WindowNo] = max((WindowSelectionCDF-WindowSelectionRand)>0);
        %row=randperm(k);
        row=randperm(WindowSize(WindowNo));                                                        
%算法的基本思想：为了得到随机变量d,首先得到(0到1)的随即变量r,然后找到cumulative(x-1)<=r<cumulative(x),则d=x
%为了加速运算，找到cumulative-r中第一个大于0的下标，即为度
        uniformRandomVariable=repmat(rand(1,1),1,D+1);
        [useless,d]=max((cumulativeOmega-uniformRandomVariable)>0);   %d为随机得到的度
        assert(max(d)<=k,'随机得到的度大于输入符号数,请检查参数epsilon和输入符号的个数');
        %Add by Hao Chen
        d = min(d,WindowSize(WindowNo));
        G(row(1:d),i)=1;
    end
end

