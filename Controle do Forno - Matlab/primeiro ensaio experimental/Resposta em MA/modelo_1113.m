clear all
close all
clc

%% Configuracao de um grid na tela para graficos

screenSize = get(0,'screensize'); % gets screen size
monWidth = screenSize(3);
monHeight = screenSize(4);

offHeight = 30; % assumed height of system task bar
monHeight = monHeight - offHeight; % usable screen height

% establishing a 2x3 grid on the screen
figHeight = monHeight/2;
figWidth = monWidth/3;

%% Extracao dos dados experimentais

nCol = 4; % numero colunas
nSam = 402016; % numero de amostras 

fName = '20230904_171958_heater___b_comconvec2.txt';
fileID = fopen(fName,'r');
formatSpec = repmat('%f',1,nCol);
A = fscanf(fileID,formatSpec,[nCol nSam]);
A = A';

%% Vetores das colunas
vecIter = A(:,1); %time
vecT4   = A(:,2); %temperatura CH4
vecT9   = A(:,3); %temperatura CH9
vecPWM  = A(:,4); %duty cycle PWM

%media temperaturas
vecTM = (vecT4 + vecT9)/2;

%% Graficos dos dados experimentais

figure
set(gcf,'OuterPosition',[0 figHeight figWidth figHeight]);
set(gcf,'name','Temperaturas')

grid on
hold on

first =  find(vecT4>0, 1); %primeiro valor de temperatura acima de zero
subplot(2,1,1)
plot(vecIter(first:end),vecT4(first:end))
hold on
plot(vecIter(first:end),vecT9(first:end))
hold on
plot(vecIter(first:end),vecTM(first:end))
hold off
legend('CH4','CH9','TM');
subplot(2,1,2)
plot(vecIter(first:end),vecPWM(first:end))
legend('duty cycle');

%% selecionando a partir do valor degrau 11% --> 13% duty cycle

figure
subplot(2,1,1);
pr =  find(vecTM==31.625, 1);
plot(vecIter(pr:end),vecTM(pr:end))
axis([pr length(vecIter)  31 41])
xlabel('iteration')
ylabel('Temperature [ºC]')

subplot(2,1,2);
plot(vecIter(pr:end),vecPWM(pr:end))
axis([pr length(vecIter)  8 18])
xlabel('iteration')
ylabel('Duty Cycle PWM [%]')

%% Relação ente dados colhidos em regime permanente pv(mv)

%mv PWM [duty cycle %]:       
x = [ 9       11      13     15     17];
%pv temperatura media [ºC]:   
y = [ 31.668  34.10   35.80  38.50  39.93];
%plot([9 11 13 15 17],[ 31.668  34.10   35.80  38.50  39.93]);
nx = x - 9;
ny = y - 31.668;
plot(nx,ny)
xlabel('PWM')
ylabel('Temperature')


%% pesquisando os intervalos

degraus = [];
init = [];

%constroi vetor com valores diferentes dos degraus de PWM
for i = 1: length(vecPWM)-1
    i = i + 1;
    if vecPWM(i) ~= vecPWM(i-1) & vecPWM(i) > 0
        degraus(end+1) = vecPWM(i);                            
    end 
end

%registrando a primeira ocorrência de cada um deles dentro do vecPWM
for i = 1 : length(degraus)   
   init(end+1) = find(vecPWM==degraus(i), 1);
end

%% Normalizacao dos dados

%u = 11 --> 13
u = vecPWM(276367:324753); %inicio e fim do intervalo
uN = u - 11;

%y = 34.1820 --> 35.95 
y = vecTM(276367:324753);  %inicio e fim do intervalo
yN = y - 34.1820;

%configurando janela
screenSize = get(0,'screensize'); % gets screen size
monWidth = screenSize(3);
monHeight = screenSize(4);
offHeight = 0; % assumed height of system task bar
monHeight = monHeight - offHeight; % usable screen height
% establishing a 2x3 grid on the screen
figHeight = monHeight/2;
figWidth = monWidth/3;

%nao normalizado (começa do ponto de operacao 2.5V)
figure
set(gcf,'OuterPosition',[1 offHeight figWidth figHeight]);
set(gcf,'name','Dados não normalizados')
subplot(2,1,1)
plot(y)
hold on
xlabel('iteration')
ylabel('Temperatura [ºC]')
hold on
subplot(2,1,2)
plot(u)
xlabel('iteration')
ylabel('duty cycle [%]')

