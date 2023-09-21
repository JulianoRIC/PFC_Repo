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

nSam = 18824; %numero de amostras 1o teste:fora da sala
%nSam = 18897 ; %numero de amostras 2o teste: dentro da sala

fName = '20230918_110145_mf_ensaioForno__b.txt'; %1o teste
%fName = '20230919_134331_mf_ensaioForno__b.txt';  %2o teste: dentro da sala

fileID = fopen(fName,'r');
formatSpec = repmat('%f',1,nCol);
A = fscanf(fileID,formatSpec,[nCol nSam]);
A = A';

%% Vetores das colunas
vecIter = A(:,1); %time
vecPV   = A(:,2); %temperatura de saída PV
vecSP   = A(:,3); %temperatura de SP
vecMV   = A(:,4); %duty cycle PWM 

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
plot(minutos,vecPV)
hold on
plot(minutos,vecSP)
hold off
axis([0 minutos(end) 22 58])
legend('PV','SP');
xlabel('tempo [min]')
ylabel('Temperatura [ºC]')
subplot(2,1,2)
plot(minutos,vecMV)
axis([0 minutos(end) 0 100])
xlabel('tempo [min]')
ylabel('Duty Cycle PWM [%]')