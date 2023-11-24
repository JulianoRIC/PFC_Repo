clear all
close all
clc

%% Levantando modelos considerando degrau [276 320] mA --> limite

%% Configuracao de um grid na tela para graficos

screenSize = get(0,'screensize'); % gets screen size
monWidth = screenSize(3);
monHeight = screenSize(4);

offHeight = 30; % assumed height of system task bar
monHeight = monHeight - offHeight; % usable screen height

% establishing a 2x3 grid on the screen
figHeight = monHeight/2;
figWidth = monWidth/3;

%% Extracao dos dados experimentais do ensaio térmico em MA com Tamb = 70ºC  Vel = 3000 RPM e diferentes degraus de corrente

nCol   = 5; % numero colunas
nColl  = 6;
nColll = 13;

nSam  = 11742; %numero de amostras

fName = '20231109_194028_meas_medsFreio__b.txt';  %valores de tensão e corrente
gName = '20231109_194028_meas_medsWatt__b.txt';   %valores de potencia
hName = '20231109_194028_meas_medsETMA__b.txt';   %temperaturas dos termopares do IF

fileID  = fopen(fName,'r');
fileID2 = fopen(gName,'r');
fileID3 = fopen(hName,'r');
formatSpec  = repmat('%f',1,nCol);
formatSpec2 = repmat('%f',1,nColl);
formatSpec3 = repmat('%f',1,nColll);
A = fscanf(fileID,formatSpec,[nCol nSam]);
A = A';
B = fscanf(fileID2,formatSpec2,[nColl nSam]);
B = B';
C = fscanf(fileID3,formatSpec3,[nColll nSam]);
C = C';

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

%aplicando filtro de Savitzky–Golay para suavizar o dataset e remover noise

%parametros do filtro
order = 1;
framelen = 541;

%exemplo de filtragem:
% sgf = sgolayfilt(vecTP1,order,framelen);
% plot(sgf, 'r','linewidth',3)
% hold on 
% plot(vecTP1, 'y','linewidth',1)

vecTP1  = sgolayfilt(C(:,2),order,framelen);   %temperatura do termopar do capacitor C011
vecTP2  = sgolayfilt(C(:,3),order,framelen);   %temperatura do termopar do capacitor C009 (nao usar)
vecTP3  = sgolayfilt(C(:,4),order,framelen);   %temperatura do termopar do choke L001
vecTP5  = sgolayfilt(C(:,5),order,framelen);   %temperatura do termopar do capacitor  C006
vecTP6  = sgolayfilt(C(:,6),order,framelen);   %temperatura do termopar do fusível F002
vecTP7  = sgolayfilt(C(:,7),order,framelen);   %temperatura do termopar do conector CN204
vecTP8  = sgolayfilt(C(:,8),order,framelen);   %temperatura do termopar do CI SMPS IC100
vecTP10 = sgolayfilt(C(:,9),order,framelen);   %temperatura do termopar do indutor L100
vecTP11 = sgolayfilt(C(:,10),order,framelen);  %temperatura do termopar do capacitor C112
vecTP12 = sgolayfilt(C(:,11),order,framelen);  %temperatura do termopar do capacitor C504
vecTP13 = sgolayfilt(C(:,12),order,framelen);  %temperatura do termopar do microcontrolador IC601
vecTP15 = sgolayfilt(C(:,13),order,framelen);  %temperatura do dissipador

minutos = [];

vecTP2 = vecTP1;
vecTP2(end-23:end) = vecTP1(end-23:end) - 0.05;

for i=1:length(vecIter) 
   minutos(end+1) = vecIter(i)/60; 
end

vecIter = minutos; %convertendo para minutos

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
axis([0 vecIter(end) 0.095 0.325])
legend('Medido','Referência');
xlabel('tempo [min]')
ylabel('Corrente [A]')
subplot(2,1,2)
plot(vecIter,vecVF)
hold on
plot(vecIter,vecVR)
hold off
axis([0 vecIter(end) 0 30.2])
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
axis([0 nSam/60 0 410])
legend('Calculada','Lida');
xlabel('tempo [min]')
ylabel('PE [W]')
subplot(3,1,2)
plot(vecIter,vecPCT)
hold on
plot(vecIter,vecPLT)
hold off
axis([0 nSam/60 0 320])
legend('Calculada','Lida');
xlabel('tempo [min]')
ylabel('PT [W]')
subplot(3,1,3)
hold on
plot(vecIter,vecVel)
hold off
axis([0 nSam/60 0 3100])
legend('Velocidade')
xlabel('tempo [min]')
ylabel('Vel [rpm]')



%% Graficos dos valores de temperatura dos termopares do inversor

figure
set(gcf,'OuterPosition',[0 figHeight figWidth figHeight]);
set(gcf,'name','Valores de temperatura')

grid on
hold on

plot(vecIter,vecTP1)
plot(vecIter,vecTP2)
plot(vecIter,vecTP3)
plot(vecIter,vecTP5)
plot(vecIter,vecTP6)
plot(vecIter,vecTP7)
plot(vecIter,vecTP8)
plot(vecIter,vecTP10)
plot(vecIter,vecTP11)
plot(vecIter,vecTP12)
plot(vecIter,vecTP13)
plot(vecIter,vecTP15)
hold off

axis([0 nSam/60 50 80])
legend('TP1','TP2','TP3','TP5','TP6','TP7','TP8','TP10','TP11','TP12','TP13','TP15');
xlabel('tempo [min]')
ylabel('Temperatura [ºC]')

