library(ggpubr)
library(png)
library(ggplot2)
library(gridExtra)
library(grid)
library(data.table)
library(dplyr)
library(tidyverse)

# Set default folder
folder <- dirname(rstudioapi::getSourceEditorContext()$path)

# Helper function to calculate mean and standard deviation of each group
data_summary <- function(data, varname, groupnames){
  require(plyr)
  summary_func <- function(x, col){c(mean = mean(x[[col]], na.rm=TRUE),
      sd = sd(x[[col]], na.rm=TRUE))}
  data_sum <- ddply(data, groupnames, .fun=summary_func,varname)
  data_sum <- rename(data_sum, c("mean" = varname))
  return(data_sum)}

#Load the data
folder <- dirname(rstudioapi::getSourceEditorContext()$path)
dr <- read.csv(file.path(folder, "uq_results.csv"))
de <- read.csv(file.path(folder, "mission_emission_results.csv"))

# INDIVIDUAL EMISSION PLOTS
# Rocket Fuels
Fuel <- c("Kerosene", "Kerosene", "Hypergolic", "Solid", "Cryogenic",
          "Hypergolic")
Rockets <- c("Falcon-9", "Soyuz-FG", "Soyuz-FG", "Ariane-5", "Ariane-5",
             "Ariane-5")
Amount <- c(488370, 218150, 7360, 10000, 480000, 184900)
fuels_df <- data.frame(Rockets, Fuel, Amount) 

fuels <- ggplot(fuels_df, aes(x = Rockets, y = Amount/1e3, 
  fill = Fuel, label = Amount/1e3)) + geom_bar(stat = "identity", width = 0.98) + 
  geom_text(size = 1.5, position = position_stack(vjust = 0.9)) + 
  scale_fill_brewer(palette="Paired") + labs(colour=NULL, 
  title = NULL, subtitle = "Rocket Fuel Compositions",
  x = NULL, y = "Fuel Amounts (t)", fill = "Fuel") +
  scale_y_continuous(labels = function(y) format(y, 
  scientific = FALSE), expand = c(0, 0), limits = c(0, 700)) + 
  theme_minimal() + theme(strip.text.x = element_blank(),
  panel.border = element_blank(), panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
  axis.title=element_text(size=5)) + theme(legend.position = 'bottom') + 
  theme(legend.text=element_text(size=5))
fuels
# Variables to Consider
emissions <- select(de, constellation, constellation_capacity,
  capacity_per_user, total_emissions_t, total_opex, opex_scenario,
  emission_per_capacity, emission_per_sqkm, emission_for_every_cost, 
  total_cost_ownership, subscriber_scenario, subscribers, mission_total_emissions, 
  capex_scenario, mission_emission_per_capacity, mission_emission_per_sqkm,
  mission_emission_for_every_cost, emission_per_subscriber)

# Capacity per Subscriber
cap_per = emissions %>%
  group_by(capacity_per_user, constellation, subscriber_scenario) %>%
  summarise(value =mean(capacity_per_user),
            error = sd(capacity_per_user)) %>%
  ungroup() 
df1 <- data_summary(emissions, varname="capacity_per_user", 
                    groupnames=c("constellation", "subscriber_scenario"))
df1$subscriber_scenario=as.factor(df1$subscriber_scenario)
df1$Constellation = factor(df1$constellation)
df1$subscriber_scenario = factor(df1$subscriber_scenario,
   levels=c('Low', 'Baseline', 'High'),
   labels=c('Low', 'Baseline', 'High'))

capacity_subscriber <- ggplot(df1, aes(x = Constellation, y = capacity_per_user, 
  fill = subscriber_scenario)) + geom_bar(stat = "identity", 
  position=position_dodge()) + 
  geom_errorbar(aes(ymin=capacity_per_user-sd, 
  ymax=capacity_per_user+sd), width=.2,
  position=position_dodge(.9), color = 'orange', size = 0.3) +
  scale_fill_brewer(palette="Paired") + 
  labs(colour=NULL, title = "Capacity per User", 
  subtitle = "Estimated for different subscriber scenarios with \nerror bars representing 1 standard deviation.", 
  x = NULL, y = "Capacity (Mbps/user)", fill ='Scenario') +
  scale_y_continuous(labels = function(y) format(y, scientific = FALSE), 
  expand = c(0, 0), limits = c(0, 150)) + theme_minimal() +
  theme(strip.text.x = element_blank(), 
  panel.border = element_blank(), panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) + 
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) +
  theme(legend.text=element_text(size=8))
