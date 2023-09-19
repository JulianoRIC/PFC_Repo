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
nSam = 18824; % numero de amostras 

fName = '20230918_110145_mf_ensaioForno__b.txt';
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
axis([0 minutos(end) 0 100])
xlabel('tempo [min]')
ylabel('Duty Cycle PWM [%]')