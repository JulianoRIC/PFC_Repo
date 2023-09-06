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

%primeiro valor de temperatura acima de zero
first =  find(vecT4>0, 1);
plot(vecIter(first:end),vecT4(first:end))
plot(vecIter(first:end),vecT9(first:end))
%plot(vecIter(first:end),vecPWM(first:end))

xlabel('iteration')
ylabel('Temperaturas')
legend('CH4','CH9','PWM');


%% Normalizacao dos dados

degraus = [];
init = [];


%o vetor com valores diferentes dos degraus de PWM
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


%% 
%rodar arquivo modelo MTG

%Normalizando os valores de entrada e saída

%Basicamente, é necessário deslocar no tempo e na amplitude todos valores
%medidos da entrada e da saída para que o ponto de operacao inicie em zero.
%Para isso, iniciaremos do valor 2.5V --> que agora será deslocado para 0, então 
%toda a faixa de dados de u que é igual do primeiro valor de 2.5V ate o ultimo valor de 3V 
%(no caso as linhas 4005:5005  da 2a coluna do array) será o ponto inicial, o mesmo é feito 
%com a saída, com a diferença  que o valor descontado será igual ao ultimo valor 
%onde y = 2.5V (pois ja passou o transitorio).

%Scopedata2 é o array gerado pelo scope do Simlulink que guarda na 
%1a coluna: o tempo
%2a coluna: os valores de entrada
%3a coluna: os valores da saída

% u = ScopeData2(3006:5005,2);
% uN = u - 2.5;
% 
% y = ScopeData2(3006:5005,3);
% yN = y - 2.5903;

%nao normalizado (começa do ponto de operacao 2.5V)
% figure
% u = u(600:end) %para começar mais tarde e deixar menos pontos no '2.5'
% y = y(600:end)
% plot(u)
% hold on
% plot(y)
% axis([0 1150 2.45 3.5])
% xlabel('tempo de simulacao [s]')
% ylabel('tensão [V]')
% legend('Entrada de Controle', 'Saida Medida')


%normalizado --> ponto de operação deslocado para a origem
% figure
% uN = uN(600:end)
% yN = yN(600:end)
% plot(uN)
% hold on
% plot(yN)
% axis([0 1150 -0.1 0.9])
% xlabel('tempo de simulacao [s]')
% ylabel('tensão [V]')
% legend('Entrada de Controle Normalizada', 'Saida Medida Normalizada')




    