capacity_subscriber

# Emission per subscriber
subscriber = emissions %>%
  group_by(emission_per_subscriber, constellation, subscriber_scenario) %>%
  summarise(value =mean(emission_per_subscriber),
            error = sd(emission_per_subscriber)) %>%
  ungroup() 
df1 <- data_summary(emissions, varname="emission_per_subscriber", 
       groupnames=c("constellation", "subscriber_scenario"))
df1$subscriber_scenario=as.factor(df1$subscriber_scenario)
df1$Constellation = factor(df1$constellation)
df1$subscriber_scenario = factor(df1$subscriber_scenario,
                levels=c('Low', 'Baseline', 'High'),
                 labels=c('Low', 'Baseline', 'High'))

emission_subscriber <- ggplot(df1, aes(x = Constellation, y = emission_per_subscriber, 
  fill = subscriber_scenario)) + geom_bar(stat = "identity",width = 0.98, 
  position=position_dodge()) + scale_fill_brewer(palette="Paired") + 
  theme_minimal() + labs(colour=NULL, title = NULL, 
  subtitle = "Emissions estimated for \ndifferent subscriber scenarios.", 
  x = NULL, y = "Emission (kg/subscriber)", fill ='Scenario') +
  scale_y_continuous(labels = function(y) format(y, scientific = FALSE), expand = c(0, 0)) +
  #facet_wrap(~Constellation, scales = "free") +
  theme_minimal() + theme(strip.text.x = element_blank(),
  panel.border = element_blank(), panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) + 
  theme(legend.position = 'bottom', axis.title=element_text(size = 5)) + 
  theme(legend.text=element_text(size=5)) 
emission_subscriber

# Mission Total Emissions
total_emissions = emissions %>%
  group_by(mission_total_emissions, constellation) %>%
  summarise(value =mean(mission_total_emissions),
            error = sd(mission_total_emissions)) %>%
  ungroup() 
df1 <- data_summary(emissions, varname="mission_total_emissions", 
                    groupnames=c("constellation"))
df1$Constellation = factor(df1$constellation)

emission_total <- ggplot(df1, aes(x = Constellation, y = mission_total_emissions/1e6, 
  fill=Constellation)) + geom_text(aes(label = round(after_stat(y),2), 
  group = Constellation), stat = 'summary', fun = sum, vjust = -.5, size = 1.5) +
  geom_bar(stat = "identity", width = 0.98, position = "dodge")  + scale_fill_brewer(palette="Paired") + 
  theme_minimal()  +  labs(colour=NULL, title = NULL, subtitle = "Total Constellation Emissions", 
  x = NULL, y = "Total Emissions (kt)", fill = "Constellations") +
  scale_y_continuous(labels = function(y) format(y, scientific = FALSE), 
  expand = c(0, 0), limits = c(0,35)) + theme_minimal() +
  theme(strip.text.x = element_blank(), panel.border = element_blank(),
  panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
  axis.line = element_line(colour = "black")) + theme(legend.position = 'none',
  axis.title=element_text(size = 6)) + theme(legend.text=element_text(size=6))
emission_total

# Emissions Vs Capacity Provided
emission_cap = emissions %>%
  group_by(mission_emission_per_capacity, constellation) %>%
  summarise(value =mean(mission_emission_per_capacity),
            error = sd(mission_emission_per_capacity)) %>%
  ungroup() 
df1 <- data_summary(emissions, varname="mission_emission_per_capacity", 
                    groupnames=c("constellation"))
df1$Constellation = factor(df1$constellation)

