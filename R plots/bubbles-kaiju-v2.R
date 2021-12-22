# following tutorial from Jackie Zorz https://jkzorz.github.io/2019/06/05/Bubble-plots.html

library(ggplot2)
library(reshape2)

# first column are samples, second column is a factor (Chimney), first row is a factor (Taxa), second row are variable labels (ASVs)
pc = read.csv("bubbles-kaiju-v2.csv", header = TRUE)

#convert data frame from a "wide" format to a "long" format
pcm = melt(pc, id.vars = c("Sample", "Chimney"))

#Keep the order of samples from your excel sheet:
pcm$Sample <- factor(pcm$Sample,levels=unique(pcm$Sample))

#specify order of chimneys
pcm$Chimney = factor(pcm$Chimney, levels = c("Camel Humps", "Sombrero MT", "Sombrero", "Marker 3", "Calypso", "Marker 2 MT", "Marker 2"))

#manually add Taxa factor level
pcm$Taxa = factor(c("Proteobacteria","Euryarchaeota","Bacteroidetes","Actinobacteria","Chloroflexi","Thaumarchaeota","Basidiomycota","Firmicutes","Ascomycota","Marinimicrobia","Ciliophora","Nitrospirae","Viruses","Planctomycetes","Apicomplexa","Verrucomicrobia","Chytridiomycota","Acidobacteria","Patescibacteria"))

# colors
cbPalette <- c("#999999", "#E69F00", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
outline1 <- c("black","#E69F00","black","black","black", "#F0E442","black")
outline2 <- c("#999999","black","#E69F00","#56B4E9","#009E73", "black","#F0E442")

xx = ggplot(pcm, aes(x = Sample, y = variable)) + 
  geom_point(aes(size = value, fill = Chimney, color = Chimney), alpha = 0.75, shape = 21, stroke=1) + 
  scale_fill_manual(values = cbPalette, guide = guide_legend(override.aes = list(size=5))) +
  scale_color_manual(values = outline2) +
  scale_size_continuous(limits = c(0.001, 100), range=c(1,20), breaks = c(1,10,25,50), labels=scales::number_format(accuracy=1)) + 
  labs( x= "", y = "", size = "Relative\nAbundance\n(%)", fill = "Chimney")  +
  theme(legend.key=element_blank(), 
        axis.text.x = element_text(colour = "black", size = 11, face = "bold", angle = 90, vjust = 0.3, hjust = 1), 
        axis.text.y = element_text(colour = "black", face = "bold", size = 9), 
        legend.text = element_text(size = 10, face ="bold", colour ="black"), 
        legend.title = element_text(size = 11, face = "bold"), panel.background = element_blank(), 
        panel.border = element_rect(colour = "black", fill = NA, size = 1.2), 
        legend.position = "right", panel.grid.major.y = element_line(colour = "grey95"),
        legend.title.align = 0.5) +  
  scale_y_discrete(limits = rev(levels(pcm$variable)))

xx

ggsave("bubbles-kaiju-v2.svg")
ggsave("bubbles-kaiju-v2.png")