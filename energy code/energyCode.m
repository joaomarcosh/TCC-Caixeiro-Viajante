clear variables
clc

tic
geracoes = 500;
distancias = readmatrix('distancias.xlsx');
velocidades = readmatrix('velocidades.xlsx');
alturas = readmatrix('alturas.xlsx');
m = 2170; %kg
accel = 6; %m/s
G = 9.81;
Cr = 0.0065;
Cd = 0.24;
p = 1.2;
SA = 0.58;
ncidades = size(distancias,1);
%geração da população inicial
populacao_inicial = zeros(100,ncidades);
for i=1:1:100
   populacao_inicial(i,1:ncidades) = randperm(ncidades); 
end
populacao = populacao_inicial;

melhores_valores = zeros(3,geracoes);
melhores_solucoes = zeros(geracoes,ncidades);
for g=1:1:geracoes
    %avaliação
    custos = zeros(2,100);
    for i=1:1:100
        d = 0;
        vi = 0;
        energia = 0;
        for j=1:1:ncidades-1
            from = populacao(i,j);
            to = populacao(i,j+1);
            dd = distancias(min(from,to),max(from,to));
            d = d + dd;
            H = asin((alturas(to)-alturas(from))/(dd));
            vf = velocidades(min(from,to),max(from,to));
            if (vf < vi)
                ddd = (vi^2-vf^2)/(2*accel);
                em = ((m*-accel*ddd) + (m*G*ddd*sin(H)) + (m*G*Cr*ddd*cos(H)) ...
                    + (0.5*Cd*SA*p*ddd*(vi^2+(vf^2-vi^2)/2)))/3600;
                em = em + ((m*G*(dd-ddd)*sin(H)) + (m*G*Cr*(dd-ddd)*cos(H)) ...
                    + (0.5*Cd*SA*p*(dd-ddd)*(vi^2+(vf^2-vi^2)/2)))/3600;
            elseif (vf > vi)
                ddd = (vf^2-vi^2)/(2*accel);
                em = ((m*accel*ddd) + (m*G*ddd*sin(H)) + (m*G*Cr*ddd*cos(H)) ...
                    + (0.5*Cd*SA*p*ddd*(vi^2+(vf^2-vi^2)/2)))/3600;
                em = em + ((m*G*(dd-ddd)*sin(H)) + (m*G*Cr*(dd-ddd)*cos(H)) ...
                    + (0.5*Cd*SA*p*(dd-ddd)*(vi^2+(vf^2-vi^2)/2)))/3600;
            else
                em = ((m*G*dd*sind(H)) + (m*G*Cr*dd*cosd(H)) ...
                    + (0.5*Cd*SA*p*dd*(vi^2+(vf^2-vi^2)/2)))/3600;
            end
            energia = energia + em;
            vi = vf;
        end
        inicial = populacao(i,1);
        final = populacao(i,ncidades);
        d = d + distancias(min(inicial,final),max(inicial,final));
        H = asin((alturas(inicial)-alturas(final))/(dd));
        vf = velocidades(min(inicial,final),max(inicial,final));
        if (vf < vi)
            ddd = (vi^2-vf^2)/(2*accel);
            em = ((m*-accel*ddd) + (m*G*ddd*sin(H)) + (m*G*Cr*ddd*cos(H)) ...
                + (0.5*Cd*SA*p*ddd*(vi^2+(vf^2-vi^2)/2)))/3600;
            em = em + ((m*G*(dd-ddd)*sin(H)) + (m*G*Cr*(dd-ddd)*cos(H)) ...
                + (0.5*Cd*SA*p*(dd-ddd)*(vi^2+(vf^2-vi^2)/2)))/3600;
        elseif (vf > vi)
            ddd = (vf^2-vi^2)/(2*accel);
            em = ((m*accel*ddd) + (m*G*ddd*sin(H)) + (m*G*Cr*ddd*cos(H)) ...
                + (0.5*Cd*SA*p*ddd*(vi^2+(vf^2-vi^2)/2)))/3600;
            em = em + ((m*G*(dd-ddd)*sin(H)) + (m*G*Cr*(dd-ddd)*cos(H)) ...
                + (0.5*Cd*SA*p*(dd-ddd)*(vi^2+(vf^2-vi^2)/2)))/3600;
        else
            em = ((m*G*dd*sind(H)) + (m*G*Cr*dd*cosd(H)) ...
                + (0.5*Cd*SA*p*dd*(vi^2+(vf^2-vi^2)/2)))/3600;
        end
        energia = energia + em;
        custos(1,i) = abs(d);
        custos(2,i) = energia;
    end
    [melhores_valores(2,g),melhores_valores(1,g)] = min(custos(1,:));
    melhores_valores(3,g) = min(custos(2,:));
    melhores_solucoes(g,:) = populacao(melhores_valores(1,g),:); 
    
    %critério de parada
    if g==geracoes
        break
    end

    %seleção
    casais = zeros(50,2);
    for j=1:1:2
        for i=1:1:50
           torneio = zeros(5,2);
           torneio(1:5,1)=randperm(100,5);
           torneio(1:5,2)=custos(2,torneio(1:5,1));
           [M,I] = min(torneio(1:5,2));
           casais(i,j)=torneio(I);
        end
    end

    %recombinação
    filhos = zeros(100,ncidades);
    for r=2:2:100
        pais = [populacao(casais(r/2,1),1:ncidades); ...
            populacao(casais(r/2,2),1:ncidades)];
        filhos(r-1,round(ncidades/2):ncidades)=pais(1,round(ncidades/2):ncidades);
        filhos(r,round(ncidades/2):ncidades)=pais(2,round(ncidades/2):ncidades);
        for j=1:-1:0
            d=1;
            for i=1:1:ncidades
                if ismember(pais(1+j,i),pais(2-j,round(ncidades/2):ncidades))
                    continue
                end
                filhos(r-j,d)=pais(1+j,i);
                d=d+1;
            end
        end
    end

    %mutação
    posicao = zeros(1,2);
    valor = zeros(1,2);
    for i=1:1:100
        if randi(100) < 6
            posicao(1:2) = randperm(ncidades,2);
            valor(1) = filhos(i,posicao(1));
            valor(2) = filhos(i,posicao(2));
            filhos(i,posicao(1)) = valor(2);
            filhos(i,posicao(2)) = valor(1);
        end
    end

    %substituição
    populacao = filhos;
