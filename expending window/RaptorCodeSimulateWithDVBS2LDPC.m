function errorRate = RaptorCodeSimulateWithDVBS2LDPC(LDPCRate,DecodingCost)
%   The Simulation Of Raptor Codes using LDPC DVBS2 Matrix as precode
%   Author ������


transmittedBitsPerFrame=64800*LDPCRate;
numberOfPrecodedBits=64800;
LTPerFrame=20 ;%ÿ�δ��䱻�ֳ�LTPerFrame��LT�룻
K=numberOfPrecodedBits/LTPerFrame;  
N=transmittedBitsPerFrame/LTPerFrame*DecodingCost;% LT������symbol����
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
precodedBits=encode(LDPCEncoder,source); % LDPC ����
precodedSymbol=precodedBits;
for i=1:LTPerFrame
    G=generateG(K,N,0.03);
    raptorCodedResult=encodeLT(precodedSymbol(:,(i-1)*numberOfPrecodedBits/LTPerFrame+1:i*numberOfPrecodedBits/LTPerFrame),G);
    erase=zeros(1,N);
    LTDecodedSymbol=decodeLT(raptorCodedResult,G,erase);
    LTDecodedBits=reshape(LTDecodedSymbol',1,K);
    LTFails=find(LTDecodedBits<0);
%    [i length(LTFails)/K]
    LTDecodedBits(LTFails)=-1;   %�������ʧ�ܵı���
    LTDecodedResult((i-1)*numberOfPrecodedBits/LTPerFrame+1:i*numberOfPrecodedBits/LTPerFrame)=LTDecodedBits;
end

% LTDecodedResultLLR  (������Ϊllr)Ϊ log-likelihood ratio ,llr(i)=log(p(ci=0)/p(ci=1))
%LTDecodedBits(i)==-1   =>   llr(i)=0
%LTDecodedBits(i)==1 => llr(i)=-inf (����ȡ-1000)
%LTDecodedBits(i)==0 => llr(i)=inf (����ȡ1000)

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
LTDecodedResultLLR=(1000-(LTDecodedResult==1)*2000).*(LTDecodedResult~=-1);%matlab ��for��if then else ����������Ϊ���������ٶȣ�����ʹ�þ������㣬�����һ�µġ�
decodedResult=decode(LDPCDecoder,LTDecodedResultLLR);%LDPC ����
errorRate=length(find(decodedResult-source~=0))/transmittedBitsPerFrame;
end

