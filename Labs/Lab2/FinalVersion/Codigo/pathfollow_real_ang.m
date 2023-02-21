function [ percorrido,visto, integrated_error] = pathfollow_real_ang(path, v, start, error,p0)
global rob;
%PATHFOLLOW_REAL_ANG Fun��o que recebe a porta s�rie e traject�ria a ser
%seguida e segue-a com velocidade v.
%   Detailed explanation goes here

% Orientar o robot na direc��o do primeiro tro�o
if(start == 1)
    theta=fix(atan2(path(2,2)-path(1,2),path(2,1)-path(1,1))*360/2/pi)
    pioneer_set_heading(rob,theta);
    integrated_error=0;
    pause(3)
else
    integrated_error=error;
    theta = 0;
end

% Inicializa��o de contantes
percorrido=[]
visto=[]
ref=1;
K=v/100;  % Factor escala, uma vez que foi testado a v=100 este factor permite usar as mesmas contantes para qualquer v

w=0;
pioneer_set_controls(rob,v,w);
zone = 0;
n_count = 0;
passo=0;
y_correct = 0;


figure,
while ref~=length(path)
    
    ref
    passo=passo+1;
    
    % Localiza��o atrav�s de odomtria.
    q=pioneer_read_odometry();
    x=q(1);
    y=q(2);
    thetareal=q(3);
    thetareal=fix(thetareal*360/4096);
    if thetareal>180
        thetareal=thetareal-360;
    else thetareal;
    end
    percorrido=[percorrido;x y thetareal];
    
    vision=pioneer_read_sonars();
    if length(vision)==8
        visto=[visto;vision];
    else visto=[visto;ones(1,8)*5000];
    end
    
   
    
    
    % Procurar ponto de refer�ncia e caso seja o �ltimo ponto da
    % traject�ria aborta a navega��o. Caso contr�rio calcula velocidade
    % angular de refer�ncia.
    
    ref=nearestpt(x,y,path,ref);
    if ref==length(path)
        pioneer_set_controls(rob,0,0);

        break
    end
    
%    Sonar helps to stay at the midle of the hall  
    zone = check_zone(path(ref,1) + p0(1,1),path(ref,2)+ p0(1,2),44.40);
    zone
    if n_count == 100 && zone ~= 0 % Quantas menos correccoes menos erros
                      % Testar com correccoes de 15 a 20 s
                      % n_count == 150 ou n_count == 200 
    %    Hall 1
%         if zone == 1
%             
%             vision_1 = vision(1)
%             vision_8 = vision(8)
%             if(vision(8) > 750) % Encostado a direita
%                 y_correct = y_correct + (vision(8) - 850)/2;
%                
%              end
%             if(vision(8) < 650) % Encostado a esquerda
%                 y_correct = y_correct - (850 - vision(8))/2;
%             end
% 
%         end

%         %    Hall 2
%         if zone == 2
%             vision_1 = vision(1)
%             vision_8 = vision(8)
%             if(vision(1) > 750 && vision(8) < 750) % Encostado a direita
%               %x_correct = x_correct - (850 - vision(8));
%                 
%              end
%             if(vision(8) > 750 && vision(1) < 750) % Encostado a esquerda
%                 %x_correct = x_correct + (850 - vision(1));
% 
%             end
% 
%         end
% 
%         %    Hall 3
%         if zone == 3
%             vision_1 = vision(1)
%             vision_8 = vision(8)
%             if(vision(1) > 750 && vision(8) < 750)
%              
%             
%             end
%             if(vision(8) > 750 && vision(1) < 750)
%          
%                 
%             end
% 
%         end
% 
%      %    Hall 4
%         if zone == 4
%             vision_1 = vision(1)
%             vision_8 = vision(8)
%             if(vision(1) > 750 && vision(8) < 750)
%               
%                 
%             end
%             if(vision(8) > 750 && vision(1) < 750)
%               
%                 
%             end
% 
%         end
       
        n_count = 0;
    end
    
    x = x;
    y = y + y_correct;
    
    if zone ~= 0
        n_count = n_count + 1;
    end
    
    xref=path(ref,1);
    yref=path(ref,2);
    thetaref=atan2(1000*(path(ref+1,2)-yref),1000*(path(ref+1,1)-xref))*360/2/pi;
    if ref==1
        dtheta=0;
    else dtheta=thetaref-atan2(1000*(yref-path(ref-1,2)),1000*(xref-path(ref-1,1)))*360/2/pi;
    end
    
   
    
    wref=dtheta*v/sqrt((path(ref+1,1)-path(ref,1))^2+(path(ref+1,2)-path(ref,2))^2);
    
    % C�lculo dos erros de orienta��o e posi��o
    
    theta_err=thetaref-thetareal;
    
    if theta_err<-180
        theta_err=theta_err+360;
    elseif theta_err>180
        theta_err=theta_err-360;
    end
    
    
    eWF=[xref-x;
        yref-y;
        theta_err];
    
    eB=[cos(thetaref) sin(thetaref) 0;
        -sin(thetaref) cos(thetaref) 0;
        0 0 1]*eWF;
    
    
    %C�lculo dos ajustes aos erros
    
    integrated_error=0.5*integrated_error+eB(2);
    
    qsi=0.1;
    
    b=0.0005;
    
     
    adjust_eb2=b*v*integrated_error*K;
    
    if abs(adjust_eb2)>30
        adjust_eb2=30*sign(adjust_eb2);
    end
    
    
    adjust_eb3=eB(3)*2*qsi*sqrt(wref^2+abs(b)*v^2)*K;
    if abs(adjust_eb3)>15
        adjust_eb3=15*sign(adjust_eb3);
    end
    
    vision=pioneer_read_sonars;
    angles=[90 50 30 10 -10 -30 -50 -90];

    
    adjust_eb2;
    adjust_eb3;
    w=fix(wref+adjust_eb3+adjust_eb2);
    
    display(w);
    pioneer_set_controls(rob,v,w);
      
    % Ciclo que mostra as traject�rias e as leituras de sonar a cada 10
    % ciclos.
    if passo==10
        passo=0;
        
        subplot(1,2,1)
        plot(path(:,1),path(:,2));hold on;
        plot(x,y,'o');
        plot(percorrido(:,1),percorrido(:,2),'.g');
        plot(xref,yref,'marker','o','color','r');hold off;
        
        
        % M�todo para mostrar os sonares s� at� 500 mm
        for i=1:8
            if vision(i)>1000
                vision(i)=1000;
            end
        end
        
        subplot(1,2,2)
        polar(angles*2*pi/360,vision(1:8));
        
        
        pause(0.1)
    end
        
end

end


function[imin]=nearestpt(x,y,path,ref);

imin=ref+1;
min=(path(1,1)-x)^2+(path(1,2)-y)^2;

if ref < length(path)/2 
    for i=ref:length(path)/2;
        if min>(path(i,1)-x)^2+(path(i,2)-y)^2;
            min=(path(i,1)-x)^2+(path(i,2)-y)^2;
            imin=i+1;
        end
    end
else
    for i=ref:length(path);
        if min>(path(i,1)-x)^2+(path(i,2)-y)^2;
            min=(path(i,1)-x)^2+(path(i,2)-y)^2;
            imin=i+1;
        end
    end       
end
display(imin);
end
    
    