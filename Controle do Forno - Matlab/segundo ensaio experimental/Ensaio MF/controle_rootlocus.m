clear all
close all
clc

%Código para projetar um controlador PID (dois zeros e dois polos) com o LR
%Controle PID pelo  LR  --> C = Kc(1 + 1/Tis + sTd/(1+ alpha*sTd)) 
%contem projeto do filtro, Bodes, DPZs.

%% Parametros da planta
Ke =   0.9729;     %ganho estatico da planta
tau =  5.2110e+03;    %constante de tempo da equação linearizada perto do ponto de equilibrio

%% Especificacoes MF
t_5  = tau/3;   %tempo de 5%
pico = 0.10;  %sobressinal 20% sempre em valor ABSOLUTO

syms zeta wn

%fator de amortecimento (zeta)
fa= vpa(solve((pico ==  exp((-pi*zeta)/(sqrt(1 - zeta^2)))))); 
fa = fa(1,:); 

%frequencia natural (wn)
wn = vpa(solve(t_5 == (3/(fa*wn))));    %para 0 < Xi <= 0.7 

%ponto desejado
sd_imPositivo =  -fa*wn  + 1i*wn*sqrt(1-fa^2);  %parte real positiva
sd_imNegativo =  -fa*wn  - 1i*wn*sqrt(1-fa^2);   %parte real negativa

%% Calculando contribuicoes dos polos e zeros do den da FT de malha fechada

sd   = -fa*wn + 1i*wn*sqrt(1-fa^2); 
polo = 0.0001919; %polo planta

fase2 = 180 - rad2deg(double(atan( abs(imag(sd))/(-1*real(sd)))));
fase3 = 180 - rad2deg(double(atan( abs(imag(sd))/(-1*real(sd) - polo))));

faseConhecida =  - (fase2 + fase3);

faseTotal = -180; %se K>0

syms faseDesconhecida
faseDesconhecida = vpa(solve(faseTotal == faseConhecida + faseDesconhecida));

%zeros SEMPRE a esquerda da localizacao do sd para nao afetar a dominancia
% Calculando a localizacao do zero do controlador:
zero =  -1*real(sd) +  (imag(sd))/tan(deg2rad(double(faseDesconhecida)));

fasePROVAreal = rad2deg(double(atan( abs(imag(sd))/(zero + real(sd)))));

%% Calculando K
syms K  
s = sd_imPositivo;
num = K*(s + double(zero))*(Ke/5211);
den = s*(s+ double(polo));
Kc_pos = double(vpa(solve(((1 + ((num/den)) == 0)))));
s = sd_imNegativo;
Kc_neg = double(vpa(solve(((1 + ((num/den)) == 0)))));

Kc = real(Kc_pos);

%% Funcoes de transferencia contínuas 

s = tf('s'); % variavel de Laplace

%FT da planta P(s) sem perturbação
P = Ke/(1+s*tau);
[num_P,den_P] = tfdata(P);

%FT do controlador PI
C = Kc*((s+double(zero))/s);
[num_C,den_C] = tfdata(C);

%% 
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