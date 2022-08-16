library(ggpubr)
library(png)
library(ggplot2)
library(gridExtra)
library(grid)
# library(kableExtra)
library(data.table)
library(dplyr)
library(tidyverse)
# library(reshape2)

# Set default folder
folder <- dirname(rstudioapi::getSourceEditorContext()$path)

# Helper function to calculate mean and standard deviation of each group
data_summary <- function(data, varname, groupnames){
  require(plyr)
  summary_func <- function(x, col){
    c(mean = mean(x[[col]], na.rm=TRUE),
      sd = sd(x[[col]], na.rm=TRUE))}
  data_sum<-ddply(data, groupnames, .fun=summary_func,varname)
  data_sum <- rename(data_sum, c("mean" = varname))
  return(data_sum)}

#Load the data
folder <- dirname(rstudioapi::getSourceEditorContext()$path)
dr <- read.csv(file.path(folder, "uq_results.csv"))
de <- read.csv(file.path(folder, "mission_emission_results.csv"))

# INDIVIDUAL EMISSION PLOTS
de$Constellation = factor(de$constellation)
te <- ggplot(de, aes(x = Constellation,
  y = mission_total_emissions/1e6, fill = Constellation)) +
  geom_bar(stat = "identity", size = 0.9, position=position_dodge(width = 0.01)) +
  scale_fill_brewer(palette = "Paired") +theme_bw() +
  theme(panel.border = element_blank(), 
  panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(), 
  axis.line = element_line(colour = "black"))+
  theme(legend.position = 'bottom') + labs(colour=NULL,
  title = " ",
  subtitle = "Total Emissions",
  x = NULL, y = "Emissions (kt)") +
  scale_y_continuous(labels = function(y) format(y, scientific = FALSE),
  expand = c(0, 0))
te
 ce <- ggplot(de, aes(x = Constellation,
   y = emission_per_capacity*1e3, fill = Constellation)) +
   geom_bar(stat = "identity", size = 0.9, position=position_dodge(width = 0.01)) +
   scale_fill_brewer(palette = "Paired") +theme_bw() +
   theme(panel.border = element_blank(), 
   panel.grid.major = element_blank(),
   panel.grid.minor = element_blank(), 
   axis.line = element_line(colour = "black"))+
   theme(legend.position = 'bottom') + labs(colour=NULL,
   title = " ",
   subtitle = "Emissions per Capacity",
   x = NULL, y = "Emissions (g/Mbps)") +
   scale_y_continuous(labels = function(y) format(y, scientific = FALSE), 
   expand = c(0, 0)) 