emission_capacity <- ggplot(df1, aes(x= Constellation, y = mission_emission_per_capacity, 
  fill=Constellation)) + geom_text(aes(label = round(after_stat(y), 2), group = Constellation), 
  stat = 'summary', fun = sum, vjust = -.5, size = 1.5) +
  geom_bar(stat = "identity", size = 0.98)  +
  scale_fill_brewer(palette = "Paired") + theme_minimal() + 
  theme(legend.position = 'right') + geom_col(width = 0.5) + 
  labs(colour = NULL, title = NULL, subtitle = "Emissions vs \nProvided Capacity", 
  x = NULL, y = "Emissions (kg/Mbps)", fill='Constellations') +
  scale_y_continuous(labels = function(y) format(y, 
  scientific = FALSE), expand = c(0, 0), limits = c(0, 1)) +
  theme_minimal() + theme(strip.text.x = element_blank(),
  panel.border = element_blank(), panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) + 
  theme(legend.position = 'none', axis.title=element_text(size = 6)) + 
  theme(legend.text=element_text(size=6)) 
emission_capacity

# Emission vs Cost

emission_ct = emissions %>%
  group_by(mission_emission_for_every_cost, constellation) %>%
  summarise(value = mean(mission_emission_for_every_cost),
            error = sd(mission_emission_for_every_cost)) %>%
  ungroup() 
df1 <- data_summary(emissions, varname ="mission_emission_for_every_cost", 
                    groupnames = c("constellation"))
df1$Constellation = factor(df1$constellation)

emission_cost <- ggplot(df1, aes(x= Constellation, y = (mission_emission_for_every_cost * 1e6) / 1e3, 
  fill=Constellation)) + geom_text(aes(label = round(after_stat(y), 2), group = Constellation), 
  stat = 'summary', fun = sum, vjust = -.5, size = 1.5) +
  geom_bar(stat = "identity", size = 0.98)  +
  scale_fill_brewer(palette = "Paired") + theme_minimal() + 
  theme(legend.position = 'right') + 
  labs(colour = NULL, title = NULL, subtitle = "Emissions vs \nInvestment Cost", 
       x = NULL, y = "Emissions (Tonnes per US$ 1 Million)", fill = "Constellations") +
  scale_y_continuous(labels = function(y) format(y, 
  scientific = FALSE), expand = c(0, 0), limits = c(0, 30)) +
  theme_minimal() + theme(strip.text.x = element_blank(),
  panel.border = element_blank(), panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"), 
  axis.title.x=element_text(size=5)) + 
  theme(legend.position = 'none', axis.title = element_text(size = 6)) + 
  theme(legend.text=element_text(size=6)) 
emission_cost

# Emission vs Area

emission_sqkm = emissions %>%
  group_by(mission_emission_per_sqkm, constellation) %>%
  summarise(value = mean(mission_emission_per_sqkm),
            error = sd(mission_emission_per_sqkm)) %>%
  ungroup() 
df1 <- data_summary(emissions, varname = "mission_emission_per_sqkm", 
                    groupnames = c("constellation"))
df1$Constellation = factor(df1$constellation)

emission_area <- ggplot(df1, aes(x = Constellation, y = mission_emission_per_sqkm, 
  fill=Constellation)) + geom_text(aes(label = round(after_stat(y), 2), group = Constellation), 
  stat = "summary", fun = sum, vjust = -.5, size = 2.5) +
  geom_bar(stat = "identity", size = 0.9)  +
  scale_fill_brewer(palette = "Paired") + theme_minimal() + 
  theme(legend.position = "right") + 
  labs(colour = NULL, title = "", subtitle = "Emissions vs Coverage Area", 
  x = "", y = "Emissions (Kilograms per km^2)", fill = "Constellations") +
  scale_y_continuous(labels = function(y) format(y, 
  scientific = FALSE), expand = c(0, 0), limits = c(0, 200)) +
  theme_minimal() + theme(strip.text.x = element_blank(),
  panel.border = element_blank(), panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) + 
  theme(legend.position = 'bottom', axis.title = element_text(size = 7))
emission_area


# EMISSION VALIDATION WITH COLUMBIA DATA
constellation <- c("Kuiper", "OneWeb", "Starlink", "Terrestrial")
subscribers_high <- c(500000, 100000, 800000, 61000000)
total_emissions_full <- c(29, 0.04, 18, 187)
emission_sub <- c(29*1e6/1000000, 0.04*1e6/300000, 18*1e6/1500000, 187*1e6/61800000)
sat_terres <- data.frame(constellation, subscribers_high, emission_sub)

