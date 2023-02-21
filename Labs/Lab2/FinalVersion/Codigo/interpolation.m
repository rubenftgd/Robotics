function [ yy,xx ,ppx,ppy] = interpolation( varargin )
%INTERPOLATION fun��o que recebe os pontos vi�rios, o n�mero de pontos na
%traject�ria interpolada e opcionalmente  tipo de interpola��o a fazer e
%devolve a traject�ria interpolada.
%Modo 1 � o predefenido e � o pchip, o modo 2 � spline
%   Detailed explanation goes here

if nargin==2
    pathpts=varargin{1};
    mode=1;
    pts=varargin{2};
elseif nargin==3
    pathpts=varargin{1};
    mode=varargin{2};
    pts=varargin{3};
end

if mode==1
    x=pathpts(:,1);
    y=pathpts(:,2);
    t=linspace(0,1000,length(x));
    ppx=pchip(t,x);
    xx = ppval(ppx, linspace(0,1000,pts));
    ppy=pchip(t,y);
    yy = ppval(ppy, linspace(0,1000,pts));
else
    
    x=pathpts(:,1);
    y=pathpts(:,2);
    t=linspace(0,1000,length(x));
    ppx=spline(t,x);
    xx = ppval(ppx, linspace(0,1000,pts));
    ppy=spline(t,y);
    yy = ppval(ppy, linspace(0,1000,pts));
end
end

