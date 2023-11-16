clear all
close all
clc

%Código para projetar um controlador PID (dois zeros e dois polos) com o LR
%Controle PID pelo  LR  --> C = Kc(1 + 1/Tis + sTd/(1+ alpha*sTd)) 
%contem projeto do filtro, Bodes, DPZs.

%% Parametros da planta
Ke =   34.57;     %ganho estatico da planta
tau =  1732;    %constante de tempo da equação linearizada perto do ponto de equilibrio

%% Especificacoes MF
t_5  = tau/4;   %tempo de 5%
pico = 0.01;  %sobressinal 10% sempre em valor ABSOLUTO

syms zeta wn

%fator de amortecimento (zeta)
fa= vpa(solve((pico ==  exp((-pi*zeta)/(sqrt(1 - zeta^2)))))); 
fa = fa(1,:); 

%frequencia natural (wn)
%wn = vpa(solve(t_5 == (3/(fa*wn))));    %para 0 < Xi <= 0.7 
wn = vpa(solve(t_5 == (4.8/(fa*wn)))); %para 0.8 <= Xi <= 1
%wn = vpa(solve(t_5 == 1.5*tau_rapido + 3*tau_lento)); %para 0.8 > Xi > 1

%ponto desejado
sd_imPositivo =  -fa*wn  + 1i*wn*sqrt(1-fa^2);  %parte real positiva
sd_imNegativo = -fa*wn - 1i*wn*sqrt(1-fa^2);   %parte real negativa

%% Calculando contribuicoes dos polos e zeros do den da FT de malha fechada

sd   = -fa*wn + 1i*wn*sqrt(1-fa^2); 
polo = 1/tau; %polo planta

%fase1 = 180 - rad2deg(double(atan( abs(imag(sd))/(-1*real(sd) - zero))));
fase2 = 180 - rad2deg(double(atan( abs(imag(sd))/(-1*real(sd)))));
fase3 = 180 - rad2deg(double(atan( abs(imag(sd))/(-1*real(sd) - polo))));

faseConhecida = - (fase2 + fase3);

%faseTotal = 0; %se  K<0
faseTotal = -180; %se K>0

syms faseDesconhecida
faseDesconhecida = vpa(solve(faseTotal == faseConhecida + faseDesconhecida));

 %                                                                                       __                                      ___                                          
 %Queremos um controlador PID do tipo: C(s) =   Kc  |  1 +  1    +        sTd                |
  %                                                                                     |         ----      --------------------     | 
  %                                                                                     |_         sTi   (1+ alpha*sTd)__|
 %                                                                                      __                                       ___                                          
 %                                                                          =   Kc  |          (s + z1) (s + z2)            |
  %                                                                                     |       ----------------------------       | 
  %                                                                                     |_          s (s + paf)            ___|
  
  
%Onde paf é um polo de alta frequencia que serve apenas para tornar a FT do controlador realizável

%calculando paf
paf = double(abs(sd)*10);

%calculando a fase do paf
fase_paf = rad2deg(double(atan( abs(imag(sd))/(paf + real(sd))))); 

%recalculando a fase total desonhecida:
faseDesconhecidaNova = fase_paf + faseDesconhecida;

%zeros SEMPRE a esquerda da localizacao do sd para nao afetar a dominancia
%com essa nova fase desconhecida, calculamos a localizacao dos zeros tq
%eles contribuam com a  fase 2*x --> ou  seja --> cada zero contribui com x

% Calculando a localizacao do zero do controlador:
zero = double( -1*real(sd) +  (imag(sd))/tan(deg2rad(double( (faseDesconhecidaNova/2)))));

%Prova real
fasePROVAreal = (rad2deg(double(atan( abs(imag(sd))/(zero + real(sd))))))*2; %multiplica por 2 pq sao dois zeros


%% Calculando K
syms K  
s = sd_imPositivo;
num = K*( (s + double(zero))^2)*(Ke/1732); %dividi o ganho da planta por conta da forma monica do polinomio
den = s*(s+ double(polo))*(s+paf);
s = sd_imPositivo;
Kc_pos = double(vpa(solve(((1 + ((num/den)) == 0)))));
s = sd_imNegativo;
Kc_neg = double(vpa(solve(((1 + ((num/den)) == 0)))));

