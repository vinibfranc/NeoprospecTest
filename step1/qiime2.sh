#!/bin/bash
set -e
set -u
set -o pipefail

# UTILIZAÇÃO: ./qiime2.sh

### Esse script realiza as etapas 1.3 e 1.4 do desafio ###

##### Necessário ativar o env do QIIME2 antes de rodar o script #####
# $ conda activate qiime2-2019.10

echo "Inspecionando o arquivo de metadados"
qiime tools inspect-metadata ../metadata.csv

echo "Importando os reads como um qiime2 artifact"
qiime tools import --type 'SampleData[SequencesWithQuality]' \
  --input-path manifest \
  --output-path ../fqs/fqs_qiime2.qza \
  --input-format SingleEndFastqManifestPhred33V2

echo "Executando Dada2 para discriminar melhor entre a verdadeira diversidade de sequências e os erros de sequenciamento"
qiime dada2 denoise-single \
	--i-demultiplexed-seqs ../fqs/fqs_qiime2.qza \
  --p-trunc-len 0 \
  --o-table ../fqs/table.qza \
  --o-representative-sequences ../fqs/rep-seqs-dada2.qza \
  --o-denoising-stats ../fqs/stats.qza

echo "Sumarizando os resultados"
echo "Os arquivos gerados abaixo (table.qzv e rep-seqs.qzv) podem ser visualizados no QIIME2 viewer (https://view.qiime2.org/)"
qiime feature-table summarize \
  --i-table ../fqs/table.qza \
  --o-visualization ../fqs/table.qzv \
  --m-sample-metadata-file ../metadata.csv

qiime feature-table tabulate-seqs \
  --i-data ../fqs/rep-seqs-dada2.qza \
  --o-visualization ../fqs/rep-seqs.qzv

# Cria pasta para colocar o banco de dados de referência GreenGenes
mkdir -p ../my_ref_db

echo "Baixando banco de dados de referência de 16s rRNA (GreenGenes)"
wget -O "../my_ref_db/gg_13_8_otus.tar.gz" "ftp://greengenes.microbio.me/greengenes_release/gg_13_5/gg_13_8_otus.tar.gz"
cd ../my_ref_db
tar xvzf gg_13_8_otus.tar.gz

mkdir -p ../results

echo "Importando os arquivos de OTUs e taxonomias para treinar o classificador"
qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path gg_13_8_otus/rep_set/99_otus.fasta \
  --output-path ../results/99_otus.qza

qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --input-format HeaderlessTSVTaxonomyFormat \
  --input-path gg_13_8_otus/taxonomy/99_otu_taxonomy.txt \
  --output-path ../results/ref-taxonomy.qza

cd ../step1

echo "Treinando o classificador q2-feature-classifier do QIIME2"
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads ../results/99_otus.qza \
  --i-reference-taxonomy ../results/ref-taxonomy.qza \
  --o-classifier ../results/classifier.qza

echo "Executando a atribuição taxonômica dos reads usando o q2-feature-classifier (testa o classificador)"
qiime feature-classifier classify-sklearn \
  --i-classifier ../results/classifier.qza \
  --i-reads ../fqs/rep-seqs-dada2.qza \
  --o-classification ../results/taxonomy.qza

echo "Gerando arquivo (taxonomy.qzv), que pode ser visualizado no QIIME2 viewer (https://view.qiime2.org/)"
qiime metadata tabulate \
  --m-input-file ../results/taxonomy.qza \
  --o-visualization ../results/taxonomy.qzv

echo "Exportando arquivo biom"
mkdir -p ../results/my_tables
qiime tools export \
  --input-path ../fqs/table.qza \
  --output-path ../results/my_tables/

qiime tools export \
  --input-path ../results/taxonomy.qza \
  --output-path ../results/my_tables/

echo "Converte arquivo biom para tsv... Ainda sem taxonomias!"
biom convert -i ../results/my_tables/feature-table.biom -o ../results/my_tables/table.tsv --to-tsv

# Modificar cabeçalho do arquivo taxonomy.tsv antes de rodar:
# Novo cabeçalho: #OTUID taxonomy	confidence 
# biom add-metadata -i ../results/my_tables/feature-table.biom -o ../results/my_tables/table_w_taxonomy.biom --observation-metadata-fp ../results/my_tables/taxonomy_orig.tsv --observation-header OTUID,taxonomy,confidence

# biom convert -i ../results/my_tables/table_w_taxonomy.biom -o ../results/my_tables/table_w_taxonomy.tsv --to-tsv

# Atribui nomes científicos das espécies
# qiime taxa collapse \
#   --i-table ../fqs/table.qza \
#   --i-taxonomy ../results/taxonomy.qza \
#   --p-level 6 \
#   --o-collapsed-table ../results/feature-table-genus.qza

# qiime metadata tabulate \
#   --m-input-file ../results/taxonomy.qza \
#   --o-visualization ../results/taxonomy_2.qzv