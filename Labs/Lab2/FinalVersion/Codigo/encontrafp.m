function [ point ] = encontrafp( fp,pt )
%ENCONTRAFP Fun??o que recebe a estrutura que guarda os free_points e um
%ponto e devolve o free_point que o representa.
%   Detailed explanation goes here

i=1;
found=0;
while i<=length(fp)&&~found
    if fp(i).freepoint(1)==pt(1) && fp(i).freepoint(2)==pt(2)
        point=fp(i);
        found=1;
    end
    i=i+1;
end

end

