library(ggplot2)
library(dplyr)
library(ggpubr)

folder <- dirname(rstudioapi::getSourceEditorContext()$path)
#Load the data
dq <- read.csv(file.path(folder, "uq_results.csv"))
dqq <- select(dq, constellation, constellation_capacity,cnr_scenario, 
              capacity_scenario, capacity_per_area_mbps.sqkm,cnr, 
              demand_scenario, cost_per_capacity, cost_scenario)

# Rename the Columns
names(dqq)[names(dqq) == "constellation"] <- "Constellation"
names(dqq)[names(dqq) == "constellation_capacity"] <- "Constellation_Capacity"
names(dqq)[names(dqq) == "capacity_scenario"] <- "Capacity_Scenario"
names(dqq)[names(dqq) == "capacity_per_area_mbps.sqkm"] <- "Demand_Density"
names(dqq)[names(dqq) == "demand_scenario"] <- "Demand_Scenario"
names(dqq)[names(dqq) == "cost_per_capacity"] <- "Cost_per_Capacity"
names(dqq)[names(dqq) == "cost_scenario"] <- "Cost_Scenario"

dqq$Demand_Scenario = factor(dqq$Demand_Scenario,
                           levels=c('Low', 'Baseline', 'High'))
dq <- ggplot(dqq, aes(x = Demand_Scenario, y = Demand_Density, 
      fill = Constellation)) + geom_boxplot() + 
      stat_summary(fun = "mean", geom = "point",shape = 8, 
      size = 2, color = "white") + 
      scale_fill_brewer(palette = "Paired") + theme_bw() + 
      theme(panel.border = element_blank(), 
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(), 
      axis.line = element_line(colour = "black")) + 
      labs(colour=NULL, title = NULL,
      x = " ", y = "Capacity per area (Mbps/km^2)") + 
      scale_y_continuous(labels = function(y) format(y, scientific = FALSE))

dqq$Cost_Scenario = factor(dqq$Cost_Scenario,
                         levels=c('Low', 'Baseline', 'High'))
ctq <- ggplot(dqq, aes(x = Cost_Scenario, y = Cost_per_Capacity/1e6, 
       fill = Constellation)) + geom_boxplot() + 
       stat_summary(fun = "mean", geom = "point",shape = 8, 
       size = 2, color = "white") + 
       scale_fill_brewer(palette = "Paired") + theme_bw() + 
       theme(panel.border = element_blank(), 
       panel.grid.major = element_blank(),
       panel.grid.minor = element_blank(), 
       axis.line = element_line(colour = "black")) + 
       labs(colour=NULL, title = NULL,
       x = " ", y = "Cost per Capacity (US$ millions)") + 
       scale_y_continuous(labels = function(y) format(y, scientific = FALSE))
ctq

dqq$cnr_scenario = factor(dqq$cnr_scenario,
                         levels=c('Low', 'Baseline', 'High'))
cnr_box <- ggplot(dqq, aes(x = cnr_scenario, y = cnr, 
                          fill = Constellation)) + geom_boxplot() + 
  stat_summary(fun = "mean", geom = "point",shape = 8, 
               size = 2, color = "white") + 
  scale_fill_brewer(palette = "Paired") + theme_bw() + 
  theme(panel.border = element_blank(), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), 
        axis.line = element_line(colour = "black")) + 
  labs(colour=NULL, title = NULL,
       x = " ", y = "Carrier-to-noise ratio (dB)") + 
  scale_y_continuous(labels = function(y) format(y, scientific = FALSE))
cnr_box

uq <- ggarrange(cnr_box, dq, ctq, ncol = 3, 
          common.legend = T, legend="bottom",
          labels = c("A", "B","C"), align = c("hv"))
uq

path = file.path(folder, 'figures', 
                 'uncertainity_plots.tiff')
dir.create(file.path(folder, 'figures'), 
           showWarnings = FALSE)
tiff(path, units="in", width=9, height=3.5, res=300)
print(uq)
dev.off()
