rota = fopen('rota 76.txt','r');
vetor = fscanf(rota,'%f')';
ncidades = size(vetor,2)/3;
matriz = (zeros(ncidades,3));
for i=1:1:ncidades
   y=3*i;
   x=y-1;
   ponto=y-2;
   matriz(i,1)=vetor(ponto);
   matriz(i,2)=vetor(x);
   matriz(i,3)=vetor(y);
end
distancias = zeros(ncidades);
for i=1:1:ncidades
    for j=1:1:ncidades
        if j<=i
           continue 
        end
        xd = matriz(i,2)-matriz(j,2);
        yd = matriz(i,3)-matriz(j,3);
        d  = round(sqrt(xd*xd+yd*yd));
        distancias(i,j)=d;
    end
end
writematrix(distancias,'distancias.xlsx')
