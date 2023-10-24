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

%% Extracao dos dados experimentais do ensaio com 2000 RPM

nCol = 5; % numero colunas
nColl = 6;

nSam = 1157; %numero de amostras

fName = '20231009_125114_meas_medsFreio__b.txt';  %valores de tensão e corrente
gName = '20231009_125114_meas_medsWatt__b.txt';   %valores de potencia

fileID  = fopen(fName,'r');
fileID2 = fopen(gName,'r');
formatSpec = repmat('%f',1,nCol);
A = fscanf(fileID,formatSpec,[nCol nSam]);
A = A';
B = fscanf(fileID2,formatSpec,[nColl nSam]);
B = B';

%% Vetores das colunas
vecIter = A(:,1); %time
vecIF   = A(:,2); %corrente de saída da fonte para o freio
vecIR   = A(:,3); %referencia de corrente da fonte para o freio
vecVF   = A(:,4); %tensão de saída da fonte para o freio
vecVR   = A(:,5); %referencia de tensão da fonte para o freio


vecPCE = B(:,2); %potencia calculada na entrada do inversor
vecPLE = B(:,3); %potencia lida na entrada do inversor
vecPCT = B(:,4); %potencia calculada total
vecPLT = B(:,5); %potencia lida total
vecVel = B(:,6); %referencia de velocidade

%% Graficos dos valores de corrente e tensão medidos/aplicados ao freio

figure
set(gcf,'OuterPosition',[0 figHeight figWidth figHeight]);
set(gcf,'name','Medidas do freio')

grid on
hold on

subplot(2,1,1)
plot(vecIter,vecIF)
hold on
plot(vecIter,vecIR)
hold off
axis([0 vecIter(end) 0.07 0.3])
legend('Medido','Referência');
xlabel('tempo [s]')
ylabel('Corrente [A]')
subplot(2,1,2)
plot(vecIter,vecVF)
hold on
plot(vecIter,vecVR)
hold off
axis([0 vecIter(end) 0 18])
legend('Saída atual','Limite da fonte');
xlabel('tempo [s]')
 ylabel('Tensão [V]')
 
 
%% Graficos dos valores de potencia do inversor

figure
set(gcf,'OuterPosition',[0 figHeight figWidth figHeight]);
set(gcf,'name','Valores de potencia')

grid on
hold on

subplot(2,1,1)
plot(vecIter,vecPCE)
hold on
plot(vecIter,vecPLE)
hold on
hold off
axis([0 vecIter(end) 0 260])
legend('Calculada','Lida');
xlabel('tempo [s]')
ylabel('PE [W]')
subplot(2,1,2)
plot(vecIter,vecPCT)
hold on
plot(vecIter,vecPLT)
%hold on
%plot(vecIter, vecVel, 'visible', 'off')
hold off
axis([0 vecIter(end) 0 260])
legend('Calculada','Lida');
xlabel('tempo [s]')
ylabel('PT [W]')
 
 
 
%% pesquisando os intervalos

degraus = [vecIR(1)];
init = [];
t_rp = []; 

%constroi vetor com valores diferentes dos degraus de PWM
for i = 1: length(vecIR)-1
    i = i + 1;
    if vecIR(i) ~= vecIR(i-1) & vecIR(i) > 0
        degraus(end+1) = vecIR(i);                            
    end 
end

%registrando a primeira ocorrência de cada um deles dentro do vecPWM
for i = 1 : length(degraus)   
   init(end+1) = find(vecIR==degraus(i), 1);
end

%% 
x= vecIR(229:270) 
y= vecPCT(229:270)

subplot(2,1,1)
plot(vecIF)
hold on
plot(vecIR)
legend('IF','IR')
subplot(2,1,2)
plot(vecPCT)
legend('Pot')
