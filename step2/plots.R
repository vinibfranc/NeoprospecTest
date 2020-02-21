# Realiza as etapas 2.1, 2.2 e 2.3 utilizando os arquivos disponibilizados na pasta 'tables'

# ETAPA 2.1: gráfico de barras com contagem absoluta das 50 bactérias mais abundantes

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("phyloseq")
BiocManager::install("ggplot2")

library(phyloseq)
library(ggplot2)

# Importa OTU table
otumat <- as.matrix(read.table("../tables/otu_table_tax_amostras.tsv", sep="\t", header=T, row.names=1))
otumat
taxmat = as.matrix(read.table("../tables/tax_table_amostras.tsv", sep="\t", header=T, row.names=1))
rownames(taxmat) <- rownames(otumat)
colnames(taxmat) <- c("Domain", "Phylum", "Class", "Order", "Family", "Genus", "Species")
taxmat

class(otumat)
class(taxmat)

OTU = otu_table(otumat, taxa_are_rows = TRUE)
TAX = tax_table(taxmat)
OTU
TAX

physeq = phyloseq(OTU, TAX)
physeq

# Os resultados dos gráficos de barra com as 50 bactérias mais abundantes podem ser visualizados no RStudio ou então na pasta 'plots'
TopNOTU_genus <- names(sort(taxa_sums(physeq), TRUE)[1:50]) 
top_50_genus   <- prune_taxa(TopNOTU_genus, physeq)
print(top_50_genus)

plot_bar(top_50_genus, fill = "Genus")

TopNOTU_species <- names(sort(taxa_sums(physeq), TRUE)[1:50]) 
top_50_species   <- prune_taxa(TopNOTU_species, physeq)
print(top_50_species)

plot_bar(top_50_species, fill = "Species")

# ETAPA 2.2: gráfico PCoA mostrando o perfil de agrupamento entre as amostras por dia após o desmame