emission_validation <- ggplot(sat_terres, aes(x = constellation, y = emission_sub, 
  fill = constellation)) + 
  geom_text(aes(label = round(after_stat(y), 2), group = constellation), 
  stat = "summary", fun = sum, vjust = -.5, size = 1.5) + 
  geom_bar(stat = "identity", size = 0.9) + 
  scale_fill_brewer(palette="Paired") + theme_minimal() + 
  theme(legend.position = "right") + 
  labs(colour = NULL, title = NULL, 
  subtitle = "Constellations vs \nTerrestrial Networks", 
  x = NULL, y = "Emission (kg/subscriber)", 
  caption = "Terrestrial network is based on 2020 Columbian Mobile 
  \nNetwork Operators (América Móvil, Telefonica and Millicom) market data.",
  fill ='Constellations') +
  scale_y_continuous(labels = function(y) format(y, scientific = FALSE), expand = c(0, 0), limits = c(0, 32)) +
  theme_minimal() + theme(strip.text.x = element_blank(), 
  panel.border = element_blank(), panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) + 
  theme(legend.position = 'none', axis.title = element_text(size = 5)) +
  theme(plot.caption = element_text(size=5, color="black", face="italic")) + 
  theme(legend.text=element_text(size=5))
emission_validation

# Save emission validation results
pub_emission <- ggarrange(fuels, emission_total, emission_capacity, emission_cost,
  emission_subscriber, emission_validation, nrow = 3, ncol = 2, 
  labels = c("a","b","c","d", "e", "f"))

path = file.path(folder, 'figures', 'pub_emission.tiff')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
tiff(path, units="in", width=5.6, height=6.5, res=720)
print(pub_emission)
dev.off()

# INDIVIDUAL PLOTS WITH ERROR BARS #
dct <- select(dr, constellation, capex_scenario, total_opex, 
              channel_capacity, opex_scenario, 
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
  levels=c('Low (<7.5 dB)', 'Baseline(7.6 - 10.5 dB)', 'High(>13.5 dB)'),
  labels=c('Low', 'Baseline', 'High'))

chn_capacity <- ggplot(df1, aes(x=Constellation, y=channel_capacity/1e3, fill=CNR)) + 
  geom_bar(stat="identity", position=position_dodge()) +
  geom_errorbar(aes(ymin=channel_capacity/1e3-sd/1e3, 
  ymax=channel_capacity/1e3+sd/1e3), width=.2,
  position=position_dodge(.9), color = 'orange', size = 0.3) +
  scale_fill_brewer(palette="Paired") + theme_minimal() + 
  theme(legend.position = 'right') + 
  labs(colour=NULL, title = "Single Satellite Channel Capacity", 
  subtitle = "Estimated for different QoS scenarios with \nerror bars representing 1 SD.", 
  x = NULL, y = "Capacity (Gbps)", fill='Scenario') +
  scale_y_continuous(labels = function(y) format(y, 
  scientific = FALSE), expand = c(0, 0)) +theme_minimal() +
  theme(strip.text.x = element_blank(), panel.border = element_blank(),
  panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
  axis.line = element_line(colour = "black")) + 
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) + 
  theme(legend.text=element_text(size=8))
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
                 levels=c('Low (<7.5 dB)', 'Baseline(7.6 - 10.5 dB)', 'High(>13.5 dB)'),
                 labels=c('Low', 'Baseline', 'High'))

sat_capacity <- ggplot(df2, aes(x=Constellation, y=capacity_per_single_satellite/1e3, fill=CNR)) + 
  geom_bar(stat="identity", position=position_dodge()) +
  geom_errorbar(aes(ymin=capacity_per_single_satellite/1e3-sd/1e3, 
  ymax=capacity_per_single_satellite/1e3+sd/1e3), width=.2,
  position=position_dodge(.9), color = 'orange', size = 0.3) +
  scale_fill_brewer(palette="Paired") + theme_minimal() + 
  theme(legend.position = 'bottom') + labs(colour=NULL, 
  title = "Single Satellite Aggregate Capacity", 
  subtitle = "Estimated for different QoS scenarios with \nerror bars representing 1 SD.", 
  x = NULL, y = "Capacity (Gbps)", fill='Scenario') + 
  scale_y_continuous(labels = function(y) format(y, 
  scientific = FALSE), expand = c(0, 0), limits = c(0, 30)) + 
  theme_minimal() +  theme(strip.text.x = element_blank(),
  panel.border = element_blank(), panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) + 
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) + 
  theme(legend.text=element_text(size=8))
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
                 levels=c('Low (<7.5 dB)', 'Baseline(7.6 - 10.5 dB)', 'High(>13.5 dB)'),
                 labels=c('Low', 'Baseline', 'High'))