ce
 ae <- ggplot(de, aes(x = Constellation,
   y = emission_per_sqkm, fill = Constellation)) +
   geom_bar(stat = "identity", size = 0.9, position=position_dodge(width = 0.01)) +
   scale_fill_brewer(palette = "Paired") +
   theme(legend.position = 'bottom') + theme_bw() +
   theme(panel.border = element_blank(), 
   panel.grid.major = element_blank(),
   panel.grid.minor = element_blank(), 
   axis.line = element_line(colour = "black"))+
   labs(colour=NULL,
   title = " ",
   subtitle = "Equivalent Emission per Area",
   x = NULL, y = "Emissions (kg/km^2)") +
   scale_y_continuous(labels = function(y) format(y, scientific = FALSE), 
   expand = c(0, 0)) 
 ae
 cte <- ggplot(de, aes(x = Constellation,
   y = emission_for_every_cost*1e3, fill = Constellation)) +
   geom_bar(stat = "identity", size = 0.9, position=position_dodge(width = 0.01)) +
   scale_fill_brewer(palette = "Paired") +theme_bw() +
   theme(panel.border = element_blank(), 
   panel.grid.major = element_blank(),
   panel.grid.minor = element_blank(), 
   axis.line = element_line(colour = "black"))+
   theme(legend.position = 'bottom') + labs(colour=NULL,
   title = " ",
   subtitle = "Emissions for every Cost",
   x = NULL, y = "Emissions (mg/$)") +
   scale_y_continuous(labels = function(y) format(y, scientific = FALSE),
   expand = c(0, 0)) 
 cte
 emission_profile <- ggarrange(te, ce, ae, cte, ncol = 2, nrow = 2, 
           common.legend = T, legend="bottom", 
           labels = c("A", "B", "C", "D"))
 emission_profile
 
 path = file.path(folder, 'publication_plots', 
        'constellation_emission_profile.tiff')
 dir.create(file.path(folder, 'publication_plots'), 
         showWarnings = FALSE)
 tiff(path, units="in", width=6, height=6, res=300)
 print(emission_profile)
 dev.off()
 
 # INDIVIDUAL PLOTS WITH ERROR BARS #
 dct <- select(dr, constellation, capex_scenario,channel_capacity, 
               capacity_per_single_satellite, satellite_launch_cost, 
               capacity_per_area_mbps.sqkm, constellation_capacity, 
               ground_station_cost, cnr,
               cnr_scenario,cost_per_capacity, total_cost_ownership)
 
 # CAPACITY PLOTS
 
 # Channel capacity with Bars
 coss = dct %>%
   group_by(channel_capacity, constellation, cnr_scenario) %>%
   summarise(value =mean(channel_capacity),
             error = sd(channel_capacity)) %>%
   ungroup() 
 df1 <- data_summary(dct, varname="channel_capacity", 
                     groupnames=c("constellation", "cnr_scenario"))
 df1$cnr_scenario=as.factor(df1$cnr_scenario)
 df1$Constellation = factor(df1$constellation)
 df1$CNR = factor(df1$cnr_scenario,
   levels=c('Low', 'Baseline', 'High'))
 
 chn_capacity <- ggplot(df1, aes(x=Constellation, y=channel_capacity/1e3, fill=CNR)) + 
    geom_bar(stat="identity", 
   position=position_dodge()) +
   geom_errorbar(aes(ymin=channel_capacity/1e3-sd/1e3, 
   ymax=channel_capacity/1e3+sd/1e3), width=.2,
   position=position_dodge(.9), color = 'orange', size = 0.3) +
   scale_fill_brewer(palette="Paired") + theme_minimal() + 
   theme(legend.position = 'right') + 
       labs(colour=NULL, 
      title = "Channel Capacity", 
      subtitle = "Single channel capacity of each satellite for different carrier-to-noise ratio scenario", 
      x = "Constellation", y = "Capacity (Gbps)") +
   scale_y_continuous(labels = function(y) format(y, 
   scientific = FALSE), expand = c(0, 0)) +
   facet_wrap(~Constellation, scales = "free") + theme_minimal() +
   theme(strip.text.x = element_blank(),
   panel.border = element_blank(),
   panel.grid.major = element_blank(),
   panel.grid.minor = element_blank(),
   axis.line = element_line(colour = "black"))
 chn_capacity
 
 ## Single Satellite Capacity with bars
 coss = dct %>%
   group_by(capacity_per_single_satellite, constellation, cnr_scenario) %>%
   summarise(value =mean(capacity_per_single_satellite),
             error = sd(capacity_per_single_satellite)) %>%
   ungroup() 
 df2 <- data_summary(dct, varname="capacity_per_single_satellite", 
                     groupnames=c("constellation", "cnr_scenario"))
 df2$cnr_scenario=as.factor(df2$cnr_scenario)
 df2$Constellation = factor(df2$constellation)
 df2$CNR = factor(df2$cnr_scenario,
   levels=c('Low', 'Baseline', 'High'))
 
 sat_capacity <- ggplot(df2, aes(x=Constellation, y=capacity_per_single_satellite/1e3, fill=CNR)) + 
    geom_bar(stat="identity", 
   position=position_dodge()) +
   geom_errorbar(aes(ymin=capacity_per_single_satellite/1e3-sd/1e3, 
      ymax=capacity_per_single_satellite/1e3+sd/1e3), width=.2,
   position=position_dodge(.9), color = 'orange', size = 0.3) +
   scale_fill_brewer(palette="Paired") + 
    theme_minimal() + 
   theme(legend.position = 'bottom') + 
    labs(colour=NULL, 
      title = "Single Satellite Capacity", 
      subtitle = "Aggregate capacity of a single satellite based on different carrier-to-noise ratio scenario", 
       x = "Constellation", y = "Capacity (Gbps)") + 
   scale_y_continuous(labels = function(y) format(y, 
   scientific = FALSE), expand = c(0, 0)) + 
   facet_wrap(~Constellation, scales = "free") + 
    theme_minimal() + 
   theme(strip.text.x = element_blank(),
      panel.border = element_blank(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      axis.line = element_line(colour = "black"))
 sat_capacity
 
 ## Per Area Capacity with error bars
 dct %>%
   group_by(capacity_per_area_mbps.sqkm, constellation, cnr_scenario) %>%
   summarise(value =mean(capacity_per_area_mbps.sqkm),
   error = sd(capacity_per_area_mbps.sqkm)) %>%
   ungroup() 
 df3 <- data_summary(dct, varname="capacity_per_area_mbps.sqkm", 
   groupnames=c("constellation", "cnr_scenario"))
 df3$cnr_scenario=as.factor(df3$cnr_scenario)
 df3$Constellation = factor(df3$constellation)
 df3$CNR = factor(df3$cnr_scenario,
   levels=c('Low', 'Baseline', 'High'))
 
 ar_capacity <- ggplot(df3, aes(x=Constellation, y=capacity_per_area_mbps.sqkm, 
   fill=CNR)) + geom_bar(stat="identity", 
   position=position_dodge()) +
   geom_errorbar(aes(ymin=capacity_per_area_mbps.sqkm-sd, 
   ymax=capacity_per_area_mbps.sqkm+sd), width=.2,
   position=position_dodge(.9), color = 'orange', size = 0.3) +
   scale_fill_brewer(palette="Paired") + theme_minimal() +
   theme(legend.position = 'bottom') + labs(colour=NULL, 
   title = "Per Area Capacity", subtitle = "Possible capacity per area for different carrier-to-noise ratio and user adoption rates", 
   x = "Constellation", y = "Capacity (Mbps/km^2)") + 
   scale_y_continuous(labels = function(y) format(y, 
   scientific = FALSE), expand = c(0, 0)) + 
   facet_wrap(~Constellation, scales = "free") + theme_minimal() + 
   theme(strip.text.x = element_blank(),
   panel.border = element_blank(),
   panel.grid.major = element_blank(),
   panel.grid.minor = element_blank(),
   axis.line = element_line(colour = "black"))
 ar_capacity
 
 ## Constellation capacity with error bars
 dct %>%
   group_by(constellation_capacity, constellation, cnr_scenario) %>%
   summarise(value =mean(constellation_capacity),
             error = sd(constellation_capacity)) %>%
   ungroup() 
 df4 <- data_summary(dct, varname="constellation_capacity", 
   groupnames=c("constellation", "cnr_scenario"))
 df4$cnr_scenario=as.factor(df4$cnr_scenario)
 df4$Constellation = factor(df4$constellation)
 df4$CNR = factor(df4$cnr_scenario,
   levels=c('Low', 'Baseline', 'High'))
 
 const_capacity <- ggplot(df4, aes(x=Constellation, y=constellation_capacity/1e6, 
   fill=CNR)) + geom_bar(stat="identity", 
   position=position_dodge()) +
   geom_errorbar(aes(ymin=constellation_capacity/1e6-sd/1e6, 
   ymax=constellation_capacity/1e6+sd/1e6), width=.2,
   position=position_dodge(.9), color = 'orange', size = 0.3) +
   scale_fill_brewer(palette="Paired") + theme_minimal() +
   theme(legend.position = 'bottom') + labs(colour=NULL, 
   title = "Constellation Capacity", subtitle = "Constellation Capacity based on different carrier-to-noise ratio scenario", 
   x = "Constellation", y = "Capacity (Tbps)") +
   scale_y_continuous(labels = function(y) format(y, 
   scientific = FALSE), expand = c(0, 0)) + 
   facet_wrap(~Constellation, scales = "free") + theme_minimal() + 
   theme(strip.text.x = element_blank(),
   panel.border = element_blank(),
   panel.grid.major = element_blank(),
   panel.grid.minor = element_blank(),
   axis.line = element_line(colour = "black"))
 const_capacity
 
 ## Combine all the capacity plots ##
 capacities <- ggarrange(chn_capacity, sat_capacity, 
                    ar_capacity, const_capacity, 
                    ncol = 1, nrow = 4, 
                    common.legend = T, legend="bottom", 
                    labels = c("A", "B", "C", "D"))
 capacities
 
 path = file.path(folder, 'publication_plots', 
                  'constellation_capacity_profile.tiff')
 dir.create(file.path(folder, 'publication_plots'), 
            showWarnings = FALSE)
 tiff(path, units="in", width=7, height=10, res=300)
 print(capacities)
 dev.off()
 
 ## Constellation Satellite Launch costs with Error Bars
 dct %>%
   group_by(satellite_launch_cost, constellation, capex_scenario) %>%
   summarise(value =mean(satellite_launch_cost),
             error = sd(satellite_launch_cost)) %>%
   ungroup() 
 df5 <- data_summary(dct, varname="satellite_launch_cost", 
                     groupnames=c("constellation", "capex_scenario"))
 df5$capex_scenario=as.factor(df5$capex_scenario)
 df5$Constellation = factor(df5$constellation)
 df5$Capex = factor(df5$capex_scenario,
   levels=c('Low', 'Baseline', 'High'))

 p <- ggplot(df5, aes(x=Constellation, y=satellite_launch_cost/1e6, 
   fill=Capex)) + geom_bar(stat="identity", 
   position=position_dodge()) +
   geom_errorbar(aes(ymin=satellite_launch_cost/1e6-sd/1e6, 
   ymax=satellite_launch_cost/1e6+sd/1e6), width=.2,
   position=position_dodge(.9), color = 'orange', size = 0.3)
 sat_costs <- p + scale_fill_brewer(palette="Paired") + theme_minimal() + 
   theme(legend.position = 'bottom') + labs(colour=NULL, 
   title = "Satellite Launch Cost", subtitle = "Satellite Launch Cost for different capital expenditure costs", 
   x = "Capex Scenario", y = "Cost ($ million)") + 
   scale_y_continuous(labels = function(y) format(y, 
   scientific = FALSE), expand = c(0, 0)) + 
   facet_wrap(~Constellation, scales = "free") + theme_minimal() + 
   theme(strip.text.x = element_blank(),
   panel.border = element_blank(),
   panel.grid.major = element_blank(),
   panel.grid.minor = element_blank(),
   axis.line = element_line(colour = "black"))
 sat_costs
 
 ## Constellation Ground Costs with Error Bars
 dct %>%
   group_by(ground_station_cost, constellation, capex_scenario) %>%
   summarise(value =mean(ground_station_cost),
             error = sd(ground_station_cost)) %>%
   ungroup() 
 df6 <- data_summary(dct, varname="ground_station_cost", 
   groupnames=c("constellation", "capex_scenario"))
 df6$capex_scenario=as.factor(df6$capex_scenario)
 df6$Constellation = factor(df6$constellation)
 df6$Capex = factor(df6$capex_scenario,
    levels=c('Low', 'Baseline', 'High'))
 
 p <- ggplot(df6, aes(x=Constellation, y=ground_station_cost/1e6, 
   fill=Capex)) + geom_bar(stat="identity", 
   position=position_dodge()) +
   geom_errorbar(aes(ymin=ground_station_cost/1e6-sd/1e6, 
   ymax=ground_station_cost/1e6+sd/1e6), width=.2,
   position=position_dodge(.9), color = 'orange', size = 0.3)
 grd_costs <- p + scale_fill_brewer(palette="Paired") + theme_minimal() + 
   theme(legend.position = 'bottom') + labs(colour=NULL, 
   title = "Ground Station Cost", subtitle = "Ground Station Cost for different capital expenditure costs", 
   x = "Capex Scenario", y = "Cost ($ million)") + 
   scale_y_continuous(labels = function(y) format(y, 
   scientific = FALSE), expand = c(0, 0)) + 
   facet_wrap(~Constellation, scales = "free") + theme_minimal() + 
   theme(strip.text.x = element_blank(),
   panel.border = element_blank(),
   panel.grid.major = element_blank(),
   panel.grid.minor = element_blank(),
   axis.line = element_line(colour = "black"))
 grd_costs
 
 ## Constellation Cost per capacity Costs with Error Bars
 dct %>%
   group_by(cost_per_capacity, constellation, capex_scenario) %>%
   summarise(value =mean(cost_per_capacity),
             error = sd(cost_per_capacity)) %>%
   ungroup() 
 dff6 <- data_summary(dct, varname="cost_per_capacity", 
   groupnames=c("constellation", "capex_scenario"))
 dff6$capex_scenario=as.factor(dff6$capex_scenario)
 dff6$Constellation = factor(dff6$constellation)
 dff6$Capex = factor(dff6$capex_scenario,
   levels=c('Low', 'Baseline', 'High'))
 
 
 p <- ggplot(dff6, aes(x=Constellation, y=cost_per_capacity/1e6, 
   fill=Capex)) + geom_bar(stat="identity", 
   position=position_dodge()) +
   geom_errorbar(aes(ymin=cost_per_capacity/1e6-sd/1e6, 
   ymax=cost_per_capacity/1e6+sd/1e6), width=.2,
   position=position_dodge(.9), color = 'orange', size = 0.3)
 cap_cost <- p + scale_fill_brewer(palette="Paired") + theme_minimal() +
   theme(legend.position = 'bottom') + labs(colour=NULL, 
   title = "Cost per Capacity", subtitle = "Cost for providing a 1 Gbps capacity under different capital expenditure scenarios", 
   x = "Capex Scenario", y = "Cost ($ million/Gbps)") + 
   scale_y_continuous(labels = function(y) format(y, 
   scientific = FALSE), expand = c(0, 0)) + 
   facet_wrap(~Constellation, scales = "free") + theme_minimal() + 
   theme(strip.text.x = element_blank(),
   panel.border = element_blank(),
   panel.grid.major = element_blank(),
   panel.grid.minor = element_blank(),
   axis.line = element_line(colour = "black"))
 cap_cost
 
 ## Constellation Total Cost Ownership with Error Bars
 dct %>%
   group_by(total_cost_ownership, constellation, capex_scenario) %>%
   summarise(value =mean(total_cost_ownership),
             error = sd(total_cost_ownership)) %>%
   ungroup() 
 df7 <- data_summary(dct, varname="total_cost_ownership", 
   groupnames=c("constellation", "capex_scenario"))
 df7$capex_scenario=as.factor(df7$capex_scenario)
 df7$Constellation = factor(df7$constellation)
 df7$Capex = factor(df7$capex_scenario,
   levels=c('Low', 'Baseline', 'High'))

 p <- ggplot(df7, aes(x=Constellation, y=total_cost_ownership/1e6, 
   fill=Capex)) + geom_bar(stat="identity", 
   position=position_dodge()) +
   geom_errorbar(aes(ymin=(total_cost_ownership/1e6)-sd/1e6, 
   ymax=(total_cost_ownership/1e6)+sd/1e6), width=.2,
   position=position_dodge(.9), color = 'orange', size = 0.3)
 total_cost <- p + scale_fill_brewer(palette="Paired") +
   theme(legend.position = 'bottom') + labs(colour=NULL, 
   title = "Total Cost Ownership", subtitle = "Resulting total cost of ownership for different capital expenditure scenario", 
   x = "Capex Scenario", y = "Cost ($ million)") + 
   scale_y_continuous(labels = function(y) format(y, 
   scientific = FALSE), expand = c(0, 0)) + 
   facet_wrap(~Constellation, scales = "free") + theme_minimal() + 
   theme(strip.text.x = element_blank(),
   panel.border = element_blank(),
   panel.grid.major = element_blank(),
   panel.grid.minor = element_blank(),
   axis.line = element_line(colour = "black"))
 total_cost
 
 ## Combine Cost Plots ##
 const_cost <- ggarrange(sat_costs, grd_costs, 
                         cap_cost, total_cost, 
                         nrow = 4, 
                         common.legend = T, legend="bottom", 
                         labels = c("A", "B", "C", "D"))
 const_cost
 
 path = file.path(folder, 'publication_plots', 
                  'constellation_cost_profile.tiff')
 dir.create(file.path(folder, 'publication_plots'), 
            showWarnings = FALSE)
 tiff(path, units="in", width=7, height=10, res=380)
 print(const_cost)
 dev.off()
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


