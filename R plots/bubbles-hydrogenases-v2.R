# following tutorial from Jackie Zorz https://jkzorz.github.io/2019/06/05/Bubble-plots.html

library(ggplot2)
library(reshape2)

pc = read.csv("bubbles-hydrogenases-v2.csv", header = TRUE)

#convert data frame from a "wide" format to a "long" format
pcm = melt(pc, id = c("Sample", "Chimney"))

#Keep the order of samples from your excel sheet:
pcm$Sample <- factor(pcm$Sample,levels=unique(pcm$Sample))

#specify order of chimneys
pcm$Chimney = factor(pcm$Chimney, levels = c("Camel Humps", "Sombrero MT", "Sombrero", "Marker 3", "Calypso", "Marker 2 MT", "Marker 2"))

#define gene category factor
library(plyr)
pcm$Genes = revalue(pcm$variable, c("hyaC"="Group 1 NiFe","hyaB"="Group 1 NiFe","hyaA"="Group 1 NiFe","hydB3"="Group 1 NiFe","hydA3"="Group 1 NiFe","hydB2"="Group 1 NiFe","hydA2"="Group 1 NiFe","hoxH"="Group 3 NiFe","hoxF"="Group 3 NiFe","hoxU"="Group 3 NiFe","hoxY"="Group 3 NiFe","mbhL"="Group 4 NiFe","mbhK"="Group 4 NiFe","mbhJ"="Group 4 NiFe","hndB"="FeFe","hndA"="FeFe","hndC"="FeFe","hndD"="FeFe","mvhA"="Group 3 NiFe","frhA"="Group 3 NiFe","frhB"="Group 3 NiFe","frhD"="Group 3 NiFe","frhG"="Group 3 NiFe","echA"="Group 4 NiFe","echB"="Group 4 NiFe","echC"="Group 4 NiFe","echD"="Group 4 NiFe","echE"="Group 4 NiFe","echF"="Group 4 NiFe","ehaR"="Group 4 NiFe","ehbQ"="Group 4 NiFe","vhoA"="Group 1 NiFe","vhoG"="Group 1 NiFe"))

#specify order of gene categories
pcm$Genes = factor(pcm$Genes, levels = c("Group 1 NiFe", "Group 3 NiFe", "Group 4 NiFe", "FeFe"))

# colors
cbPalette <- c("#999999", "#E69F00", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
outline1 <- c("black","#E69F00","black","black","black", "#F0E442","black")
outline2 <- c("#999999","black","#E69F00","#56B4E9","#009E73", "black","#F0E442")

xx = ggplot(pcm, aes(x = Sample, y = variable, order = variable)) + 
  geom_point(aes(size = value, fill = Chimney, color = Chimney), alpha = 0.75, shape = 21, stroke=1) + 
  scale_fill_manual(values = cbPalette, guide = guide_legend(override.aes = list(size=5))) +
  scale_color_manual(values = outline2) + 
  scale_size_continuous(limits = c(0.01, 1050), range=c(1,15), breaks = c(1,10,100,1000)) + 
  labs( x= "", y = "", size = "Normalized Coverage (TPM)", fill = "Chimney")  +
  theme(legend.key=element_blank(), 
        axis.text.x = element_text(colour = "black", size = 10, face = "bold", angle = 90, vjust = 0.3, hjust = 1), 
        axis.text.y = element_text(colour = "black", face = "bold", size = 9), 
        legend.text = element_text(size = 10, face ="bold", colour ="black"), 
        legend.title = element_text(size = 11, face = "bold"), panel.background = element_blank(), 
        panel.border = element_rect(colour = "black", fill = NA, size = 1.2), 
        legend.position = "right", panel.grid.major.y = element_line(colour = "grey95")) +  
  facet_grid(Genes ~ ., scales = "free", space="free") +
  #scale_y_discrete(limits = rev(levels(pcm$variable))) +
  theme(strip.text = element_text(size = 10, colour = "black", face = "bold", angle = 90))

xx

ggsave("bubbles-hydrogenases-v2.svg")
ggsave("bubbles-hydrogenases-v2.png")