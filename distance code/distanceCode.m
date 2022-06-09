clear variables
clc

tic
m = readmatrix('distancias.xlsx');
ncidades = size(m,1);
%geração da população inicial
populacao_inicial = zeros(100,ncidades);
for i=1:1:100
   populacao_inicial(i,1:ncidades) = randperm(ncidades); 
end
populacao = populacao_inicial;

melhores_valores = zeros(2,500);
melhores_solucoes = zeros(500,ncidades);
for g=1:1:500
    g
    %avaliação
    custos = zeros(1,100);
    for i=1:1:100
        d = 0;
        for j=1:1:ncidades-1
            a = populacao(i,j);
            b = populacao(i,j+1);
            d = d + m(min(a,b),max(a,b));
        end
        inicial = populacao(i,1);
        final = populacao(i,ncidades);
        d = d + m(min(inicial,final),max(inicial,final));
        custos(i) = d;
    end
    %melhores_valores(g) = min(custos);
    [melhores_valores(2,g),melhores_valores(1,g)] = min(custos);
    melhores_solucoes(g,:) = populacao(melhores_valores(1,g),:); 
    
    %critério de parada
    if g==500
        break
    end

    %seleção
    casais = zeros(50,2);
    for j=1:1:2
        for i=1:1:50
           torneio = zeros(5,2);
           torneio(1:5,1)=randperm(100,5);
           torneio(1:5,2)=custos(torneio(1:5,1));
           [M,I] = min(torneio(1:5,2));
           casais(i,j)=torneio(I);
        end
    end

    %recombinação
    filhos = zeros(100,ncidades);
    for r=2:2:100
        pais = [populacao(casais(r/2,1),1:ncidades);populacao(casais(r/2,2),1:ncidades)];
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
grafico = plot(melhores_valores(2,:));
xlabel('geração');
ylabel('distância (m)');
%ylim([105000 400000]);
saveas(grafico,'grafico.png');
[menor_custo,melhor_geracao] = min(melhores_valores(2,:));
melhor_solucao = melhores_solucoes(melhor_geracao,:);
tempo = toc
arquivo = fopen('relatório.txt','w');
fprintf(arquivo,'Relatório da execução do algoritmo\n\n');
fprintf(arquivo,'Geração com o melhor resultado encontrado = %d\n',melhor_geracao);
fprintf(arquivo,'Melhor solução encontrada = %s\n',num2str(melhor_solucao(:).'));
fprintf(arquivo,'Custo da melhor solução = %d\n',menor_custo);
fprintf(arquivo,'Tempo de execução do algoritmo = %2.4fs\n',tempo);
fclose(arquivo);
menor_custo






































