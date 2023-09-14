clc
clear all
close all

%% Modelo da planta estimado pelo System Identification a partir dos dados normalizados

H = tf(0.0001867, [1 0.0001919]);


%% Controlador 

% ajuste do controlador pelo PID tune 
C1 = pidtune(H,'PI');  C1= tf(C1);
C2 = pidtune(H,'PID'); C2= tf(C2);

%1o ajuste feito pelo tuning pid do Control system designer
pi = pi_1o;   %Kp = 39.6, Ti = 877  tf(39.6 0.04516], [1 0])
pi_cd = tf(pi);


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
deg =  plot(out.setpoint.time/60, out.setpoint.data, 'g');
hold on
p0 = plot(out.pv_C1.time/60, out.pv_C1.data, 'r');
hold on
p1 = plot(out.pv_C2.Time/60, out.pv_C2.Data, '-y');
hold on
p2 = plot(out.pv_picd.Time/60, out.pv_picd.Data, 'b');
%hold on
%p3 = plot(out.pv_pidcd.Time, out.pv_pidcd.Data, '-k');
grid on
xlabel('Tempo [min]')
ylabel('Temperatura [ºC]')
axis([0 1.6e03 25 48]);
legend([deg, p0,p1,p2],'SP', 'PV C1','PV C2', 'PI ajuste');

figure
set(gcf,'OuterPosition',[1 offHeight figWidth figHeight]);
set(gcf,'name','Resposta MF - Sinal de controle')
p0 = plot(out.mv_C1.time/60, out.mv_C1.data, 'r');
hold on
p1 = plot(out.mv_C2.Time/60, out.mv_C2.Data, '-y');
hold on
p2 = plot(out.mv_picd.Time/60, out.mv_picd.Data, 'b');
%hold on
grid on
xlabel('Tempo [min]')
ylabel('Duty cycle [%]')
axis([0 1.6e03 0 100]);
legend([p0,p1,p2],'MV C1','MV C2', 'MV PI ajuste');