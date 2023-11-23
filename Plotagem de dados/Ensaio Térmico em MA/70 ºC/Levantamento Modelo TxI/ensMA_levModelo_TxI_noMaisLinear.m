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

for i=1:length(vecIter) 
   minutos(end+1) = vecIter(i)/60; 
end

%vecIter = minutos; %convertendo para minutos

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
t_rp = showRegPerm(init(1:end), vecTP13, vecIter, vecIR, 'TP13')
 
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

%% Determinando regiao de operacao aproximadamente linear

%tp1:  deltaI = [144 188] mA
%plot(vecTP1(4016:5877))

%tp3:  deltaI = [276 320] mA 
%subplot(2,1,1)
%plot(vecTP3(9766:end-1))

%tp5:  deltaI = [144 188] mA
%plot(vecTP5(4016:5877)

%tp6:  deltaI = [144 188] mA 
%plot(vecTP6(4016:5877))

%tp7: nao linear

%tp8:  deltaI = [144 188] mA 
%plot(vecTP8(4016:5878))

%tp10:  deltaI = [100 144] mA 
%plot(vecTP10(2210:4015))

%tp11: nao linear

%tp12:  deltaI = [100 144] mA 
%plot(vecTP12(2210:4015))

%tp13:  deltaI = [100 144] mA 
subplot(2,1,1)
plot(vecTP13(2210:4015))
subplot(2,1,2)
plot(vecIR(2210:4015))

%tp15: dissipador (nao usado)


%% normalizacao dos dados 

%u = 0.100 mA --> 0.144 mA
u = vecIR(init(2)-1:init(3)-1); %inicio e fim do intervalo
uN13 = u - degraus(1);

%u = 0.144 mA --> 0.188 mA
%u = vecIR(init(3)-1:init(4)-1); %inicio e fim do intervalo
%uN = u - degraus(2);

%u = 0.188 mA --> 0.232 mA
%u = vecIR(init(4)-1:init(5)-1); %inicio e fim do intervalo
%uN3 = u - degraus(3);

%u = 0.232 mA --> 0.276 mA
%u = vecIR(init(5)-1:init(6)-1); %inicio e fim do intervalo
%uNx = u - degraus(4);

%u = 0.276 mA --> 0.320 mA
%u = vecIR(init(6)-1:end-1); %inicio e fim do intervalo
%uNx = u - degraus(5);


%% y1 = 67.3691 --> 67.9381
t_rp = showRegPerm(init(1:end), vecTP1,vecIter, vecIR, 'TP1')
y   = vecTP1(init(3)-1:init(4)-1); 
yN  = y - t_rp(2);

%% y3 = 67.4160 -->  67.9705
t_rp = showRegPerm(init(1:end), vecTP3,vecIter, vecIR, 'TP3')
y   = vecTP3(init(6)-1:end-1);  %inicio e fim do intervalo
yN3  = y - t_rp(5);

%% y5 = 66.4021 -->  66.8479
t_rp = showRegPerm(init(1:end), vecTP5,vecIter, vecIR, 'TP5')
y   = vecTP5(init(3)-1:init(4)-1);  %inicio e fim do intervalo
yN5  = y - t_rp(2);

%% y6 = 66.3006 -->  66.7448
t_rp = showRegPerm(init(1:end), vecTP6,vecIter, vecIR, 'TP6')
y   = vecTP6(init(3)-1:init(4)-1);  %inicio e fim do intervalo
yN6  = y - t_rp(2);

%% y8 =  74.1812 -->  74.7262 
t_rp = showRegPerm(init(1:end), vecTP8,vecIter, vecIR, 'TP8')
y   = vecTP8(init(3)-1:init(4)-1);  %inicio e fim do intervalo
yN8  = y - t_rp(2);

%% y10 =   75.2003 -->   75.6470
t_rp = showRegPerm(init(1:end), vecTP10, vecIter, vecIR, 'TP10')
y   = vecTP10(init(2)-1:init(3)-1);  %inicio e fim do intervalo
yN10  = y - t_rp(1);

%% y12 = 67.8491 -->  68.4542
t_rp = showRegPerm(init(1:end), vecTP12, vecIter, vecIR, 'TP12')
y   = vecTP12(init(2)-1:init(3)-1);  %inicio e fim do intervalo
yN12  = y - t_rp(1);

%% y13 =   69.1950 -->   69.7799  
t_rp = showRegPerm(init(1:end), vecTP13, vecIter, vecIR, 'TP13')
y   = vecTP13(init(2)-1:init(3)-1);  %inicio e fim do intervalo
yN13n  = y - t_rp(1);

%% colocando em minutos
% x = (init(3)-1:init(4)-1);
% xN = x - x(2);

%x = (init(2)-1:init(3)-1);
%xN10 = x - x(1);

%x = (init(5)-1:init(6)-1);
%xN12 = x - x(4);

%%

%nao normalizado (começa do ponto de operacao 2.5V)
figure
set(gcf,'OuterPosition',[1 offHeight figWidth figHeight]);
set(gcf,'name','Dados não normalizados')
subplot(2,1,1)
plot(x,y)
hold on
xlabel('tempo [min]')
ylabel('Temperatura [ºC]')
hold on
subplot(2,1,2)
plot(x,u)
xlabel('tempo [min]')
ylabel('Corrente [A]')

% normalizado --> ponto de operação deslocado para a origem
figure
set(gcf,'OuterPosition',[1 offHeight figWidth figHeight]);
set(gcf,'name','Dados normalizados')
subplot(2,1,1)
plot(xN,yN)
xlabel('tempo [min]')
ylabel('Temperatura [ºC]')
hold on
subplot(2,1,2)
plot(xN,uN)
xlabel('tempo [min]')
ylabel('Corrente [A]')


%% Plantas

%tp1
tftp1 = tf([0 0.009301],[1 0.000233]);
%tp3
tftp3 = tf([0 0.007539],[1 0.0001564]);
%tp5
tftp5 = tf([0 0.006868],[1 0.0001431]);
%tp6
tftp6 = tf([0 0.009227],[1 0.0006283]);
%tp8
tftp8 = tf([0 0.01466],[1 0.0009717]);
%tp10
tftp10 = tf([0 0.01071],[1 0.0007777]);
%tp12
tftp12 = tf([0 0.01807],[1 0.001191]);
%tp13
tftp13 = tf([0 0.01547],[1 0.0009927]);


step(tftp1)
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
legend('TP1','TP5','TP6','TP8','TP10','TP12','TP13')

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