Kc = real(Kc_pos);

%% Funcoes de transferencia contínuas 

s = tf('s'); % variavel de Laplace

%FT da planta P(s) sem perturbação
P = Ke/(1+s*tau);
[num_P,den_P] = tfdata(P);

%FT do controlador PID
C = Kc*( (s +zero)^2)/(s*(s +paf));
[num_C,den_C] = tfdata(C);

%% FT de MF sem Filtro

%funcao de transferencia de malha fechada de Y/R
Hr =  minreal((C*P)/(1 + (C*P)));
[num_Hr, den_Hr] = tfdata(Hr);

%funcao de transferencia de malha fechada de Y/Q
Hq =  minreal((P)/(1 + (C*P)));
[num_Hq,den_Hq] = tfdata(Hq);

%funcao de transferencia de malha fechada de U/R
Hur =  minreal((C)/(1 + (C*P)));
[num_Hur,den_Hur] = tfdata(Hur);

%funcao de transferencia de malha fechada de U/Q
Huq =  minreal((-C)/(1 + (C*P)));
[num_Huq,den_Huq] = tfdata(Huq);


%% Desenhando o LR

%sem filtro
rlocus(C*P)

%% Respostas das FT MF sem o Filtro

figure
step(Hr)  %resposta ao degrau do sistema em MF
title('Resposta ao degrau em relacao ao seguimento de referencias')
figure
step(Hq) %resposta ao degrau do sistema em MF em relacao a pert
title('Resposta ao degrau em relacao a rejeicao à perturbacao')

figure
pzmap(Hr)   %DPZ da FT de MF da saida em relacao a referencia
title('DPZ da FT de MF Y/R')
figure
pzmap(Hq) %DPZ da FT de MF da saida em relacao a perturbacao
title('DPZ da FT de MF Y/Q')
figure
pzmap(Hur) %DPZ da FT de MF da entrada de controle em relacao a referencia
title('DPZ da FT de MF U/R')
figure
pzmap(Huq) %DPZ da FT de MF da entrada de controle em relacao a perturbacao
title('DPZ da FT de MF U/Q')

%compara a resposta em frequencia das FTs de MF sem o filtro
figure
h = bodeoptions;
h.PhaseMatching = 'on';
bodeplot(Hr,'-b', Hq ,'-.g', Hur, 'r', Huq,':k',{0.1 10},h)
legend('Y/R','Y/Q','U/R', 'U/Q', 'Location','SouthWest')

%% Projeto do Filtro 

%FT do filtro de referência
F = 1/(1+(1/zeros)*s)^2; %zeros são os zeros duplos que estão "incomodando a resposta"
[num_F,den_F] = tfdata(F);


%funcao de transferencia de malha fechada de Y/R com filtro
FTmfFiltro =  (F*C*P)/(1 + (C*P));
[num_FTmf,den_FTmf] = tfdata(FTmfFiltro);

%filtro nao afeta em nada a resposta a perturbacao!!!!!!!

%% FT de MF com Filtro 

%funcao de transferencia de malha fechada de Y/R
Hrf =  minreal((P*C*F)/(1 + (C*P)));
[num_Hrf, den_Hrf] = tfdata(Hrf);

%funcao de transferencia de malha fechada de U/R
Hurf =  minreal((C*F)/(1 + (C*P)));
[num_Hurf,den_Hurf] = tfdata(Hurf);

figure
pzmap(Hrf)   %DPZ da FT de MF da saida em relacao a referencia com filtro
title('DPZ da FT de MF Y/R com filtro')

figure
pzmap(Hurf) %DPZ da FT de MF da entrada de controle em relacao a referencia com filtro
title('DPZ da FT de MF U/R com filtro')

%compara a resposta em frequencia das FTs de MF com o filtro
figure
h = bodeoptions;
h.PhaseMatching = 'on';
bodeplot(Hr,'-b',  Hur, 'r',{0.1 10},h)
legend('Y/R','U/R', 'Location','SouthWest')
