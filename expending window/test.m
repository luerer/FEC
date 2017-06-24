clc
clear
%***************************PacketLossRate***************************%
LossRate=0:0.1:0.5;
err=zeros(3,length(LossRate));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LDPCRate = [9/10 8/9 5/6 4/5 3/4 2/3 3/5 1/2];
N = 64800;
MaxN = 8192;
Base = 2; %base for codeword
Epsilon = 0.1:0.1:1.2;%0.05:0.01:0.8;
LTFrame = 4;
LTSingleInputN = N/LTFrame; %LT input number of symbols per layer
%LT Fountain matrix with priority window
WindowSize = [LTSingleInputN, LTSingleInputN + LTSingleInputN];
FirstWinSelectProb = 0:0.1:0.5;
% Number of iteration;
iter = 100;

for RateInd = 1:length(LDPCRate)
    M = N * LDPCRate(RateInd);
    L = N * LDPCRate(RateInd);
    H = dvbs2ldpc(LDPCRate(RateInd));
    hEnc = comm.LDPCEncoder(H);
    hDec = comm.LDPCDecoder(H);
    
    for EpsilonInd=1:length(Epsilon) %redundant symbols after erasur
        LTEncodedN= ceil((M+L)/LTFrame*(1+Epsilon(EpsilonInd)));
        for WinSelectProbInd=1:length(FirstWinSelectProb) %window selection probability allocation
            WinSelectProb = [FirstWinSelectProb(WinSelectProbInd), 1-FirstWinSelectProb(WinSelectProbInd)];
            GLTfilename = strcat('G_LT_',num2str(WindowSize(end)),'x',num2str(LTEncodedN),'_Winp',...
                num2str(WinSelectProb(1)),'_',num2str(WinSelectProb(2)),'.mat');
            if(exist(GLTfilename,'file'))
                load(GLTfilename,'G_LT','-mat');
            else
                tic
                %             G_LT = GenerateG(WindowSize(end), LTEncodedN, WindowSize, WinSelectProb);
                %             G_LT = generateGWithPriorityWindowRSD(WindowSize(end),LTEncodedN,0.1,0.5,WindowSize(1),WinSelectProb(1));
                G_LT = generateGBetter(WindowSize(end), LTEncodedN, 0.03,WindowSize, WinSelectProb);
                fprintf('LT G matrix using time:');
                toc
                save(GLTfilename,'G_LT','-v7.3');
            end
            for LossRateInd=1:length(LossRate);
                Window1Error=0;
                Window2Error=0;
                AvgWinError=0;
                for count = 1:iter
                    BaseBitsVec = randi(Base, M, 1) - 1;
                    EnhanceBitsVec = randi(Base, L, 1) - 1;
                    %LDPC encode
                    BaseBitsLDPC = step(hEnc, BaseBitsVec);
                    EnhanceBitsLDPC = step(hEnc, EnhanceBitsVec);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    for i = 1:LTFrame
                        %LT encode
                        G_LT_use = G_LT;
                        LTInputSymbol = [BaseBitsLDPC((i-1)*LTSingleInputN+1:i*LTSingleInputN);EnhanceBitsLDPC((i-1)*LTSingleInputN+1:i*LTSingleInputN)];
                        LTCodedSymbol = EncodeFountain(G_LT_use, LTInputSymbol', Base);
                        %get expected error
                        %                       CurrentSNR = 3; %SNR in dB
                        %                       PeBit = 1/2 * erfc(sqrt(10.^(CurrentSNR./10))); %??
                        %                       PeSymbol = PeBit * (2^Base-1)/(2^(Base-1)); %??
                        
                        %place erasures
                        ErasureVec = zeros(1, LTEncodedN);  %??
                        for ind = 1: LTEncodedN
                            Temp = rand(1,1);
                            %                          if Temp < PeSymbol(CurrentSNR)
                            if Temp < LossRate(LossRateInd)
                                %no need to change the symbol value. If there is erasure, algo will
                                %disregard the value
                                ErasureVec(ind) = 1;
                            end
                        end
                        
                        LTReceivedSymbol = LTCodedSymbol;
                        G_LT_use(:, ErasureVec==1) = [];
                        LTReceivedSymbol(ErasureVec==1) = [];
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%decode%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %LT decode
                        DecBits = DecodeFountainLT(G_LT_use, LTReceivedSymbol, ErasureVec, log2(Base));
                        %minus ones are non-decoded symbols (for erasures of next degree, i.e., raptor code)
                        loc = find(DecBits<0);
                        DecBits(loc) = 5;%unsure bits set 5 for LDPC decode
                        %Reording
                        BaseLTDecodedResult((i-1)*LTSingleInputN+1:i*LTSingleInputN) = DecBits(1:LTSingleInputN);
                        EnhanceLTDecodedResult((i-1)*LTSingleInputN+1:i*LTSingleInputN) = DecBits(LTSingleInputN+1:end);
                    end
                    LTDecodedResult = [BaseLTDecodedResult EnhanceLTDecodedResult];
                    %LDPC decode
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    llrData = zeros(N + N,1);
                    llrData((LTDecodedResult == 1)) = -1000;
                    llrData((LTDecodedResult == 0)) = 1000;
                    llrData((LTDecodedResult == 5)) = 0;
                    vhat1 = step(hDec, llrData(1:N));
                    vhat2 = step(hDec, llrData(N+1:end));
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Window1Error=Window1Error+length(find(bitxor(vhat1, BaseBitsVec)));
                    %Window1Error=Window1Error+length(find(vhat1~=BaseBitsVec));
                    Window2Error=Window2Error+length(find(bitxor(vhat2, EnhanceBitsVec)));
                    %Window2Error=Window2Error+length(find(DecBits(N+1:N+L)~=EnhanceBitsVec'));
                    AvgWinError=Window1Error + Window2Error;
                    disp(count);
                end
                err(1,LossRateInd)=Window1Error/(M*iter);
                err(2,LossRateInd)=Window2Error/(L*iter);
                err(3,LossRateInd)=AvgWinError/((M+L)*iter);
            end
            % semilogy(LossRate,err(1,:),'r:+');hold on;
            % semilogy(LossRate,err(2,:),'g:o');hold on;
            % semilogy(LossRate,err(3,:),'b:+');hold on;
            % hold on;
            % grid on
            % legend('MIB error rate','LIB error rate','average error rate');
            % %xlabel('信噪比(SNR)');ylabel('误码率');title('信噪比与误码率关系');
            % xlabel('PacketLossRate');ylabel('BitErrorRate');title('信噪比与误码率关系');
            errfile = strcat('err_',num2str(LossRate(1)),'~',num2str(LossRate(length(LossRate))),...
                '_K1_',num2str(M),'_N1_',num2str(N),'_K2_',num2str(L),'_N2_',num2str(N),'_LT_Ndiv',...
                num2str(LTFrame),'_',num2str(LTEncodedN),'_Winp',num2str(WinSelectProb(1)),'_',...
                num2str(WinSelectProb(2)));
            ErrFileNameTxt = strcat(errfile,'.txt');
            save(ErrFileNameTxt,'LossRate','err','-ASCII');
            h = figure('visible','off');
            semilogy(LossRate,err(1,:),'r:+');hold on;
            semilogy(LossRate,err(2,:),'g:o');hold on;
            semilogy(LossRate,err(3,:),'b:+');hold on;
            grid on;
            legend('MIB error rate','LIB error rate','average error rate');
            xlabel('PacketLossRate');ylabel('BitErrorRate');title('BER vs. PLR');
            ErrFileNameJpg = strcat(errfile,'.jpg');
            saveas(h,ErrFileNameJpg);
            close(h);
        end
    end
end