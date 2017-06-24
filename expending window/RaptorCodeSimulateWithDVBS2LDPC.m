function errorRate = RaptorCodeSimulateWithDVBS2LDPC(LDPCRate,DecodingCost)
%   The Simulation Of Raptor Codes using LDPC DVBS2 Matrix as precode
%   Author 赵章宗


transmittedBitsPerFrame=64800*LDPCRate;
numberOfPrecodedBits=64800;
LTPerFrame=20 ;%每次传输被分成LTPerFrame次LT码；
K=numberOfPrecodedBits/LTPerFrame;  
N=transmittedBitsPerFrame/LTPerFrame*DecodingCost;% LT编码后的symbol个数
N=round(N);
bitsPerSymbol=1;
source=round(rand(transmittedBitsPerFrame,1))';
H = dvbs2ldpc(LDPCRate);
LDPCEncoder = fec.ldpcenc(H);
LDPCDecoder = fec.ldpcdec(H);
LDPCDecoder.DecisionType = 'Hard decision';     % Set decision type
LDPCDecoder.OutputFormat = 'Information part';  % Set output format
LDPCDecoder.NumIterations = 50;                 % Set number of iterations
LDPCDecoder.DoParityChecks = 'Yes';  % Stop if all parity-checks are satisfied
precodedBits=encode(LDPCEncoder,source); % LDPC 编码
precodedSymbol=precodedBits;
for i=1:LTPerFrame
    G=generateG(K,N,0.03);
    raptorCodedResult=encodeLT(precodedSymbol(:,(i-1)*numberOfPrecodedBits/LTPerFrame+1:i*numberOfPrecodedBits/LTPerFrame),G);
    erase=zeros(1,N);
    LTDecodedSymbol=decodeLT(raptorCodedResult,G,erase);
    LTDecodedBits=reshape(LTDecodedSymbol',1,K);
    LTFails=find(LTDecodedBits<0);
%    [i length(LTFails)/K]
    LTDecodedBits(LTFails)=-1;   %标记译码失败的比特
    LTDecodedResult((i-1)*numberOfPrecodedBits/LTPerFrame+1:i*numberOfPrecodedBits/LTPerFrame)=LTDecodedBits;
end

% LTDecodedResultLLR  (下面简称为llr)为 log-likelihood ratio ,llr(i)=log(p(ci=0)/p(ci=1))
%LTDecodedBits(i)==-1   =>   llr(i)=0
%LTDecodedBits(i)==1 => llr(i)=-inf (这里取-1000)
%LTDecodedBits(i)==0 => llr(i)=inf (这里取1000)

%LTDecodedResultLLR=zeros(1,numberOfPrecodedBits);
% for i=1:numberOfPrecodedBits
%      if(LTDecodedResult(i)==1)
%             LTDecodedResultLLR(i)=-1000;
%      else if(LTDecodedResult(i)==0)
%             LTDecodedResultLLR(i)=1000;
%          else  LTDecodedResultLLR(i)=0;
%          end
%      end
% end
LTDecodedResultLLR=(1000-(LTDecodedResult==1)*2000).*(LTDecodedResult~=-1);%matlab 的for、if then else 操作很慢，为提升运算速度，这里使用矩阵运算，结果是一致的。
decodedResult=decode(LDPCDecoder,LTDecodedResultLLR);%LDPC 解码
errorRate=length(find(decodedResult-source~=0))/transmittedBitsPerFrame;
end