ar_capacity <- ggplot(df3, aes(x=Constellation, y=capacity_per_area_mbps.sqkm, 
  fill=CNR)) + geom_bar(stat="identity", 
  position=position_dodge()) +
  geom_errorbar(aes(ymin=capacity_per_area_mbps.sqkm-sd, 
  ymax=capacity_per_area_mbps.sqkm+sd), width=.2,
  position=position_dodge(.9), color = 'orange', size = 0.3) +
  scale_fill_brewer(palette="Paired") + theme_minimal() +
  theme(legend.position = 'bottom') + labs(colour=NULL, 
  title = "Per Area Capacity", 
  subtitle = "Estimated for different QoS scenarios and adoption rates with error bars representing 1 SD.", 
  x = "", y = "Capacity (Mbps/km^2)", fill='Scenario') + 
  scale_y_continuous(labels = function(y) format(y, 
  scientific = FALSE), expand = c(0, 0)) + 
  facet_wrap(~Constellation, scales = "free") + theme_minimal() + 
  theme(strip.text.x = element_blank(),
        panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.title=element_text(size=8))
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
                 levels=c('Low (<7.5 dB)', 'Baseline(7.6 - 10.5 dB)', 'High(>13.5 dB)'),
                 labels=c('Low', 'Baseline', 'High'))

const_capacity <- ggplot(df4, aes(x=Constellation, y=constellation_capacity/1e6, 
  fill=CNR)) + 
  geom_bar(stat = "identity", position=position_dodge()) +
  geom_errorbar(aes(ymin=constellation_capacity/1e6-sd/1e6, 
  ymax=constellation_capacity/1e6+sd/1e6), width=.2,
  position=position_dodge(.9), color = 'orange', size = 0.3) +
  scale_fill_brewer(palette="Paired") + theme_minimal() +
  labs(colour=NULL, title = "Aggregate Constellation Capacity", 
  subtitle = "Estimated for different QoS scenarios with \nerror bars represent 1 standard deviation.", 
  x = NULL, y = "Capacity (Tbps)", fill='Scenario') +
  scale_y_continuous(labels = function(y) format(y, 
  scientific = FALSE), expand = c(0, 0), limits = c(0, 130)) + 
  theme_minimal() + theme(strip.text.x = element_blank(),
  panel.border = element_blank(), panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
  axis.title=element_text(size=8), legend.position = 'bottom') + 
  theme(legend.text=element_text(size=8))
const_capacity

## Combine all the capacity plots ##
pub_cap <- ggarrange(chn_capacity, sat_capacity, const_capacity, 
  capacity_subscriber, nrow = 2,ncol = 2, common.legend = T, 
  legend="bottom", labels = c("a", "b", "c", "d"))
pub_cap

path = file.path(folder, 'figures', 'pub_capacity_profile.tiff')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
tiff(path, units="in", width=7.5, height=6, res=720)
print(pub_cap)
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
  title = "Satellite Launch Cost", 
  subtitle = "Estimated for different capex scenarios with error bars representing 1 SD.", 
  x = "", y = "Capex Cost\n(Million US$)") + 
  scale_y_continuous(labels = function(y) format(y, 
  scientific = FALSE), expand = c(0, 0)) + 
  facet_wrap(~Constellation, scales = "free") + theme_minimal() + 
  theme(strip.text.x = element_blank(),
        panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.title=element_text(size=8))
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
  title = "Ground Station Cost", 
  subtitle = "Estimated for different capex scenarios with error bars representing 1 SD.", 
  x = "", y = "Capex Cost\n(Million US$)") + 
  scale_y_continuous(labels = function(y) format(y, 
  scientific = FALSE), expand = c(0, 0)) + 
  facet_wrap(~Constellation, scales = "free") + theme_minimal() + 
  theme(strip.text.x = element_blank(),
        panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.title=element_text(size=8))
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
  labs(colour=NULL, title = "Cost per Capacity", 
  subtitle = "Estimated for different capex scenarios with 
  \nerror bars representing 1 standard deviation.", 
  x = NULL, y = "Capex Cost\n(Million US$ per Gbps)") + 
  scale_y_continuous(labels = function(y) format(y, 
  scientific = FALSE), expand = c(0, 0)) + 
  theme_minimal() + 
  theme(strip.text.x = element_blank(),
        panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.title=element_text(size=8), legend.position = 'bottom') +  
  theme(legend.text=element_text(size=8))
