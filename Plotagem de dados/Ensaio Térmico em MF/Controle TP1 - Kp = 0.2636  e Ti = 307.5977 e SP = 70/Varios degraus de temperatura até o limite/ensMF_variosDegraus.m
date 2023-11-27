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

%% Extracao dos dados experimentais do ensaio térmico em MA com Tamb = 70ºC  Ifreio = 320 mA e 3000 RPM
%controlador  Kp = 0.2636 e Ti = 307.5977

nCol   = 5; % numero colunas
nColl  = 6;
nColll = 13;
nCol4  = 4;

nSam  =  14556; %numero de amostras

fName = '20231125_110746_meas_medsFreio__b.txt';  %valores de tensão e corrente
gName = '20231125_110746_meas_medsWatt__b.txt';   %valores de potencia
hName = '20231125_110746_meas_medsETMA__b.txt';   %temperaturas dos termopares do IF e MA
iName = '20231125_110746_meas_medsETMF__b.txt';   %temperaturas dos termopares do IF e MF

fileID  = fopen(fName,'r');
fileID2 = fopen(gName,'r');
fileID3 = fopen(hName,'r');
fileID4 = fopen(iName,'r');
formatSpec  = repmat('%f',1,nCol);
formatSpec2 = repmat('%f',1,nColl);
formatSpec3 = repmat('%f',1,nColll);
formatSpec4 = repmat('%f',1,nCol4);
A = fscanf(fileID,formatSpec,[nCol nSam]);
A = A';
B = fscanf(fileID2,formatSpec2,[nColl nSam]);
B = B';
C = fscanf(fileID3,formatSpec3,[nColll nSam]);
C = C';
D = fscanf(fileID4,formatSpec4,[nCol4 nSam]);
D = D';


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

x       = C(:,1); %time
vecTP1  = C(:,2);   %temperatura do termopar do capacitor C011
vecTP2  = C(:,3);   %temperatura do termopar do capacitor C009 (nao usar)
vecTP3  = C(:,4);   %temperatura do termopar do choke L001
vecTP5  = C(:,5);   %temperatura do termopar do capacitor  C006
vecTP6  = C(:,6);   %temperatura do termopar do fusível F002
vecTP7  = C(:,7);   %temperatura do termopar do conector CN204
vecTP8  = C(:,8);   %temperatura do termopar do CI SMPS IC100
vecTP10 = C(:,9);   %temperatura do termopar do indutor L100
vecTP11 = C(:,10);  %temperatura do termopar do capacitor C112
vecTP12 = C(:,11);  %temperatura do termopar do capacitor C504
vecTP13 = C(:,12);  %temperatura do termopar do microcontrolador IC601
vecTP15 = C(:,13);  %temperatura do dissipador

vecTP2 = vecTP1;
vecTP2(end-23:end) = vecTP1(end-23:end) - 0.2;

vecIter = D(:,1); %time
vecPV   = D(:,2); %temperatura do TP5 em MF
vecSP   = D(:,3); %temperatura de SP
vecMV   = D(:,4); %corrente do freio (MV)

minutos = [];

for i=1:length(vecIter) 
   minutos(end+1) = vecIter(i)/60; 
end

vecIter = minutos;

tim = [];

for i=1:length(x) 
   tim(end+1) = x(i)/60; 
end

x = tim; %convertendo para minutos


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
axis([0 nSam/60 0 .325])
legend('Medido','Referência');
xlabel('tempo [min]')
ylabel('Corrente [A]')
subplot(2,1,2)
plot(vecIter,vecVF)
hold on
plot(vecIter,vecVR)
hold off
axis([0 nSam/60 0 31])
legend('Saída atual','Limite da fonte');
xlabel('tempo [min]')
ylabel('Tensão [V]')
 
 
%% Graficos dos valores de potencia do inversor

figure
set(gcf,'OuterPosition',[0 figHeight figWidth figHeight]);
set(gcf,'name','Valores de potencia')

grid on
hold on

subplot(3,1,1)
plot(vecIter,vecPCE)
hold on
plot(vecIter,vecPLE)
hold off
axis([0 nSam/60 0 420])
legend('Calculada','Lida');
xlabel('tempo [min]')
ylabel('PE [W]')
subplot(3,1,2)
plot(vecIter,vecPCT)
hold on
plot(vecIter,vecPLT)
hold off
axis([0 nSam/60 0 420])
legend('Calculada','Lida');
xlabel('tempo [s]')
ylabel('PT [W]')
subplot(3,1,3)
hold on
plot(vecIter,vecVel)
hold off
axis([0 nSam/60 0 4050])
legend('Velocidade')
xlabel('tempo [min]')
ylabel('Vel [rpm]')



%% Graficos dos valores de temperatura dos termopares do inversor

figure
set(gcf,'OuterPosition',[0 figHeight figWidth figHeight]);
set(gcf,'name','Valores de temperatura')

