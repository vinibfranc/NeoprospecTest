# NeoprospecTest
Teste para vaga na Neoprospecta, incluindo etapas de bioinformática e análise de dados sobre dados de sequenciamento 16s.

## Sobre o conjunto de dados

Mais informações a respeito do conjunto de dados podem ser lidas no arquivo ```Desafio```.

## Linguagens de programação e softwares

Para as etapas 1 e 2 deste desafio foram utilizadas as seguintes linguagens de programação, softwares, ferramentas e bancos de dados:

- [ShellScript](https://www.shellscript.sh/) 
- [Trim Galore!](https://www.bioinformatics.babraham.ac.uk/projects/trim_galore/) (v0.6.0)
- [cutadapt](https://cutadapt.readthedocs.io/en/stable/) (v2.5)
- [Miniconda](https://docs.conda.io/en/latest/miniconda.html) (conda 4.8.2)
- [QIIME2](https://qiime2.org/) (q2cli version 2019.10.0)
- [GreenGenes](https://greengenes.secondgenome.com/) (v13_8)
- [Docker](https://www.docker.com/) (v18.09.8)
- [R](https://www.r-project.org/) (v3.6.1)

## Instalação 

Para executar a etapa de bioinformática, um container docker foi disponibilizado.

Para configurá-lo, vamos realizar as etapas abaixo:

1. Instale o Docker de acordo com as instruções para seu sistema operacional, seguindo a [documentação](https://docs.docker.com/install/).

2. Baixe a imagem do Docker disponibilizada no DockerHub para sua máquina numa pasta de sua preferência:

```
$ docker pull vinibfranc/neoprospecta
```

3. Rode a imagem do Docker na sua máquina, conforme a documentação para seu sistema operacional. Geralmente, conseguimos fazer isso com o comando abaixo:

```
$ docker run -i -t neoprospecta /bin/bash
```

Dentro da imagem do Docker, atualize o arquivo PATH para que todas as ferramentas estejam configuradas:

```
$ source ~/.bashrc
```

Pronto! Agora podemos seguir para a análise de bioinformática dentro do Docker.

## Etapas

### 1) Bioinformática

Dentro da imagem do Docker, o primeiro passo será acessar o diretório com os scripts da primeira etapa:

```
$ cd step1
```

Depois, garantimos que o ShellScript responsável pela trimmagem possa ser executado, rodando:

```
$ chmod +x trimming.sh
```

Feito isto, rodamos o script ```trimming.sh``` que utiliza o FASTQC para mostrar relatórios antes do controle de qualidade dentro da pasta ```fqs/report_antes```, o trim_galore para trimmar sequências com phred score >= 30 e colocar as sequências que passaram no filtro na pasta ```fqs/fqs_trimmados```, bem como gerar o relatório após a trimmagem na pasta ```fqs/report_depois```.

```
$ ./trimming.sh fqs
```

Feito o controle de qualidade, iremos utilizar o QIIME2, um software largamente utilizado para análise de dados de sequenciamento 16s. Apesar de ter sido disponibilizado um banco de dados em nível de espécie que poderia ser usado para fazer, por exemplo, um BLAST, ou utilização de outra ferramenta mais genérica de alinhamento, preferi utilizar o QIIME2, que foi desenvolvido especificamente para este fim e conta com ferramentas mais específicas para dados de amplicon.

Damos permissão ao arquivo:

```
$ chmod +x qiime2.sh
```

O script ```qiime2.sh``` irá importar os arquivos fastq que passaram pelo filtro dentro do QIIME2, executar alguns passos de pré-processamento, baixar o banco de dados de referência (GreenGenes 13_8), treinar o classificador taxonômico bayesiano do QIIME2 chamado q2-feature-classifier utilizando um agrupamento das OTUs com 99% de identidade, fazer a atribuição taxonômica para as nossas amostras e gerar a OTU table (arquivo ```results/my_tables/table.tsv```). Essa OTU table gerada parece correta, mas não contém as taxonomias reais, somente OTU IDs, então irei trabalhar nas próximas etapas com o arquivo ```tables/otu_table_tax_amostras.tsv```, disponibilizado juntamente ao desafio.

Ativamos o conda, onde o QIIME está instaladado:

```
$ conda activate qiime2-2019.10
```

Executando o script:

```
$ ./qiime2.sh
```

Os resultados vão sendo gerados nas pastas ```fqs``` e ```results```.

### 2) Análise de dados

Para a geração de análises gráficos sobre os dados de sequenciamento, iremos utilizar o R tendo como base a OTU table presente em ```tables/otu_table_tax_amostras.tsv```. Você pode acompanhar esse processo no RStudio. 

Primeiramente, instale o [RStudio](https://rstudio.com/products/rstudio/download/), instale o [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) e clone este projeto para obter os códigos e dados necessários para a análise.

```
$ git clone https://github.com/vinibfranc/NeoprospecTest
```

Abra o RStudio e navegue para a pasta que você clonou o repositório acima. Crie um novo projeto no RStudio dentro da pasta ```step2```, onde teremos o script ```plots.R```.

Este script será responsável por instalar os pacotes necessários do R, bem como plotar:

- Um gráfico de barras que mostre a contagem absoluta das 50 bactérias mais abundantes, agrupadas por tempo (dia após o desmame);
- Um gráfico de PCoA mostrando o perfil de agrupamento entre as amostras por dia após o desmame;
- Gerar uma tabela e um gráfico com as bactérias diferencialmente abundantes entre os dias de desmame.

Todos estes arquivos gerados pelo script foram salvos, assim como relatório solicitado, e também podem ser vistos na pasta ```plots```, presente dentro do repositório.

### 3) Integração e visualização com o Django

Essa etapa foi realizada no repositório https://github.com/vinibfranc/DjangOTU.