end

writematrix(melhores_solucoes,'melhores soluções.xlsx');
grafico = plot(melhores_valores(3,:));
xlabel('geração');
ylabel('custo energético (Wh)');
saveas(grafico,'grafico2.png');
[menor_distancia,menor_geracao] = min(melhores_valores(2,:));
[menor_custo,melhor_geracao] = min(melhores_valores(3,:));
melhor_solucao = melhores_solucoes(melhor_geracao,:);
tempo = toc
arquivo = fopen('relatório2.txt','w');
fprintf(arquivo,'Relatório da execução do algoritmo\n\n');
fprintf(arquivo,'Tempo de execução do algoritmo = %2.4fs\n',tempo);
fprintf(arquivo,'Melhor solução encontrada = %s\n',num2str(melhor_solucao(:).'));
fprintf(arquivo,'Geração com o menor custo encontrado = %d\n',melhor_geracao);
fprintf(arquivo,'Custo = %d\n',menor_custo);
fprintf(arquivo,'Distância = %d\n',melhores_valores(2,melhor_geracao));
fprintf(arquivo,'Geração com a menor distância encontrada = %d\n',menor_geracao);
fprintf(arquivo,'Custo = %d\n',melhores_valores(3,menor_geracao));
fprintf(arquivo,'Distância = %d\n',menor_distancia);
fclose(arquivo);







