grid on
hold on

plot(x,vecTP1)
plot(x,vecTP2)
plot(x,vecTP3)
plot(x,vecTP5)
plot(x,vecTP6)
plot(x,vecTP7)
plot(x,vecTP8)
plot(x,vecTP10)
plot(x,vecTP11)
plot(x,vecTP12)
plot(x,vecTP13)
plot(x,vecTP15)
hold off

%axis([0 length(vecIter) 19 80])
legend('TP1','TP2','TP3','TP5','TP6','TP7','TP8','TP10','TP11','TP12','TP13','TP15');
xlabel('tempo [min]')
ylabel('Temperatura [ºC]')


%% todos separados

% tp1
ref = [];
for i = 1:length(vecSP) 
    if i >0  && i < 125.2*60
         ref(i) = 63.2;
    end
    if i >= 125.2*60  && i < 160*60
         ref(i) = 66;
    end
    if i >= 160*60  && i < 177*60
         ref(i) = 67.3;
     end
     if i >= 177*60 && i < 191.6*60
        ref(i) = 68.6;
    end
    if i >= 191.6*60 && i <210*60
        ref(i) = 69.9;
    end
    if i >= 210*60
        ref(i) = 71.05;
    end
end

figure
subplot(2,1,1)
plot(vecIter,vecPV)
hold on
plot(vecIter, ref)
xlabel('tempo [min]')
ylabel('TP 1 [ºC]')
legend('SP', 'PV')
axis([175 242.6667 67 71.25])
subplot(2,1,2)
plot(vecIter,vecMV)
xlabel('tempo [min]')
ylabel('Corrente [A]')
axis([175 242.6667 0 0.32])


%% tp3
figure
subplot(2,1,1)
plot(vecIter,vecTP3)
xlabel('tempo [min]')
ylabel('TP 3')
subplot(2,1,2)
plot(vecIter,vecIF)
xlabel('tempo [min]')
ylabel('Corrente [A]')

%% tp5
figure
subplot(2,1,1)
plot(vecIter,vecTP5)
xlabel('tempo [min]')
ylabel('TP 5')
subplot(2,1,2)
plot(vecIter,vecIF)
xlabel('tempo [min]')
ylabel('Corrente [A]')

%% tp6
figure
subplot(2,1,1)
plot(vecIter,vecTP6)
xlabel('tempo [min]')
ylabel('TP 6')
subplot(2,1,2)
plot(vecIter,vecIF)
xlabel('tempo [min]')
ylabel('Corrente [A]')

%% tp 7
figure
subplot(2,1,1)
plot(vecIter,vecTP7)
xlabel('tempo [min]')
ylabel('TP 7')
subplot(2,1,2)
plot(vecIter,vecIF)
xlabel('tempo [min]')
ylabel('Corrente [A]')

%% tp 8
figure
subplot(2,1,1)
plot(vecIter,vecTP8)
xlabel('tempo [min]')
ylabel('TP 8')
subplot(2,1,2)
plot(vecIter,vecIF)
xlabel('tempo [min]')
ylabel('Corrente [A]')

%% tp 10
figure
subplot(2,1,1)
plot(vecIter,vecTP10)
xlabel('tempo [min]')
ylabel('TP 10')
subplot(2,1,2)
plot(vecIter,vecIF)
xlabel('tempo [min]')
ylabel('Corrente [A]')

%% tp11
figure
subplot(2,1,1)
plot(vecIter,vecTP11)
xlabel('tempo [min]')
ylabel('TP 11')
subplot(2,1,2)
plot(vecIter,vecIF)
xlabel('tempo [min]')
ylabel('Corrente [A]')

%% tp12
figure
subplot(2,1,1)
plot(vecIter,vecTP12)
xlabel('tempo [min]')
ylabel('TP 12')
subplot(2,1,2)
plot(vecIter,vecIF)
xlabel('tempo [min]')
ylabel('Corrente [A]')

%% tp13
figure
subplot(2,1,1)
plot(vecIter,vecTP13)
xlabel('tempo [min]')
ylabel('TP 13')
subplot(2,1,2)
plot(vecIter,vecIF)
xlabel('tempo [min]')
ylabel('Corrente [A]')

%% tp15
figure
subplot(2,1,1)
plot(vecIter,vecTP15)
xlabel('tempo [min]')
ylabel('TP 15')
subplot(2,1,2)
plot(vecIter,vecIF)
xlabel('tempo [min]')
ylabel('Corrente [A]')




%% Graficos da resposta em MF

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
axis([30 minutos(end) vecTP1(120.7*60) vecTP1(end)])
legend('PV','SP');
xlabel('tempo [min]')
ylabel('Temperatura [ºC]')
subplot(2,1,2)
plot(minutos,vecMV)
axis([28 minutos(end) 0 0.325])
xlabel('tempo [min]')
ylabel('Corrente [A]')