cap_cost

## Constellation Total Cost Ownership with Error Bars
dct %>%
  group_by(total_cost_ownership, constellation, capex_scenario) %>%
  summarise(value =mean(total_cost_ownership),
  error = sd(total_cost_ownership)) %>% ungroup() 
df7 <- data_summary(dct, varname="total_cost_ownership", 
  groupnames=c("constellation", "capex_scenario"))
df7$capex_scenario=as.factor(df7$capex_scenario)
df7$Constellation = factor(df7$constellation)
df7$Capex = factor(df7$capex_scenario, levels=c('Low', 'Baseline', 'High'))

p <- ggplot(df7, aes(x=Constellation, y=total_cost_ownership/1e6, 
  fill=Capex)) + geom_bar(stat="identity", position=position_dodge()) +
  geom_errorbar(aes(ymin=(total_cost_ownership/1e6)-sd/1e6, 
  ymax=(total_cost_ownership/1e6)+sd/1e6), width=.2,
  position=position_dodge(.9), color = 'orange', size = 0.3)
total_cost <- p + scale_fill_brewer(palette="Paired") +
  labs(colour=NULL, title = "Total Cost of Ownership (TCO)", 
  subtitle = "Estimated for different capex scenarios with 
  \nerror bars representing 1 standard deviation.", 
  x = NULL, y = "TCO\n(Million US$ per Gbps)") + 
  scale_y_continuous(labels = function(y) format(y, 
  scientific = FALSE), expand = c(0, 0)) + 
  theme_minimal() + theme(strip.text.x = element_blank(),
  panel.border = element_blank(), panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
  axis.title=element_text(size=8), legend.position = 'bottom') +
  theme(legend.text=element_text(size=8))
total_cost

## Total Cost Ownership per subscriber with Error Bars
emissions %>%
  group_by(total_cost_ownership, constellation, capex_scenario, subscribers) %>%
  summarise(value =mean(total_cost_ownership/subscribers),
  error = sd(total_cost_ownership/subscribers)) %>% ungroup() 
df7 <- data_summary(emissions, varname="total_cost_ownership", 
  groupnames=c("constellation", "capex_scenario", "subscribers"))
df7$capex_scenario=as.factor(df7$capex_scenario)
df7$Constellation = factor(df7$constellation)
df7$Capex = factor(df7$capex_scenario, levels=c('Low', 'Baseline', 'High'))

p <- ggplot(df7, aes(x=Constellation, y=total_cost_ownership/subscribers, 
  fill=Capex)) + geom_bar(stat="identity", position=position_dodge()) +
  geom_errorbar(aes(ymin=(total_cost_ownership/subscribers)-sd/subscribers, 
  ymax=(total_cost_ownership/subscribers)+sd/subscribers), width=.2,
  position=position_dodge(.9), color = 'orange', size = 0.3)
tco_subscriber <- p + scale_fill_brewer(palette="Paired") +
  labs(colour=NULL, title = "TCO per User", 
  subtitle = "Estimated for different capex scenarios with 
  \nerror bars representing 1 standard deviation.", 
  x = NULL, y = "TCO per User\n(Million US$ per User)") + 
  scale_y_continuous(labels = function(y) format(y, 
  scientific = FALSE), expand = c(0, 0)) + theme_minimal() + 
  theme(strip.text.x = element_blank(),
  panel.border = element_blank(), panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
  axis.title=element_text(size=8), legend.position = 'bottom') +
  theme(legend.text=element_text(size=8))
tco_subscriber

