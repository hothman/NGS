library(circlize)
library(tidyverse)
# initialize the circular graph 
setwd("/home/houcemeddine/BILIM/ADME_PGx/novel_variants_adme/circular_plot")

unique_var <- read.csv("./new_data/unique_novel_by_group_extended.csv")
links <- read_csv('.new_data/links_core_genes_4circos_extended.csv')

len <- length(unique_var$groups)
y_coordinates <- rep(-25, len)

unique_var$ycoor <- y_coordinates

min_ax <- 1
max_ax <- max(unique_var$index)

##################################
# plotting THE CIRCULAR PLOT
##################################

#### Plotting external tracks (by group color)

circos.par("track.height" = 0.05, track.margin = c(0.01, 0.05) )

circos.initialize(factors = unique_var$groups, x = unique_var$index, xlim = c(min_ax, max_ax))

circos.track(factors = unique_var$groups, y = unique_var$index , bg.col= c("#2078b380", "#ff000080", "#00800080", "#00000080"), 
             panel.fun = function(x, y) {
             }, bg.border = NA)

#########################################################
# Plotting coordinates axis and positions of unique snps
#########################################################
circos.track(factors = unique_var$groups, y =unique_var$index, 
             panel.fun = function(x, y) {
               circos.axis(minor.ticks = 1 , labels.cex =0.5 , col = "#6f6f6fff", labels.col = "#6f6f6fff" )
             },  bg.border = NA)


circos.trackPoints(unique_var$groups, unique_var$index , c(unique_var$ycoor) , 
                   , col = c("#2078b380", "#ff000080", "#00800080", "#00000080") , pch = 20, cex = 0.4)

##############################################################
# draw links 
##############################################################
length_links <- length(links$lower)
alpha_vec <- seq(0.0001, 1, length.out = length_links)
links[["alpha"]] <- rev(alpha_vec)

for(i in 1:nrow(links)) {
  donor <- links[i,3]
  acceptor <- links[i,4]
  lower <- as.integer( links[i,1] )
  upper <- as.integer( links[i,2] )
  alpha <- as.numeric(links[i,5] )
  if( (donor == "G1"  &  acceptor == "G2") | donor == "G2"  &  acceptor == "G1"  ) {color <- "#43ab92" }
  if( (donor == "G1"  &  acceptor == "G4") | donor == "G4"  &  acceptor == "G1"  ) {color <- "#f75f00" }
  if( (donor == "G1"  &  acceptor == "G5") | donor == "G5"  &  acceptor == "G1"  ) {color <- "#c93838" }
  if( (donor == "G2"  &  acceptor == "G4") | donor == "G4"  &  acceptor == "G2"  ) {color <- "#512c62" }
  if( (donor == "G2"  &  acceptor == "G5") | donor == "G5"  &  acceptor == "G2"  ) {color <- "#93a7acff" }
  if( (donor == "G4"  &  acceptor == "G5") | donor == "G5"  &  acceptor == "G4"  ) {color <- "#d5e5ffff" }
  
  # get rgb
  rgb_color <- as.vector( col2rgb( color )  ) 
  hex_color <- rgb(red=rgb_color[1]/255, green=rgb_color[2]/255, blue=rgb_color[3]/255, alpha=alpha ) 
  circos.link(toString(donor), c(lower, upper),  toString(acceptor),  c(lower, upper), col = hex_color)
  
  
}

circos.clear()





