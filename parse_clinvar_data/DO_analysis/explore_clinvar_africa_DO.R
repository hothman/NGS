library(DOSE)
library(aliases2entrez)
library(ontologyIndex)
library(wordcloud)
library(tm)
library(RColorBrewer)
library(tidyverse)


clinvar_by_africans <- read.csv("../clinVar_genes_byAfricans.csv")

entrez_gene_ids <- c("10481", "8405")
gene_symbols <- as.character(unlist(gene_symbols))

# udate the gene list correspondance, If theere is a problem with the server
#you may get an error, in such case, try to run the command again
HGNC <- aliases2entrez::update_symbols()

# getting ENTREZ IDs from gene symbols 
gene2entrez_list <- aliases2entrez::convert_symbols(gene_symbols, HGNC)
gene2entrez_list <- as.character(unlist( gene2entrez_list["entrezID"]) ) 

DO_enriched_terms <- DOSE::enrichDO( gene2entrez_list)

DOSE::enrichResult(DO_enriched_terms)

Ontology_mapping <-setReadable(DO_enriched_terms, 'org.Hs.eg.db')

write.csv(Ontology_description, "DO_terms.csv")

## Disease ontology hierachy exploration
# The subsequent snippet is used to extract 
do <- get_ontology("doid.obo")

ontology_IDs <- Ontology_mapping$ID

# A place holders for the upper classes of DO terms 
placeholder1 <- replicate( length(ontology_IDs), "" )
placeholder2 <- replicate( length(ontology_IDs), "" )

for (i in 1:length(ontology_IDs)) {
  do_ancestors <- get_term_property(ontology=do, property="ancestors", term=ontology_IDs[i] , as_names=TRUE)
  placeholder1[i] <- do_ancestors[2]   # first classes in the hierarchy tree, root is 1
  placeholder2[i] <- do_ancestors[3]   # second classes in the hierarchy tree 
}

tb<-table(placeholder2)
cloud_fig  <- wordcloud(words = names(tb), as.numeric(tb), colors=brewer.pal(15, "Set1"), random.order=F)

data.frame(placeholder1) %>% group_by(placeholder1) %>% count()
