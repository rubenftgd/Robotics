function [ mapout ] = fechasalas( mapa,p0,pf )

% Esta fun��o faz um pr�-processamento do mapa e veda o acesso ao robot de
% salas que n�o v�o ser utilizadas durante o procedimento, de forma a
% melhorar a efici�ncia do algoritmo e evitar trabalho desnecess�rio.

mapout=mapa;

for i=6:634
    for j=6:634
        if mapa(i,j)==0
            mapout(i-5:i+5,j-5:j+5)=zeros(11,11);
        end
    end
end


end

