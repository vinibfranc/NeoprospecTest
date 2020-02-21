# NeoprospecTest
Teste para vaga na Neoprospecta, incluindo etapas de bioinformática, análise de dados e visualização com o framework Django.

## Sobre o conjunto de dados

Mais informações a respeito do conjunto de dados podem ser lidas no arquivo Desafio.

## Linguagens de programação e softwares

Para as etapas 1 e 2 deste desafio foram utilizadas as seguintes linguagens de programação, softwares, ferramentas e bancos de dados:

- [ShellScript](https://www.shellscript.sh/) 
- [R](https://www.r-project.org/) (v3.6.1)
- [Trim Galore!](https://www.bioinformatics.babraham.ac.uk/projects/trim_galore/) (v0.6.0)
- [cutadapt](https://cutadapt.readthedocs.io/en/stable/) (v2.5)
- [Miniconda](https://docs.conda.io/en/latest/miniconda.html) (conda 4.8.2)
- [QIIME2](https://qiime2.org/) (q2cli version 2019.10.0)
- [GreenGenes](https://greengenes.secondgenome.com/) (v13_8)
- [Docker](https://www.docker.com/) (v18.09.8)

Para executar a etapa de bioinformática, um container docker foi disponibilizado.

Para configurá-lo, vamos realizar as etapas abaixo:

1. Instale o Docker de acordo com as instruções para seu sistema operacional, seguinte a [documentação](https://docs.docker.com/install/).

2. 


## Etapas

### 1) Bioinformática

O objetivo deste desafio será o de gerar um script que contemple os seguintes steps:
1.1) Efetuar trimagem dos dados, por qualidade, usando algum trimador de sua preferência;

1.2) Gerar reports da qualidade PHRED antes e após trimagem dos dados;

1.3) Fazer identificação taxonômicas das sequências que passaram pelo filtro de qualidade usando um banco de referência e um programa de sua escolha;

1.4) Gerar uma OTU table, onde as linhas serão taxonomias e as colunas os nomes das amostras. A intersecção de colunas e linhas devem mostrar as contagens da taxonomia na amostra;

1.5) Estes steps devem estar em um container Docker, onde o código deve ser comitado em uma conta do GitHub. Construa o requirements.txt e demais instruções para instalação e execução automática do pipeline. 


2) Competência básica para análise de dados: o objetivo deste desafio será o de gerar análises gráficas (descritivas e estatísticas) a partir de dados de sequenciamento (recomendado utilizar a linguagem R).
2.1) Plotar um gráfico de barras que mostre a contagem absoluta das 50 bactérias mais abundantes, agrupadas por tempo (dia após o desmame);

2.2) Plotar um gráfico de PCoA mostrando o perfil de agrupamento entre as amostras por dia após o desmame;

2.3) Usar alguma métrica que mostre as bactérias diferencialmente abundantes entre os dias de desmame (edegR ou DESeq2, por exemplo). Em um arquivo (PDF, HTML, DOC ou similar), descreva os resultados obtidos e explique quais foram os critérios de escolha dos métodos analíticos usados.