## Constellation Total Opex with Error Bars
emissions %>%
  group_by(total_opex, constellation, opex_scenario) %>%
  summarise(value =mean(total_opex), error = sd(total_opex)) %>%
  ungroup() 
df7 <- data_summary(emissions, varname="total_opex", 
       groupnames=c("constellation", "opex_scenario"))
df7$opex_scenario=as.factor(df7$opex_scenario)
df7$Constellation = factor(df7$constellation)
df7$Capex = factor(df7$opex_scenario, levels=c('Low', 'Baseline', 'High'))

p <- ggplot(df7, aes(x=Constellation, y=(total_opex/1e6), 
   fill=Capex)) + geom_bar(stat="identity", position=position_dodge()) +
  geom_errorbar(aes(ymin=((total_opex/1e6))-sd/1e6, ymax=((total_opex/1e6))+sd/1e6), 
  width=.2, position=position_dodge(.9), color = 'orange', size = 0.3)
opex_cost <- p + scale_fill_brewer(palette="Paired") +
  labs(colour=NULL, title = "Total Operating (Opex) Costs", 
       subtitle = "Estimated for different maintenance cost scenarios with 
  \nerror bars representing 1 standard deviation.", 
       x = NULL, y = "Opex\n(Million US$ per Gbps)") + 
  scale_y_continuous(labels = function(y) format(y, 
  scientific = FALSE), expand = c(0, 0)) + 
  theme_minimal() + theme(strip.text.x = element_blank(),
  panel.border = element_blank(), panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
  axis.title=element_text(size=8), legend.position = 'bottom') +
  theme(legend.text=element_text(size=8))
opex_cost

## Total Opex per Subscriber with Error Bars
emissions %>%
  group_by(total_opex, constellation, opex_scenario, subscribers) %>%
  summarise(value =mean(total_opex/subscribers), error = sd(total_opex/subscribers)) %>%
  ungroup() 
df7 <- data_summary(emissions, varname="total_opex", 
  groupnames=c("constellation", "opex_scenario", "subscribers"))
df7$opex_scenario=as.factor(df7$opex_scenario)
df7$Constellation = factor(df7$constellation)
df7$Capex = factor(df7$opex_scenario, levels=c('Low', 'Baseline', 'High'))

p <- ggplot(df7, aes(x=Constellation, y=(total_opex)/subscribers, 
  fill=Capex)) + geom_bar(stat="identity", position=position_dodge()) +
  geom_errorbar(aes(ymin=((total_opex)/subscribers)-sd, 
  ymax=((total_opex)/subscribers)+sd), width=.2, 
  position=position_dodge(0.9), color = 'orange', size = 0.3)
opex_cost <- p + scale_fill_brewer(palette="Paired") +
  labs(colour=NULL, title = "Opex per User", 
  subtitle = "Estimated for different maintenance cost scenarios with 
  \nerror bars representing 1 standard deviation.", 
  x = NULL, y = "Opex\n(US$ per User)") + 
  scale_y_continuous(labels = function(y) format(y, 
  scientific = FALSE), expand = c(0, 0)) + theme_minimal() + 
  theme(strip.text.x = element_blank(), panel.border = element_blank(), 
  panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
  axis.line = element_line(colour = "black"), axis.title=element_text(size=8), 
  legend.position = 'bottom') + theme(legend.text=element_text(size=8))
opex_cost



## Combine Cost Plots ##
const_cost <- ggarrange(sat_costs, grd_costs, 
                        cap_cost, total_cost, 
                        nrow = 4, 
                        common.legend = T, legend="bottom", 
                        labels = c("A", "B", "C", "D"))
const_cost

pub_const_cost <- ggarrange(total_cost, 
                   cap_cost, ncol = 2, 
                   common.legend = T, legend="bottom", 
                   labels = c("a", "b"))
pub_const_cost

path = file.path(folder, 'figures', 'pub_cost_profile.tiff')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
tiff(path, units="in", width=7.5, height=5, res=720)
print(pub_const_cost)
dev.off()

path = file.path(folder, 'figures', 
                 'constellation_cost_profile.tiff')
dir.create(file.path(folder, 'figures'), 
           showWarnings = FALSE)
tiff(path, units="in", width=7, height=10, res=380)
print(const_cost)
dev.off()


  

 













