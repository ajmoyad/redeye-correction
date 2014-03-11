%% Demo ojos rojos
clear, clc, close all


O1=imread('test/ojo1.jpg');
O2=imread('test/ojo2.jpg');
O3=imread('test/ojo3.jpg');
O4=imread('test/ojo4.jpg');
O5=imread('test/ojo5.jpg');
O6=imread('test/ojo6.jpg');
O7=imread('test/ojo7.jpg');
O8=imread('test/ojo8.jpg');

[I1 m1]=ojosrojos(O1);
figure(1),
subplot(1,3,1),imshow(O1),title('Imagen original');
subplot(1,3,2),imshow(m1),title('Máscara usada');
subplot(1,3,3),imshow(I1),title('Imagen corregida');

[I2 m2]=ojosrojos(O2);
figure(2),
subplot(1,3,1),imshow(O2),title('Imagen original');
subplot(1,3,2),imshow(m2),title('Máscara usada');
subplot(1,3,3),imshow(I2),title('Imagen corregida');

[I3 m3]=ojosrojos(O3);
figure(3),
subplot(1,3,1),imshow(O3),title('Imagen original');
subplot(1,3,2),imshow(m3),title('Máscara usada');
subplot(1,3,3),imshow(I3),title('Imagen corregida');

[I4 m4]=ojosrojos(O4);
figure(4),
subplot(1,3,1),imshow(O4),title('Imagen original');
subplot(1,3,2),imshow(m4),title('Máscara usada');
subplot(1,3,3),imshow(I4),title('Imagen corregida');

[I5 m5]=ojosrojos(O5);
figure(5),
subplot(1,3,1),imshow(O5),title('Imagen original');
subplot(1,3,2),imshow(m5),title('Máscara usada');
subplot(1,3,3),imshow(I5),title('Imagen corregida');

[I6 m6]=ojosrojos(O6);
figure(6),
subplot(1,3,1),imshow(O6),title('Imagen original');
subplot(1,3,2),imshow(m6),title('Máscara usada');
subplot(1,3,3),imshow(I6),title('Imagen corregida');

[I7 m7]=ojosrojos(O7);
figure(7),
subplot(1,3,1),imshow(O7),title('Imagen original');
subplot(1,3,2),imshow(m7),title('Máscara usada');
subplot(1,3,3),imshow(I7),title('Imagen corregida');

[I8 m8]=ojosrojos(O8);
figure(8),
subplot(1,3,1),imshow(O8),title('Imagen original');
subplot(1,3,2),imshow(m8),title('Máscara usada');
subplot(1,3,3),imshow(I8),title('Imagen corregida');


%% Cálculo de los falsos positivos

% En la batería de imágenes presentadas solo se han encontrado falsos
% positivos en las imágenes 1 y 6. Ya que este cálculo objetivo de un
% indice de calidad no pretende ser automático sino, en la medida de lo
% posible, preciso, vamos a estimar las areas indebidamente afectadas a
% mano.

% Se debe seleccionar un area que recoja todas las zonas que la máscara ha
% detectado pero que no corresponden a ojos rojos, y de una sola vez.

% figure(9)
% subplot(1,2,1),imshow(O1);
% subplot(1,2,2),B1=roipoly(m1);
% 
% figure(10)
% subplot(1,2,1),imshow(O6);
% subplot(1,2,2),B6=roipoly(m6);
% 
% 
% % Si ahora intersecamos con la máscara de los ojos, nos quedará una máscara
% % con todos los falsos positivos y sin ojos.
% B1=B1.*m1;
% B6=B6.*m6;
% save('falsopos','B1','B6');

% La selección de las áreas se realizó una vez, y se guardaron las máscaras
% resultantes. Si se desea probar, descomentar las líneas anteriores, y
% commentar, de entre las que siguen, las que correspondan.

load('falsopos.mat');

figure(11),
subplot(1,2,1),imshow(m1),title('Máscara estimada por la función');
subplot(1,2,2),imshow(B1),title('Máscara de las zonas no deseadas');

figure(12),
subplot(1,2,1),imshow(m6),title('Máscara estimada por la función');
subplot(1,2,2),imshow(B6),title('Máscara de las zonas no deseadas');

area1total=sum(m1(:));
area1error=sum(B1(:));

area6total=sum(m6(:));
area6error=sum(B6(:));

% Indice:
% Propongo el siguiente índice:
% Calculamos el porcentaje de area que representan los ojos sobre el  total
% de la imagen. Px_O
% Calculamos el porcentaje que representa el area errónea sobre el total de
% la imagen. Px_E
% Dividiendo el error entre los ojos, Px_E/Px_O obtendremos una medida de
% la proporción de error con respecto a los ojos de tal manera que:
% - Si no existe error alguno, el índice valdrá 0. Corrección 'perfecta'
% - Si el area erronea es menor que el area de los ojos el índice estará
% entre 0 y 1. Será una corrección 'buena'.
% - Si el area errónea es mayor que el área de los ojos el índice será
% mayor que 1 y la corrección será peor cuanto mayor sea el índice.

P1_O=(area1total-area1error)/(size(I1,1)*size(I1,2));
P1_E=(area1error)/(size(I1,1)*size(I1,2));

P6_O=(area6total-area6error)/(size(I6,1)*size(I6,2));
P6_E=(area6error)/(size(I6,1)*size(I6,2));

indice_img1=P1_E/P1_O;
indice_img6=P6_E/P6_O;

% Notar que así definidos los índices habría un pequeñísimo fleco suelto.
% Estamos considerando los áreas totales pero no la dispersión de éstos.
% Así pues, una imagen con muchas áreas erróneas, pero muy pequeñas, podría
% presentar un índice de error alto o muy alto pero, perceptualmente al
% observar la imagen, no ser capaces de apreciar ese error.





%% AHORA FALTAN LOS FALSOS NEGATIVOS

% Para calcular los falsos negativos vamos a considerar aquellas imagenes
% en las que, perceptualmente, podemos apreciar que el resultado no es todo
% lo bueno que desearíamos. Vamos a calcular el area deseada a mano y luego
% vamos a realizar una comparación similar a la que aplicamos para los
% falsos positivos.

% L=roipoly(O1);
% R=roipoly(O1);
% 
% C1=L+R;
% figure,imshow(C1);
% 
% L=roipoly(O2);
% R=roipoly(O2);
% 
% C2=L+R;
% figure,imshow(C2);
% 
% C4=roipoly(O4);
% figure,imshow(C4);
% 
% save('falsosneg','C1','C2','C4')

load('falsosneg.mat');

% Intersecamos las máscaras
D1=C1.*(1-m1);
D2=C2.*(1-m2);
D4=C4.*(1-m4);

figure,imshow(D1)
figure,imshow(D2)
figure,imshow(D4)


area1total=sum(m1(:));
area1error=sum(D1(:));

area2total=sum(m2(:));
area2error=sum(D2(:));

area4total=sum(m4(:));
area4error=sum(D4(:));

P1_O=(area1total-area1error)/(size(I1,1)*size(I1,2));
P1_E=(area1error)/(size(I1,1)*size(I1,2));

P2_O=(area2total-area2error)/(size(I2,1)*size(I2,2));
P2_E=(area2error)/(size(I2,1)*size(I2,2));

P4_O=(area4total-area4error)/(size(I4,1)*size(I4,2));
P4_E=(area4error)/(size(I4,1)*size(I4,2));

indice_img1=P1_E/P1_O;
indice_img2=P2_E/P2_O;
indice_img4=P4_E/P4_O;




