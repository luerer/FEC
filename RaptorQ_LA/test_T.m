clear all
close all
clc

K = 1024;
N = 900;
T = 256;

layer=2;


%Number of source symbols
filename = 'bible_tmp.txt';
K_new = K*T;
fid = fopen(filename,'r');
sourceSymbols = [];
while(1)
    myline = fgets(fid);
    inputSyms = double(myline);
    sourceSymbols =[sourceSymbols inputSyms];
    if length(sourceSymbols)>=K_new
        break;
    end
end
sourceSymbols = sourceSymbols(1:K_new);
fclose(fid);
%-------enhance and base in the source symbols--------------
%---------base,enh1,enh2,enh3------------
lay_num = [512,512];

gen_parameters(layer,lay_num);
load parameters.mat;





%source symbols in different layers
Syminlayer = cell(1,layer);
for ii = 1:layer
    temp = [0 lay_num];
    Syminlayer{ii} = sourceSymbols(sum(temp(1:ii))+1:sum(temp(1:ii+1)));
end

char(sourceSymbols)
% for ii =1:layer
%     char(Syminlayer{ii})
% end
%--------------------------------encoding----------------------------------
tic

ExtendedSymbols = cell(1,layer);
for ii = 1:layer
    ExtendedSymbols{ii} = [Syminlayer{ii} zeros(1,prime_N(ii,1)-lay_num(ii))];
end
% for ii =1:layer
%     char(ExtendedSymbols{ii})
% end
if layer == 1
    A_LA = rfc6330_A(prime_N(1,1),ISIs{1});
elseif layer > 1
    A_LA = A_LA_encode(layer);
end
[InterSym] = A_LA_inversion(layer,A_LA,ExtendedSymbols);

EncSymbols = cell(1,layer);
for ii = 1:layer
    Inter_temp = [];
    for jj = 1:ii
        Inter_temp = [Inter_temp InterSym{jj}];
    end
    EncSymbols{ii} = A_LA_gen_encodesymbol(ii,Inter_temp);
end


encodetime = toc

for ii = 1:layer
    char(EncSymbols{ii})
end
%_____________________________________________________________________

%_________________________________A_LA_3  ,for test____________________________________
% % InterSym_B = InterSym{1};InterSym_E1 = InterSym{2};InterSym_E2 = InterSym{3};
% [InterSym_B InterSym_E1 InterSym_E2] = rfc6330_A_LA3_inversion(A_LA,sourceSymbols,K,B,E1,E2);
% EncSym_B = rfc6330_gen_encoding_symbol(prime_N(1,1),InterSym_B,0:prime_N(1,2)-1);%1
% EncSym_B_temp = rfc6330_gen_encoding_symbol(prime_N(1,1),InterSym_B,prime_N(1,1):prime_N(1,1)+prime_N(2,2)-1);
% EncSym_E1_temp = rfc6330_gen_encoding_symbol(prime_N(2,1),InterSym_E1,0:prime_N(2,2)-1);
% if length(EncSym_B_temp)~=length(EncSym_E1_temp)
% 	error('Encoded Symbols do not match');
% end
% EncSym_BE1 = zeros(1,length(EncSym_B_temp));
% for ii = 1:length(EncSym_B_temp)
% 	EncSym_BE1(ii)=bitxor(EncSym_B_temp(ii),EncSym_E1_temp(ii));%2
% end 
% EncSym_B_temp = rfc6330_gen_encoding_symbol(prime_N(1,1),InterSym_B,prime_N(1,1)+prime_N(2,1):prime_N(1,1)+prime_N(2,1)+prime_N(3,2)-1);
% EncSym_E1_temp = rfc6330_gen_encoding_symbol(prime_N(2,1),InterSym_E1,prime_N(2,1):prime_N(2,1)+prime_N(3,2)-1);
% EncSym_E2 = rfc6330_gen_encoding_symbol(prime_N(3,1),InterSym_E2,0:prime_N(3,2)-1);
% if length(EncSym_B_temp)~=length(EncSym_E2)
% 	error('Encoded Symbols do not match');
% end
% EncSym_BE1E2 = zeros(1,length(EncSym_B_temp));
% for ii = 1:length(EncSym_B_temp)
% 	EncSym_BE1E2(ii)=bitxor(bitxor(EncSym_B_temp(ii),EncSym_E1_temp(ii)),EncSym_E2(ii));%3
% end 
% toc
% char(EncSym_B)
% char(EncSym_BE1)
% char(EncSym_BE1E2)
%----------------------------------------------------------------------------------------

SentSymbols = cell(1,layer);
EncSourceSym = cell(1,layer);
EncRepairSym = cell(1,layer);

for ii = 1:layer
    temp = EncSymbols{ii};
    EncSourceSym{ii} = temp(1:lay_num(ii));
    EncRepairSym{ii} = temp(prime_N(ii,1)+1:end);
    SentSymbols{ii} = [EncSourceSym{ii} EncRepairSym{ii}];
end
%_________________erase channel_________________________
errProb = 0.45;
RecESIs = cell(1,layer);
for ii = 1:layer
    RecESIs{ii} = [];
    for ind = 0:(length(SentSymbols{ii})-1)
        if (rand > errProb)
            RecESIs{ii} = [RecESIs{ii} ind];
        end
    end
    if (length(RecESIs{ii}) < lay_num(ii))
        disp('Insufficient number of collected symbols.Decoding will fail!!')
    end
end
%_______________________________________________________

%----------------------------decoding----------------------------------------
tic
RecISIs = cell(1,layer);
indSource = cell(1,layer);
indRepair = cell(1,layer);
for ii = 1:layer
    temp = RecESIs{ii};
    indSource{ii} = temp(find(temp < lay_num(ii)));
    indRepair{ii} = temp(find(temp >= lay_num(ii)));
    if (~isempty(indRepair{ii}))
        indRepair{ii} = indRepair{ii} + prime_N(ii,1) - lay_num(ii);
    end
    indPadding = lay_num(ii):(prime_N(ii,1)-1);
    RecISIs{ii} = [indSource{ii} indPadding indRepair{ii}];
end
RecSymbols = cell(1,layer);
for ii = 1:layer
    temp = SentSymbols{ii};
    temp_out = temp(indSource{ii}+1);
    temp_out = [temp_out zeros(1,prime_N(ii,1)-lay_num(ii))];
    temp_out = [temp_out temp(indRepair{ii} - prime_N(ii,1) + lay_num(ii) + 1)];
    RecSymbols{ii} = temp_out;
end

RecInterSym = A_LA_Rec(RecSymbols,RecISIs);

DecSymbols = cell(1,layer);
for ii = 1:layer
    RecInter_temp = [];
    for jj = 1:ii
        RecInter_temp = [RecInter_temp RecInterSym{jj}];
    end
    DecSymbols{ii} = A_LA_gen_decodesymbol(ii,RecInter_temp);
end
decodetime = toc
for ii = 1:layer
    char(DecSymbols{ii})
end






