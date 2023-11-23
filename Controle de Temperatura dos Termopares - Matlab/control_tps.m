clc
clear all
close all

%%GRAFICOS DO SIMULINK

%% Modelo da planta estimado pelo System Identification a partir dos dados normalizados

P = tf([0  0.02098/0.000325],[1/0.000325 0.000325/0.000325]);


%% Controlador 

% ajuste do controlador pelo LR
C = tf( [0.2634 0.0008563], [1 0]);

%% Resposta em malha fechada 
sim('simuMFtps')

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
plot(out.setpoint.time/60, out.setpoint.data, 'g');
hold on
plot(out.pv_C.time/60, out.pv_C.data, 'r');
hold on
xlabel('Tempo [min]')
ylabel('Temperatura [ºC]')
%axis([0 300 25 55]);
legend('SP','PV')

figure
set(gcf,'OuterPosition',[1 offHeight figWidth figHeight]);
set(gcf,'name','Resposta MF - Sinal de controle')
p0 = plot(out.mv_C.time/60, out.mv_C.data, 'r');
xlabel('Tempo [min]')
ylabel('Corrente [mA]')
%axis([0 300 0 100]);