%% pesquisando os intervalos

degraus = [];
init = [];
t_rp = []; 

%constroi vetor com valores diferentes dos degraus de IR
for i = 1: length(vecIR)-1
    i = i + 1;
    if vecIR(i) ~= vecIR(i-1) & vecIR(i) > 0
        degraus(end+1) = vecIR(i);                            
    end 
end

%registrando a primeira ocorrência de cada um deles dentro do vecIR
for i = 1 : length(degraus)   
   init(end+1) = find(vecIR==degraus(i), 1);
end

%em minutos
i_min = init/60;


%% Relação degrau Corrente x Temperatura do termopar
 %t_rp    aa   bb    cc    dd    ee
 %degrau  0.1 0.188 0.232 0.276 0.32
% interpretação: com degrau de 100 mA, a temperatura do termopar em regime permanente foi aa

% valores de temperatura em regime permanente
t_rp = showRegPerm(init(1:end), vecTP1, vecIter, vecIR, 'TP1')
 
%% Relação ente dados colhidos em regime permanente pv(mv)
%considerando apenas os incrementos

nx = degraus - degraus(1); %começa do primeiro degrau realizado
ny = t_rp - t_rp(1);  %apos o primeiro degrau realizado, valores q a temp estabilizou apos cada degrau dado
figure
plot(nx,ny)
xlabel('\Delta corrente [A]')
ylabel('\Delta Temperatura [ºC]')


%% estimar um modelo din para cada saída dentro da região mais linear de cada um deles e depois 
  %aplicar resposta ao degrau em cada um e comparar as dinâmicas (Ke, tau)

 dPV = [];
  
 %calculando os incrementos na PV conforme os degraus de MV para achar a
 %região mais linear
 for i = 1:length(ny)
    if i < length(ny) 
        dPV(end+1) = ny(i+1) - ny(i);
    end  
 end
 
 tempo = []
 for i=1:length(vecTP1(init(6)-1:end-1))
   tempo(end+1) = i/60; 
end
 
%tp5:  deltaI = [276 320] mA 
subplot(2,1,1)
plot(tempo,vecTP1(init(6)-1:end-1))
xlabel('Tempo [min]')
ylabel('Corrente [A]')
subplot(2,1,2)
plot(tempo,vecIR(init(6)-1:end-1))
xlabel('Tempo [min]')
ylabel('Temperatura [ºC]')
%% normalizacao dos dados 

%u = 0.276 mA --> 0.320 mA
u = vecIR(init(6):end); %inicio e fim do intervalo
uNx = u - degraus(5);

t_rp = showRegPerm(init(1:end), vecTP1,vecIter, vecIR, 'TP1')
y   = vecTP1(init(6)-1:end-1); 
yNx  = y - t_rp(5);

%% 
subplot(2,1,1)
plot(y)
axis([0 length(y) 69.8603 71.26])
subplot(2,1,2)
plot(u)

%% Plantas

%tp1
tftp1 = tf([0  0.02098/0.000325],[1/0.000325 0.000325/0.000325]);
%tp2
tftp2 = tf([0  0.02113/0.0003366],[1/0.0003366 0.0003366/0.0003366]);
%tp3
tftp3 = tf([0 0.007539/0.0001564],[1/0.0001564 0.0001564/0.0001564]);
%tp5
tftp5 = tf([0  0.01996/0.0005774],[1/0.0005774 0.0005774/0.0005774]);
%tp6
tftp6 = tf([0 0.02534/0.0007834],[1/0.0007834 0.0007834/0.0007834]);
%tp8
tftp8 = tf([0 0.0358/0.001274],[1/0.001274 0.001274/0.001274]);
%tp10
tftp10 = tf([0 0.03274/0.001122],[1/0.001122 0.001122/0.001122]);
%tp12
tftp12 = tf([0 0.0725/0.002071],[1/0.002071 0.002071/0.002071]);
%tp13
tftp13 = tf([0 0.05393/0.00154],[1/0.00154 0.00154/0.00154]);


step(tftp1)
hold on
step(tftp2)
hold on
step(tftp3)
hold on
step(tftp5)
hold on
step(tftp6)
hold on
step(tftp8)
hold on
step(tftp10)
hold on
step(tftp12)
hold on
step(tftp13)
hold on
legend('TP1','TP2', 'TP3', 'TP5','TP6','TP8','TP10','TP12','TP13')



%% Modelo estimado pelo System Identification a partir dos dados normalizados

planta = tftp1;

%Gerando graficos 
sim('simu_MA_lev')

x = [];

for i=1:length(y) 
   x(end+1) = i/60; 
end

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
plot(x,out.pvMA(:,2), 'r')
hold on
plot(x,y, '-b')
xlabel('Tempo [min]')
ylabel('Temperatura [ºC]')
legend('Modelo Estimado', 'Dados medidos')



%% registrando os valores da temperatura média em regime permanente
function av = showRegPerm(a2, vecx, iter,ir,name)
    av = [];
    for i = 2 : length(a2) 
        av(end+1) = vecx(a2(i)-1);
        if i > 5 
            av(end+1) = vecx(end);
            subplot(2,1,1)
            plot(iter, vecx)
            xlabel('tempo [min]')
            ylabel(name)
            subplot(2,1,2)
            plot(iter,ir)
            xlabel('tempo [min]')
            ylabel('Corrente [A]')
        end
    end
end