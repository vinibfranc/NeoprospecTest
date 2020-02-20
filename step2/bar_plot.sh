#!/bin/bash
set -e
set -u
set -o pipefail

### Esse script realiza as etapas 2.1 ###

# Para gerar o gráfico de barras com as bactérias mais abundantes podemos utilizar o QIIME 2
echo "Gerando gráfico de barras"
qiime taxa barplot \
  --i-table ../fqs/table.qza \
  --i-taxonomy ../results/taxonomy.qza \
  --m-metadata-file ../metadata.csv \
  --o-visualization ../results/taxa-bar-plots.qzv
echo "Você pode inspecionar o arquivo (taxa-bar-plots.qzv) gerado na pasta results utilizando o QIIME2 Viewer (https://view.qiime2.org/)"

