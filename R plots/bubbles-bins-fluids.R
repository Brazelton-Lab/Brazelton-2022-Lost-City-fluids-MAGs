# following tutorial from Jackie Zorz https://jkzorz.github.io/2019/06/05/Bubble-plots.html

library(ggplot2)
library(reshape2)

pc = read.csv("bubbles-bins-fluids-v2.csv", header = TRUE)

#convert data frame from a "wide" format to a "long" format
pcm = melt(pc, id = c("Sample", "Chimney"))

#Keep the order of samples from your excel sheet:
pcm$Sample <- factor(pcm$Sample,levels=unique(pcm$Sample))

#specify order of chimneys
pcm$Chimney = factor(pcm$Chimney, levels = c("Camel Humps", "Sombrero MT", "Sombrero", "Marker 3", "Calypso", "Marker 2 MT", "Marker 2"))

# colors
cbPalette <- c("#999999", "#E69F00", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
outline1 <- c("black","#E69F00","black","black","black", "#F0E442","black")
outline2 <- c("#999999","black","#E69F00","#56B4E9","#009E73", "black","#F0E442")

xx = ggplot(pcm, aes(x = Sample, y = variable)) + 
  geom_point(aes(size = value, fill = Chimney, color = Chimney), alpha = 0.75, shape = 21, stroke=1) + 
  scale_fill_manual(values = cbPalette, guide = guide_legend(override.aes = list(size=5))) +
  scale_color_manual(values = outline1) +
  scale_size_continuous(limits = c(1, 8000), range=c(0.1,30), breaks = c(5,50,500,5000)) + 
  labs( x= "", y = "", size = "Normalized\nCoverage\n(TPM)", fill = "Chimney")  +
  theme(legend.key=element_blank(), 
        axis.text.x = element_text(colour = "black", size = 11, face = "bold", angle = 90, vjust = 0.3, hjust = 1), 
        axis.text.y = element_text(colour = "black", face = "bold", size = 11), 
        legend.text = element_text(size = 11, face ="bold", colour ="black"), 
        legend.title = element_text(size = 11, face = "bold"), panel.background = element_blank(), 
        panel.border = element_rect(colour = "black", fill = NA, size = 1.2),
        #plot.margin = margin(t = 50, unit = "pt"),
        legend.position = "right", panel.grid.major.y = element_line(colour = "grey95"),
        legend.title.align = 0.5) +  
  scale_y_discrete(limits = rev(levels(pcm$variable)), labels=rev(c("Methanosarcinaceae MAG-1276","Methanocellales MAG-838","ANME-1 MAG-1099","Bipolaricaulota MAG-1207","Bipolaricaulota MAG-1260","Bipolaricaulota MAG-1503","Thermodesulfovibrionales MAG-1293","Desulfotomaculum MAG-1144","Desulfotomaculum MAG-1580","Natronincolaceae MAG-2163","Dehalococcoidia MAG-844","Dehalococcoidia MAG-2669","NPL-UPA2 MAG-1083","NPL-UPA2 MAG-718","Paceibacteria MAG-302","Gracilibacteria MAG-435","WOR-3 MAG-1066"))) 

xx

ggsave("bubbles-bins-fluids1.svg")
ggsave("bubbles-bins-fluids1.png")

ggsave("bubbles-bins-fluids2.svg")
ggsave("bubbles-bins-fluids2.png")