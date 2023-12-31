clc
clear all
close all

%% Modelo da planta estimado pelo System Identification a partir dos dados normalizados

H = tf(0.0001867, [1 0.0001919]);

%esquece
%%planta estimada com dados reais e primeiro ajuste do pi
%H = tf(0.002052, [1 0.002075]); %um degraus so 35 para 40
%H = tf(0.001915, [1 0.001917]); %todos os degraus
%% Controlador 

% ajuste do controlador pelo PID tune 
C1 = pidtune(H,'PI');  C1= tf(C1);
C2 = pidtune(H,'PID'); C2= tf(C2);

%1o ajuste feito pelo tuning pid do Control system designer
pi = tf([39.6 0.04516], [1 0]);   %Kp = 39.6, Ti = 877 seg ou 14,6168 min  tf(39.6 0.04516], [1 0])
pi_cd = tf(pi);

%usando o pi aplicado na planta real
% s = tf('s');
% num = 34737*(877*s+1);
% den = 877*s;
% pi = tf(num/den)   %Kp = 39.6, Ti = 14,6168 min  
% pi_cd = tf(pi);


%2º ajuste de controlador
pif = tf([39.15 0.06366], [1 0]);   %Kp = 39.1, Ki = 0.06366   tf([39.15 0.06366], [1 0]).
                     %Ki = Kp/Ti --> Ti = Kp/Ki = 613.8148


%% Resposta em malha fechada 
sim('simuMF')

%configurando janela
screenSize = get(0,'screensize'); % gets screen size
monWidth = screenSize(3);
monHeight = screenSize(4);
offHeight = 0; % assumed height of system task bar
monHeight = monHeight - offHeight; % usable screen height
% establishing a 2x3 grid on the screen
figHeight = monHeight/2;
figWidth = monWidth/3;


figure
set(gcf,'OuterPosition',[1 offHeight figWidth figHeight]);
set(gcf,'name','Resposta MF')
deg =  plot(out.setpoint.time/60, out.setpoint.data, 'r');
hold on
% p0 = plot(out.pv_C1.time/60, out.pv_C1.data, 'r');
% hold on
% p1 = plot(out.pv_C2.Time/60, out.pv_C2.Data, '-y');
% hold on
 p2 = plot(out.pv_picd.Time/60, out.pv_picd.Data, 'b');
% hold on
% p3 = plot(out.pv_pif.Time/60, out.pv_pif.Data, '-k');
grid on
xlabel('Tempo [min]')
ylabel('Temperatura [ºC]')
axis([0 300 25 55]);
%legend([deg, p0,p1,p2, p3],'SP', 'PV C1','PV C2', 'PI ajuste 1', 'PI ajuste 2');
legend('SP','PV')

figure
set(gcf,'OuterPosition',[1 offHeight figWidth figHeight]);
set(gcf,'name','Resposta MF - Sinal de controle')
%p0 = plot(out.mv_C1.time/60, out.mv_C1.data, 'r');
% hold on
% p1 = plot(out.mv_C2.Time/60, out.mv_C2.Data, '-y');
% hold on
 p2 = plot(out.mv_picd.Time/60, out.mv_picd.Data, 'b');
% hold on
% p3 = plot(out.mv_pif.Time/60, out.mv_pif.Data, 'k');
grid on
xlabel('Tempo [min]')
ylabel('Duty cycle [%]')
axis([0 300 0 100]);
%legend([p0,p1,p2,p3],'MV C1','MV C2', 'MV PI ajuste1', 'MV PI ajuste2');


%% subplot
subplot(2,1,1)
plot(out.setpoint.time/60, out.setpoint.data, 'r');
hold on
plot(out.pv_picd.Time/60, out.pv_picd.Data, 'b');
xlabel('Tempo [min]')
ylabel('Temperatura [ºC]')
legend('SP','PV')
axis([0 300 25 55]);
subplot(2,1,2)
p2 = plot(out.mv_picd.Time/60, out.mv_picd.Data, 'b');
xlabel('Tempo [min]')
ylabel('Duty cycle [%]')
axis([0 300 0 100]);


%% Parametros da planta
Ke =   0.9729;     %ganho estatico da planta
tau =  5.2110e+03;    %constante de tempo da equação linearizada perto do ponto de equilibrio

s = tf('s'); % variavel de Laplace

%FT da planta P(s) sem perturbação
 P = Ke/(1+s*tau);
 [num_P,den_P] = tfdata(P);

%controlador
C = pi_cd;


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


t_5 = 1.13e+03;
ts = t_5/20;

