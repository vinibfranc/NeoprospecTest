# Realiza as etapas 2.1, 2.2 e 2.3 utilizando os arquivos disponibilizados na pasta 'tables'

### ETAPA 2.1: gráfico de barras com contagem absoluta das 50 bactérias mais abundantes ###

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("phyloseq")
BiocManager::install("ggplot2")

library(phyloseq)
library(ggplot2)

# Importa OTU table
otumat <- as.matrix(read.table("../tables/otu_table_tax_amostras.tsv", sep="\t", header=T, row.names=1))
taxmat = as.matrix(read.table("../tables/tax_table_amostras.tsv", sep="\t", header=T, row.names=1))
rownames(taxmat) <- rownames(otumat)
colnames(taxmat) <- c("Domain", "Phylum", "Class", "Order", "Family", "Genus", "Species")
samples_df <- read.table("../metadata.csv", sep="\t", header=T)

row.names(samples_df) <- samples_df$sample

class(otumat)
class(taxmat)
class(samples_df)

#row.names(samples_df) <- samples_df$SampleID

OTU <- otu_table(otumat, taxa_are_rows = TRUE)
TAX <- tax_table(taxmat)
samples <- sample_data(samples_df)
OTU
TAX
samples

physeq = phyloseq(OTU, TAX, samples)
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

### ETAPA 2.2: gráfico PCoA mostrando o perfil de agrupamento entre as amostras por dia após o desmame ###

# Plota alfa-diversidade
plot_richness(physeq, measures=c("Chao1", "Shannon"))

# Plota NMDS (escalonamento multidimensional)
physeq.ord <- ordinate(physeq, "NMDS", "bray")
plot_ordination(physeq, physeq.ord, type="taxa", color="Genus", shape= "Division", 
                title="OTUs")

# Plota PCoA
# Taxa de aglomerados no nível de gênero (combina todos com o mesmo nome) e remove todos os taxa sem atribuição de nível de gênero
length(get_taxa_unique(physeq, taxonomic.rank = "Genus"))
physeq_2 <- tax_glom(physeq, "Genus", NArm = TRUE)
physeq_2
# Quantos "reads" isso nos deixa
sum(colSums(otu_table(physeq_2)))

# Agora vamos filtrar amostras (outliers e amostras de baixo desempenho)
logt  <- transform_sample_counts(physeq_2, function(x) log(1 + x) )
out.pcoa.logt <- ordinate(logt, method = "PCoA", distance = "bray")
evals <- out.pcoa.logt$values$Eigenvalues

sample_variables(physeq)
# Plota PCoA das amostras
plot_ordination(logt, out.pcoa.logt, color="sample")

### ETAPA 2.3: Usar alguma métrica que mostre as bactérias diferencialmente abundantes entre os dias de desmame ###
BiocManager::install("DESeq2")
library(DESeq2)

# Importa os dados no DESeq2
sample_data(physeq)$time <- as.factor(sample_data(physeq)$time)
ds <- phyloseq_to_deseq2(physeq, ~ time)
ds <- DESeq(ds)

# Filtra OTUs usando o cuttoff do False Discovery Rate (FDR) de 0.01
# Compara bactérias diferencialmente abundantes poucos dias após o desmame (dwp < 10 -> Early) e vários dias (dwp > 140 -> Late)
alpha <- 0.01
res <- results(ds, contrast=c("time", "Early", "Late"), alpha=alpha)
res <- res[order(res$padj, na.last=NA), ]
res_sig
# Obtem somente aqueles com p-value ajustado < 0.1
res_sig <- res[(res$padj < alpha), ]
res_sig <- subset(res_sig, padj < 0.1)
# Ordena por log2FoldChange
res_ordered <- res_sig[order(res_sig$log2FoldChange),]
# O resultado (tabela) apresenta base means entre as amostras, log2 fold change, erro padrão, teste estatístico, p-values and p-values ajustados.
res_ordered

# Salva tabela de resultado com bactérias diferencialmente abundantes em arquivo na pasta plots
write.csv(as.data.frame(res_ordered), 
          file="../plots/deseq2_diff_abundance.csv")

# Plota espécies vs log2FC plot das espécies mais diferencialmente abundantes
res_sig = cbind(as(res_sig, "data.frame"), as(tax_table(physeq)[rownames(res_sig), ], "matrix"))
ggplot(res_sig, aes(x=Species, y=log2FoldChange, color=Species)) +
  geom_jitter(size=3, width = 0.2) +
  theme(axis.text.x = element_text(angle = -90, hjust = 0, vjust=0.5))
