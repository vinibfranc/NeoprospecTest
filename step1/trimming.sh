#!/bin/bash
set -e
set -u
set -o pipefail

# UTILIZAÇÃO: ./step1.sh <$1>
# $1: pasta com os arquivos para fazer o controle de qualidade

# Vai para a pasta especifica a partir da raiz do repositório
cd ../$1

# Cria pasta para colocar relatórios antes da trimmagem
mkdir -p report_antes/

# Gera relatório do FASTQC antes de trimmagem para todos os arquivos da pasta
fastqc *.fastq -o report_antes -t 4

# Cria pasta para colocar relatórios depois da trimmagem
mkdir -p report_depois/

# Cria pasta para colocar reads que passaram no controle de qualidade
mkdir -p fqs_trimmados/

# Mantem reads com phred score >=30 para todos os arquivos da pasta
for file in *.fastq
do
    trim_galore --quality 30 --phred33 --output_dir fqs_trimmados $file
done

cd fqs_trimmados
# Gera relatório depois da trimmagem para todos os arquivos da pasta
fastqc *.fq -o ../report_depois -t 4
