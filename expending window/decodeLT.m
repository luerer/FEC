function  result  = decodeLT( source,G,erasedSymbol )
    %   LT 解码
    % source 输入的比特，每一列是一个符号
    % G LT 编码矩阵
    % erasedSymbol 错误接受的符号
    N=length(source);
    K=size(G,1);
    result=-ones(1,K);
    succeedDecodedSymbol=zeros(1,N);
    while(1)
        loc=find(sum(G,1)==1);
        if(isempty(loc))
            break;
        end
        for i=1:length(loc)
            searchingCol=loc(i);
            index=find(G(:,searchingCol)==1);
            if(length(index)==0) %有可能在上一次for循环中，loc(i)已经被清零了
                continue;
            end
            linkedIndex=find(G(index,:)==1);
            if(erasedSymbol(searchingCol)==0)
                result(index)=source(searchingCol);
                succeedDecodedSymbol(index)=1;
                G(index,:)=0;
                source(linkedIndex)=mod(source(linkedIndex)+result(index),2);
            else
                G(index,searchingCol)=0;
            end
        end
    end
end

