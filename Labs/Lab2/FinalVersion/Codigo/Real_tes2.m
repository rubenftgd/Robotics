function [ via ] = Real_test2( p0,pf,real,v )
%REAL_TEST
%   Detailed explanation goes here

% Leitura do ficheiro mapa
load('mapa.mat');
[arvore,fp]=freepoints(mapa);

% Exibi��o dos pontos livres

figure(2),
imshow(mapa); hold on;
for k=1:length(fp)
    plot(fp(k).freepoint(2),fp(k).freepoint(1),'.');
end
pause(0.001);

% Algoritmo de pesquisa e cria��o de pontos vi�rios

pathpts=pesquisafp( arvore,fp,p0,pf,mapa);

pause(0.001);

figure(3),
imshow(mapa); hold on;
plot(pathpts(:,2),pathpts(:,1),'.-');
pause(0.001);hold off;
ratio=15800/348;

% Interpola��o e exibi��o no mapa
[y,x,ppx,ppy]=interpolation(pathpts,1,10000);


% Convers�o para unidades reais

for k=1:length(pathpts(:,1));
    path_real(k,:)=ratio*(pathpts(k,:)-p0);
end





[y,x,ppx,ppy]=interpolation(path_real,1,10000)




via=transpose([x;y]);

% �nicio de simula��o caso pretendido
if real==1
    
    
    rob=serial_port_start();
    
    pathfollow_real_ang(rob,via,v);

end




end

