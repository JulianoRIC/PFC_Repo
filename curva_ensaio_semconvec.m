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
nSam = 152945; % numero de amostras 

fName = '20230829_173404_heater___b_semconvec.txt';
fileID = fopen(fName,'r');
formatSpec = repmat('%f',1,nCol);
A = fscanf(fileID,formatSpec,[nCol nSam]);
A = A';

%% Vetores das colunas
vecIter = A(:,1); %time
vecT4   = A(:,2); %temperatura CH4
vecT9   = A(:,3); %temperatura CH9
vecPWM  = A(:,4); %duty cycle PWM


%% Graficos dos dados experimentais

figure
set(gcf,'OuterPosition',[0 figHeight figWidth figHeight]);
set(gcf,'name','Temperaturas')

grid on
hold on
plot(vecIter,vecT4)
plot(vecIter,vecT9)
plot(vecIter,vecPWM)

xlabel('iteration','interpreter','latex')
ylabel('Temp','interpreter','latex')

lh = legend('temp CH4','temp CH9','PWM');
set(lh,'interpreter','latex');


