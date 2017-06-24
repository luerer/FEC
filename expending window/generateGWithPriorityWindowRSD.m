function G = generateGWithPriorityWindowRSD(k,n,c,delta,numberOfPriorityBits,probablityForPriorityWindow)
%   ����LT Codes�����ɾ���
% k : ���ɾ��������,ͬʱҲ��Ԥ��������ݵĳ���
% n : LT Codes ����󳤶�
% epsilon : LT����Ĳ���
% numberOfPriorityBits : ��Ҫ�ı�����
% probablityForPriorityWindow : ѡ����Ҫ���ش��ĸ���
% ǰnumberOfPriorityBits
% ��Ϊ��Ҫ����ȫ��������Ϊ��һ��������probablityForPriorityWindow����ѡ����Ҫ�����������ѡ��ȫ�������ٸ��ݶȷֲ�ѡ�ж�
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
    cumulativeOmegaForPriorityWindow=cumsum(mu);%cumulativeOmega(i)Ϊd<=i���ۼƸ����ܶ�
    
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
    cumulativeOmegaForAllWindow=cumsum(mu);%cumulativeOmega(i)Ϊd<=i���ۼƸ����ܶ�
    
    for i=1:n
        if(rand(1,1)<probablityForPriorityWindow)
            row=randperm(numberOfPriorityBits);
                                                                %�㷨�Ļ���˼�룺Ϊ�˵õ��������d,���ȵõ�(0��1)���漴����r,Ȼ���ҵ�cumulative(x-1)<=r<cumulative(x),��d=x
                                                                %Ϊ�˼������㣬�ҵ�cumulative-r�е�һ������0���±꣬��Ϊ��
            uniformRandomVariable=repmat(rand(1,1),1,numberOfPriorityBits);
            [useless,d]=max((cumulativeOmegaForPriorityWindow-uniformRandomVariable)>0);   %dΪ����õ��Ķ�
            G(row(1:d),i)=1;
        else
            row=randperm(k);
                                                                %�㷨�Ļ���˼�룺Ϊ�˵õ��������d,���ȵõ�(0��1)���漴����r,Ȼ���ҵ�cumulative(x-1)<=r<cumulative(x),��d=x
                                                                %Ϊ�˼������㣬�ҵ�cumulative-r�е�һ������0���±꣬��Ϊ��
            uniformRandomVariable=repmat(rand(1,1),1,k);
            [useless,d]=max((cumulativeOmegaForAllWindow-uniformRandomVariable)>0);   %dΪ����õ��Ķ�
            G(row(1:d),i)=1;
        end
         
    end
end