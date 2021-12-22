# following tutorial from Jackie Zorz https://jkzorz.github.io/2019/06/05/Bubble-plots.html

library(ggplot2)
library(reshape2)

pc = read.csv("bubbles-methanogenesis-v2.csv", header = TRUE)

#convert data frame from a "wide" format to a "long" format
pcm = melt(pc, id = c("Sample", "Chimney"))

#Keep the order of samples from your excel sheet:
pcm$Sample <- factor(pcm$Sample,levels=unique(pcm$Sample))

#specify order of chimneys
pcm$Chimney = factor(pcm$Chimney, levels = c("Camel Humps", "Sombrero MT", "Sombrero", "Marker 3", "Calypso", "Marker 2 MT", "Marker 2"))

#define gene category factor
library(plyr)
pcm$Genes = revalue(pcm$variable, c("hdrC2"="Methanogenesis from CO2","hdrB2"="Methanogenesis from CO2","hdrA2"="Methanogenesis from CO2","mcrG"="Methanogenesis from CO2","mcrB"="Methanogenesis from CO2","mcrA"="Methanogenesis from CO2","mtrH"="Methanogenesis from CO2","mtrG"="Methanogenesis from CO2","mtrF"="Methanogenesis from CO2","mtrE"="Methanogenesis from CO2","mtrD"="Methanogenesis from CO2","mtrC"="Methanogenesis from CO2","mtrB"="Methanogenesis from CO2","mtrA"="Methanogenesis from CO2","mer"="Methanogenesis from CO2","hmd"="Methanogenesis from CO2","mtd"="Methanogenesis from CO2","mch"="Methanogenesis from CO2","ftr"="Methanogenesis from CO2","fwdH"="Methanogenesis from CO2","fwdG"="Methanogenesis from CO2","fwdF"="Methanogenesis from CO2","fwdE"="Methanogenesis from CO2","fwdD"="Methanogenesis from CO2","fwdC"="Methanogenesis from CO2","fwdB"="Methanogenesis from CO2","fwdA"="Methanogenesis from CO2","cdhE"="CODH/ACS","cdhD"="CODH/ACS","cdhC"="CODH/ACS","cdhB"="CODH/ACS","cdhA"="CODH/ACS","pta"="acetate/methanol","ackA"="acetate/methanol","mtaC"="acetate/methanol","mtaB"="acetate/methanol","mtaA"="acetate/methanol","mtbA"="acetate/methanol","mttB"="acetate/methanol","mttC"="acetate/methanol"))

#specify order of gene categories
pcm$Genes = factor(pcm$Genes, levels = c("Methanogenesis from CO2", "acetate/methanol", "CODH/ACS"))

# colors
cbPalette <- c("#999999", "#E69F00", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
outline1 <- c("black","#E69F00","black","black","black", "#F0E442","black")
outline2 <- c("#999999","black","#E69F00","#56B4E9","#009E73", "black","#F0E442")

xx = ggplot(pcm, aes(x = Sample, y = variable, order = variable)) + 
  geom_point(aes(size = value, fill = Chimney, color = Chimney), alpha = 0.75, shape = 21, stroke=1) + 
  scale_fill_manual(values = cbPalette, guide = guide_legend(override.aes = list(size=5))) +
  scale_color_manual(values = outline2) + 
  scale_size_continuous(limits = c(0.01, 4000), range=c(1,20), breaks = c(1,10,100,1000)) + 
  labs( x= "", y = "", size = "Normalized Coverage (TPM)", fill = "Chimney")  +
  theme(legend.key=element_blank(), 
        axis.text.x = element_text(colour = "black", size = 11, face = "bold", angle = 90, vjust = 0.3, hjust = 1), 
        axis.text.y = element_text(colour = "black", face = "bold", size = 11), 
        legend.text = element_text(size = 11, face ="bold", colour ="black"), 
        legend.title = element_text(size = 11, face = "bold"), panel.background = element_blank(), 
        panel.border = element_rect(colour = "black", fill = NA, size = 1.2), 
        legend.position = "right", panel.grid.major.y = element_line(colour = "grey95")) +  
  facet_grid(Genes ~ ., scales = "free", space="free") +
  #scale_y_discrete(limits = rev(levels(pcm$variable))) +
  theme(strip.text = element_text(size = 9, colour = "black", face = "bold", angle = 90))

xx

ggsave("bubbles-methanogenesis-v2.svg")
ggsave("bubbles-methanogenesis-v2.png")