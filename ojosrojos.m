function [Irgb mascara]=ojosrojos(imagen,varargin)
%OJOSROJOS Correcci�n de ojos rojos
%
%   [I M]=OJOSROJOS(IMG,VAR) realiza la correcci�n del defecto de los ojos
%   rojos en IMG y devuelve la imagen corregida I y la m�scara usada M.
%   Si se llama a la funci�n sin par�metros muestra las im�genes, tanto la
%   imagen corregida como la m�scara. Si se llama a la funci�n recogiendo
%   �nicamente la imagen corregida se puede a�adir el parametro de entrada
%   'showmask' para que muestre la m�scara que ha usado


%% Informaci�n
%   Antonio Jos� Moya D�az
%       Ultima actualizaci�n    22 de Junio de 2012
%   Procesado Digital de Im�genes
%   Universidad de Granada


    warning off
    
    %% Obtenci�n de la m�scara de ojos rojos
    
    I=imagen;
    % En primer lugar se convierte la imagen al espacio de color HSV
    Ih=rgb2hsv(I);
    
    % M�scara vac�a para optimizaci�n del bucle
    mascara=zeros(length(I(:,1,:)),length(I(1,:,:)));

    % Detectaremos los ojos rojos como aquellos valores de la imagen que
    % posean un tono rojo y un alto valor de saturaci�n
    
    for i=1:1:length(I(:,1,:))
        for j=1:1:length(I(1,:,:))
            if (Ih(i,j,1)>0.9 || Ih(i,j,1)<0.02) & Ih(i,j,2)>0.6
                mascara(i,j)=1;
            end
        end
    end
    
    
    %% Mejora de la m�scara mediante morfolog�a matem�tica
    
    % Definimos la forma que usaremos para la morfolog�a
    se = strel('disk',2);
    
    % En primer lugar realizamos un proceso de apertura que nos borrar� la
    % mayor�a de los falsos positivos, en su mayor�a puntos sueltos.
    aux=imopen(mascara,se);
    
    % Tras el proceso de apertura la m�scara queda demasiado cerrada, por
    % lo que la dilatamos un poco esperando mejorar los resultados.
    mascara = imdilate(aux,se);
    
    % Tras la dilataci�n tenemos una m�scara bastante decente en cuanto a
    % la aproximaci�n del �rea ocupada por el ojo rojo.

    
    %% Poda de falsos positivos
    
    % Puede ocurrir que en nuestra imagen haya grandes �reas de un color
    % rojo que cumpla las condiciones anteriormente expuestas para el
    % reconocimiento del ojo rojo, tales como ropas o similares.
    % Este tipo de grandes �reas son f�cilmente eliminables y vamos a
    % proceder a ello.
    
    % Etiquetamos todos los elementos conectados
    [L n]=bwlabel(mascara);
    
    % Como vamos a hacer un proceso generalista y estad�stico pudiera
    % ocurrir que nuestros ojos rojos tambi�n fueran podados. Debemos de
    % evitar que esto ocurra, as� que en una primera aproximaci�n solo
    % realizaremos la poda si hay m�s de 2 regiones en la m�scara. Si hay
    % solo dos las supondremos ojos correctamente detectados.
    if n>2
        % Extraemos propiedades de esos elementos conectados
        prop = regionprops(L);
    
        % Rastreamos todos los elementos conectados muestreando el valor de
        % sus �reas
        mxit=size(prop,1);
        areas=[];
        for i=1:mxit
            areas=[areas prop(i).Area];
        end
        
        % El criterio de la poda ser� el siguiente. Calcularemos las �reas
        % de todos los elementos, y estimaremos su media. Luego
        % eliminaremos aquellos elementos cuya area sea m�s del doble del
        % �rea media. 
        % Estimamentos el doble de la media un buen valor ya que si el area
        % no deseada es mucho mayor que los ojos, no pasar� dicho umbral,
        % pero sin embargo, si hemos llegado a este punto debido a areas
        % peque�as o comparables a los ojos, debemos de evitar que la poda
        % elimine los ojos.
        areamedia=mean(areas);
        s=find([prop.Area]>2*areamedia);
    
        % Localizados los elementos conectados mayores que el doble de la
        % media, los eliminamos.
        for k=1:size(s,2)
            d=floor(prop(s(k)).BoundingBox);
            
            if d(2)==0
                d(2)=1;
            end
            
            if d(1)==0
                d(1)=1;
            end
            
            mascara(d(2):d(2)+d(4),d(1):d(1)+d(3))=0;
        end
    end


    %% Correcci�n del ojo rojo
    
    % Trabajamos en RGB
    Irgb=I;
    
    % Recorremos la imagen en busca de aquellos p�xeles que la m�scara ha
    % marcado como ojos rojos. Como m�todo de correcci�n del color
    % sustituiremos el valor de la banda del rojo por un valor 'acrom�tico'
    % definido como la media entre las bandas G y B para ese pixel.
    for i=1:size(I,1)
        for j=1:size(I,2)
            if mascara(i,j)==1
                Irgb(i,j,1)=(I(i,j,2)+I(i,j,3))/2;
            end
        end
    end
    
    %% Mostramos los resultados
    
    if nargout==0
        figure,imshow(Irgb),title('Imagen corregida');
        figure,imshow(mascara),title('Mascara usada');
    else if nargout<2 && strcmp(varargin,'showmask')
        figure,imshow(mascara),title('Mascara usada');
        end
    end

end

