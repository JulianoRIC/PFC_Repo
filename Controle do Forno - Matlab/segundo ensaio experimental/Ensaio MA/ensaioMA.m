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
nSam = 254938; % numero de amostras 

fName = '20230911_105646_heater___b_comconvecFinal.txt';
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

minutos = [];

for i=1:length(vecIter) 
   minutos(end+1) = vecIter(i)/60; 
end
%% Graficos dos dados experimentais

figure
set(gcf,'OuterPosition',[0 figHeight figWidth figHeight]);
set(gcf,'name','Temperaturas')

grid on
hold on

subplot(2,1,1)
plot(minutos,vecT4)
hold on
plot(minutos,vecT9)
hold on
plot(minutos,vecTM)
hold off
axis([0 minutos(end) 22 58])
legend('CH4','CH9','TM');
xlabel('tempo [min]')
ylabel('Temperatura [ºC]')
subplot(2,1,2)
plot(minutos,vecPWM)
axis([0 minutos(end) 4 32])
xlabel('tempo [min]')
ylabel('Duty Cycle PWM [%]')


%% pesquisando os intervalos

degraus = [vecPWM(1)];
init = [];
t_rp = []; 

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

%em minutos
i_min = init/60;

%registrando os valores da temperatura média em regime permanente
for i = 2 : length(init) 
   t_rp(end+1) = vecTM(init(i)-1);
   if i > 5 
       t_rp(end+1) = vecTM(end);
   end
end


%% Relação ente dados colhidos em regime permanente pv(mv)
%plot(degraus, t_rp);
nx = degraus - degraus(1);
ny = t_rp - t_rp(1);
figure
plot(nx,ny)
xlabel('\Delta duty cycle PWM [%]')
ylabel('\Delta Temperature [ºC]')


%% Normalizacao dos dados

%u = 10 --> 15
u = vecPWM(init(3)-1:init(4)-1); %inicio e fim do intervalo
uN = u - degraus(2);

%y = 34.9295 --> 39.6710 
y = vecTM(init(3)-1:init(4)-1);  %inicio e fim do intervalo
yN = y - t_rp(2);

%colocando em minutos
x = (init(3)-1:init(4)-1)/60;
xN = x - x(1);

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
plot(x,y)
hold on
xlabel('iteration')
ylabel('Temperatura [ºC]')
axis([x(1) x(end) 34 40])
hold on
subplot(2,1,2)
plot(x,u)
axis([x(1) x(end) 9 16])
xlabel('iteration')
ylabel('duty cycle [%]')

% normalizado --> ponto de operação deslocado para a origem
figure
set(gcf,'OuterPosition',[1 offHeight figWidth figHeight]);
set(gcf,'name','Dados normalizados')
subplot(2,1,1)
plot(xN,yN)
xlabel('iteration')
ylabel('Temperatura [ºC]')
hold on
subplot(2,1,2)
plot(xN,uN)
xlabel('iteration')
ylabel('duty cycle [%]')


%% Modelo estimado pelo System Identification a partir dos dados normalizados

planta = tf(0.0001867, [1 0.0001919]);

%Gerando graficos 
sim('simu_MA')


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
plot(out.pvMA(:,2), 'ro')
hold on
plot(y, '-.c')
xlabel('Tempo [s]')
ylabel('Temperatura [ºC]')
legend('Modelo Estimado', 'Dados medidos')

