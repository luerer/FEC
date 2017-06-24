function G = generateGBetter(k,n,epsilon,WindowSize, WindowSelectionProbability)
%   ����LT Codes�����ɾ���
% k ���ɾ��������,ͬʱҲ��Ԥ��������ݵĳ���
% n LT Codes ����󳤶�
% epsilon ����
    G=zeros(k,n);
    D=4*(1+epsilon)/epsilon;
    D=round(D);
    u=epsilon/2+(epsilon/2)^2;

    %omega(i) Ϊ��Ϊi�ĸ���
    omega=zeros(1,round(D)+1);
    j=2:D;
    omega(1)=u/(u+1);
    omega(2:D)=(1./j./(j-1))/(u+1);
    omega(D+1)=1/(u+1)/D;
    sum((1:D+1).*omega);   %ƽ����
    cumulativeOmega=cumsum(omega);%cumulativeOmega(i)Ϊd<=i���ۼƸ����ܶ�
    WindowSelectionCDF = cumsum(WindowSelectionProbability)/sum(WindowSelectionProbability);
    for i=1:n
        WindowSelectionRand = rand(1,1);
        [useless,WindowNo] = max((WindowSelectionCDF-WindowSelectionRand)>0);
        %row=randperm(k);
        row=randperm(WindowSize(WindowNo));                                                        
%�㷨�Ļ���˼�룺Ϊ�˵õ��������d,���ȵõ�(0��1)���漴����r,Ȼ���ҵ�cumulative(x-1)<=r<cumulative(x),��d=x
%Ϊ�˼������㣬�ҵ�cumulative-r�е�һ������0���±꣬��Ϊ��
        uniformRandomVariable=repmat(rand(1,1),1,D+1);
        [useless,d]=max((cumulativeOmega-uniformRandomVariable)>0);   %dΪ����õ��Ķ�
        assert(max(d)<=k,'����õ��Ķȴ������������,�������epsilon��������ŵĸ���');
        %Add by Hao Chen
        d = min(d,WindowSize(WindowNo));
        G(row(1:d),i)=1;
    end
end

