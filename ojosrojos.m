function [Irgb mascara]=ojosrojos(imagen,varargin)
%OJOSROJOS Corrección de ojos rojos
%
%   [I M]=OJOSROJOS(IMG,VAR) realiza la corrección del defecto de los ojos
%   rojos en IMG y devuelve la imagen corregida I y la máscara usada M.
%   Si se llama a la función sin parámetros muestra las imágenes, tanto la
%   imagen corregida como la máscara. Si se llama a la función recogiendo
%   únicamente la imagen corregida se puede añadir el parametro de entrada
%   'showmask' para que muestre la máscara que ha usado


%% Información
%   Antonio José Moya Díaz
%       Ultima actualización    22 de Junio de 2012
%   Procesado Digital de Imágenes
%   Universidad de Granada


    warning off
    
    %% Obtención de la máscara de ojos rojos
    
    I=imagen;
    % En primer lugar se convierte la imagen al espacio de color HSV
    Ih=rgb2hsv(I);
    
    % Máscara vacía para optimización del bucle
    mascara=zeros(length(I(:,1,:)),length(I(1,:,:)));

    % Detectaremos los ojos rojos como aquellos valores de la imagen que
    % posean un tono rojo y un alto valor de saturación
    
    for i=1:1:length(I(:,1,:))
        for j=1:1:length(I(1,:,:))
            if (Ih(i,j,1)>0.9 || Ih(i,j,1)<0.02) & Ih(i,j,2)>0.6
                mascara(i,j)=1;
            end
        end
    end
    
    
    %% Mejora de la máscara mediante morfología matemática
    
    % Definimos la forma que usaremos para la morfología
    se = strel('disk',2);
    
    % En primer lugar realizamos un proceso de apertura que nos borrará la
    % mayoría de los falsos positivos, en su mayoría puntos sueltos.
    aux=imopen(mascara,se);
    
    % Tras el proceso de apertura la máscara queda demasiado cerrada, por
    % lo que la dilatamos un poco esperando mejorar los resultados.
    mascara = imdilate(aux,se);
    
    % Tras la dilatación tenemos una máscara bastante decente en cuanto a
    % la aproximación del área ocupada por el ojo rojo.

    
    %% Poda de falsos positivos
    
    % Puede ocurrir que en nuestra imagen haya grandes áreas de un color
    % rojo que cumpla las condiciones anteriormente expuestas para el
    % reconocimiento del ojo rojo, tales como ropas o similares.
    % Este tipo de grandes áreas son fácilmente eliminables y vamos a
    % proceder a ello.
    
    % Etiquetamos todos los elementos conectados
    [L n]=bwlabel(mascara);
    
    % Como vamos a hacer un proceso generalista y estadístico pudiera
    % ocurrir que nuestros ojos rojos también fueran podados. Debemos de
    % evitar que esto ocurra, así que en una primera aproximación solo
    % realizaremos la poda si hay más de 2 regiones en la máscara. Si hay
    % solo dos las supondremos ojos correctamente detectados.
    if n>2
        % Extraemos propiedades de esos elementos conectados
        prop = regionprops(L);
    
        % Rastreamos todos los elementos conectados muestreando el valor de
        % sus áreas
        mxit=size(prop,1);
        areas=[];
        for i=1:mxit
            areas=[areas prop(i).Area];
        end
        
        % El criterio de la poda será el siguiente. Calcularemos las áreas
        % de todos los elementos, y estimaremos su media. Luego
        % eliminaremos aquellos elementos cuya area sea más del doble del
        % área media. 
        % Estimamentos el doble de la media un buen valor ya que si el area
        % no deseada es mucho mayor que los ojos, no pasará dicho umbral,
        % pero sin embargo, si hemos llegado a este punto debido a areas
        % pequeñas o comparables a los ojos, debemos de evitar que la poda
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


    %% Corrección del ojo rojo
    
    % Trabajamos en RGB
    Irgb=I;
    
    % Recorremos la imagen en busca de aquellos píxeles que la máscara ha
    % marcado como ojos rojos. Como método de corrección del color
    % sustituiremos el valor de la banda del rojo por un valor 'acromático'
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