% normalizado --> ponto de operação deslocado para a origem
figure
set(gcf,'OuterPosition',[1 offHeight figWidth figHeight]);
set(gcf,'name','Dados normalizados')
subplot(2,1,1)
plot(yN)
xlabel('iteration')
ylabel('Temperatura [ºC]')
hold on
subplot(2,1,2)
plot(uN)
xlabel('iteration')
ylabel('duty cycle [%]')

%% Modelo estimado pelo System Identification a partir dos dados normalizados

m_est = tf(0.000163, [1 0.0001979]);

%Gerando graficos 
sim('simu_ma')


screenSize = get(0,'screensize'); % gets screen size
monWidth = screenSize(3);
monHeight = screenSize(4);
offHeight = 0; % assumed height of system task bar
monHeight = monHeight - offHeight; % usable screen height
% establishing a 2x3 grid on the screen
figHeight = monHeight/2;
figWidth = monWidth/3;

%Resposta em malha aberta
figure
set(gcf,'OuterPosition',[1 offHeight figWidth figHeight]);
set(gcf,'name','comparacao Resposta MA')
plot(out.dataSimu(:,2), 'ro')
hold on
plot(y, '-.c')
xlabel('Tempo [s]')
ylabel('Temperatura [ºC]')
legend('Modelo Estimado', 'Dados medidos')


%% estimando pelos dados medidos
to = 0;
uo = 11;
uf = 13;
yo = 34.1820;
yf = 35.95;
y63 = yo + 0.63*(yf-yo);
t1 = 5525;
tau = t1 - to
Kp = (yf - yo)/(uf - uo);
s = tf('s')
FT = Kp/(1+s*tau);

step(m_est)
hold on
step(FT)
legend('est SI', 'est Calculo')


%% Controle e resposta em malha fechada

%planta estimada
H = tf(m_est);

%1o ajuste feito pelo tuning pid do Control system designer
pi = PI_lento;   %Kp = 8.59, Ti = 4.54e+03  tf([8.59 0.001894], [1 0])
pi_cd = tf(pi);
pid = PI_fast; %Kp = 86.1, Ti = 4.07e+03  tf([86.1 0.02115], [1 0])
pid_cd = tf(pid);

%ajuste antigo
%pi_cd  = tf([18.02 0.0009248], [1 0]);
%pid_cd = tf([26.65 0.1126 8.395e-05], [1 0.005012 0]); 

% ajuste do controlador pelo PID tune 
C1 = pidtune(H,'PI');  C1= tf(C1);
C2 = pidtune(H,'PID'); C2= tf(C2);

sys1 = feedback(H*C1,1);
sys2 = feedback(H*C2,1);
sys3 = feedback(H*pi_cd,1);
sys4 = feedback(H*pid_cd,1);

[u,t] = gensig("square",75000,150000);
lsim(sys1,sys2,sys3,sys4, u,t)
grid on
legend("PI","PID", "PI control", "PID control")

%% Resposta em malha fechada 
sim('simu_mf_1113')

figure
set(gcf,'OuterPosition',[1 offHeight figWidth figHeight]);
set(gcf,'name','Resposta MF')
deg =  plot(out.setpoint.time, out.setpoint.data, 'g');
hold on
p0 = plot(out.pv_C1.time, out.pv_C1.data, 'r');
hold on
p1 = plot(out.pv_C2.Time, out.pv_C2.Data, 'b');
hold on
p2 = plot(out.pv_picd.Time, out.pv_picd.Data, '-y');
hold on
p3 = plot(out.pv_pidcd.Time, out.pv_pidcd.Data, '-k');
grid on
xlabel('Tempo [s]')
ylabel('Temperatura [ºC]')
%axis([0 99.99e03 25 48]);
legend([deg, p0,p1,p2,p3],'SP', 'PV C1','PV C2', 'PV PIcd','PV PIDcd');

figure
set(gcf,'OuterPosition',[1 offHeight figWidth figHeight]);
set(gcf,'name','Resposta MF - Sinal de controle')
p0 = plot(out.mv_C1.time, out.mv_C1.data, 'r');
hold on
p1 = plot(out.mv_C2.Time, out.mv_C2.Data, 'b');
hold on
p2 = plot(out.mv_picd.Time, out.mv_picd.Data, '-y');
hold on
p3 = plot(out.mv_pidcd.Time, out.mv_pidcd.Data, '-k');
grid on
xlabel('Tempo [s]')
ylabel('Temperatura [ºC]')
%axis([0 99.99e03 25 48]);
legend([p0,p1,p2,p3],'MV C1','MV C2', 'MV PIcd','MV PIDcd');
