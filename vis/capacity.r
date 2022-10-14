library(ggpubr)
library(ggplot2)
library(dplyr)
library(tidyverse)

# Set default folder
folder <- dirname(rstudioapi::getSourceEditorContext()$path)

#Load the data
folder <- dirname(rstudioapi::getSourceEditorContext()$path)
data <- read.csv(file.path(folder, "uq_results.csv"))

# INDIVIDUAL PLOTS WITH ERROR BARS #
data <- select(data, channel_capacity, constellation, cnr_scenario, 
              channel_capacity, capacity_per_single_satellite, 
              capacity_per_area_mbps.sqkm, constellation_capacity, 
              cnr
              )


################################################
##plot1 = Channel capacity with Bars
df = data %>%
  group_by(constellation, cnr_scenario) %>%
  summarize(mean=mean(channel_capacity),
    sd=sd(channel_capacity))

df$cnr_scenario=as.factor(df$cnr_scenario)
df$Constellation = factor(df$constellation)
df$CNR = factor(df$cnr_scenario,
                 levels=c('Low (<7.5 dB)', 'Baseline(7.6 - 10.5 dB)', 'High(>13.5 dB)'),
                 labels=c('Low', 'Baseline', 'High'))

chn_capacity <- 
  ggplot(df, aes(x=Constellation, y=mean/1e3, fill=CNR)) + 
  geom_bar(stat="identity", position=position_dodge(), width = 0.98) +
  geom_errorbar(aes(ymin=mean/1e3-sd/1e3, 
                    ymax=mean/1e3+sd/1e3), width=.2,
                position=position_dodge(.9), color = 'black', size = 0.3) +
  scale_fill_brewer(palette="Paired") + theme_minimal() + 
  theme(legend.position = 'right') + 
  labs(colour=NULL, title = "Single Satellite Channel Capacity", 
       subtitle = "By QoS scenario (Error bars: 1SD).", 
       x = NULL, y = "Capacity (Gbps)", fill='Scenario') +
  scale_y_continuous(labels = function(y) format(y, 
                                                 scientific = FALSE), expand = c(0, 0)) +theme_minimal() +
  theme(strip.text.x = element_blank(), panel.border = element_blank(),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        axis.line = element_line(colour = "black")) + 
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) + 
  theme(legend.text=element_text(size=8), plot.subtitle = element_text(size = 8),
        plot.title = element_text(size = 10))


################################################
##plot2 = Single Satellite Capacity with bars
df = data %>%
  group_by(constellation, cnr_scenario) %>%
  summarise(mean =mean(capacity_per_single_satellite),
            sd = sd(capacity_per_single_satellite)) %>%
  ungroup() 

df$cnr_scenario=as.factor(df$cnr_scenario)
df$Constellation = factor(df$constellation)
df$CNR = factor(df$cnr_scenario,
                 levels=c('Low (<7.5 dB)', 'Baseline(7.6 - 10.5 dB)', 'High(>13.5 dB)'),
                 labels=c('Low', 'Baseline', 'High'))

sat_capacity <- ggplot(df, aes(x=Constellation, y=mean/1e3, fill=CNR)) + 
  geom_bar(stat="identity", position=position_dodge(), width = 0.98) +
  geom_errorbar(aes(ymin=mean/1e3-sd/1e3, 
                    ymax=mean/1e3+sd/1e3), width=.2,
                position=position_dodge(.9), color = 'black', size = 0.3) +
  scale_fill_brewer(palette="Paired") + theme_minimal() + 
  theme(legend.position = 'bottom') + labs(colour=NULL, 
                                           title = "Single Satellite Aggregate Capacity", 
                                           subtitle = "By QoS scenario (Error bars: 1SD).", 
                                           x = NULL, y = "Capacity (Gbps)", fill='Scenario') + 
  scale_y_continuous(labels = function(y) format(y, 
                                                 scientific = FALSE), expand = c(0, 0), limits = c(0, 30)) + 
  theme_minimal() +  theme(strip.text.x = element_blank(),
                           panel.border = element_blank(), panel.grid.major = element_blank(),
                           panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) + 
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) + 
  theme(legend.text=element_text(size=8), plot.subtitle = element_text(size = 8),
        plot.title = element_text(size = 10))


################################################
##plot3 = Constellation capacity with error bars

df = data %>%
  group_by(constellation, cnr_scenario) %>%
  summarise(mean =mean(constellation_capacity),
            sd = sd(constellation_capacity)) %>%
  ungroup() 

df$cnr_scenario=as.factor(df$cnr_scenario)
df$Constellation = factor(df$constellation)
df$CNR = factor(df$cnr_scenario,
                 levels=c('Low (<7.5 dB)', 'Baseline(7.6 - 10.5 dB)', 'High(>13.5 dB)'),
                 labels=c('Low', 'Baseline', 'High'))

const_capacity <- 
  ggplot(df, aes(x=Constellation, y=mean/1e6, 
                                  fill=CNR)) + 
  geom_bar(stat = "identity", position=position_dodge(), width = 0.98) +
  geom_errorbar(aes(ymin=mean/1e6-sd/1e6, 
                    ymax=mean/1e6+sd/1e6), width=.2,
                position=position_dodge(.9), color = 'black', size = 0.3) +
  scale_fill_brewer(palette="Paired") + theme_minimal() +
  labs(colour=NULL, title = "Aggregate Constellation Capacity", 
       subtitle = "By QoS scenario (Error bars: 1SD).", 
       x = NULL, y = "Capacity (Tbps)", fill='Scenario') +
  scale_y_continuous(labels = function(y) format(y, 
                                                 scientific = FALSE), expand = c(0, 0), limits = c(0, 130)) + 
  theme_minimal() + theme(strip.text.x = element_blank(),
                          panel.border = element_blank(), panel.grid.major = element_blank(),
                          panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
                          axis.title=element_text(size=8), legend.position = 'bottom') + 
  theme(legend.text=element_text(size=8), plot.subtitle = element_text(size = 8),
        plot.title = element_text(size = 10))


######################################
##plot4 = capacity_subscriber

data2 <- read.csv(file.path(folder, "mission_emission_results.csv"))

df = data2 %>%
  group_by(constellation, subscriber_scenario) %>%
  summarize(mean=mean(capacity_per_user),
            sd=sd(capacity_per_user))

df$subscriber_scenario=as.factor(df$subscriber_scenario)
df$Constellation = factor(df$constellation)
df$subscriber_scenario = factor(df$subscriber_scenario,
                                 levels=c('Low', 'Baseline', 'High'),
                                 labels=c('Low', 'Baseline', 'High'))

capacity_subscriber <-
  ggplot(df, aes(x = Constellation, y = mean,
                  fill = subscriber_scenario)) + geom_bar(stat = "identity", width = 0.98,
                                                          position=position_dodge()) +
  geom_errorbar(aes(ymin=mean-sd,
                    ymax=mean+sd), width=.2,
                position=position_dodge(.9), color = 'black', size = 0.3) +
  scale_fill_brewer(palette="Paired") +
  labs(colour=NULL, title = "Capacity per User",
       subtitle = "By subscriber scenario (Error bars: 1SD).",
       x = NULL, y = "Capacity (Mbps/user)", fill ='Scenario') +
  scale_y_continuous(labels = function(y) format(y, scientific = FALSE),
                     expand = c(0, 0), limits = c(0, 150)) + theme_minimal() +
  theme(strip.text.x = element_blank(),
        panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) +
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) +
  theme(legend.text=element_text(size=8), plot.subtitle = element_text(size = 8),
        plot.title = element_text(size = 10))


####################################
## Combine all the capacity plots ##
pub_cap <- ggarrange(
  chn_capacity, 
  sat_capacity, 
  const_capacity, 
  capacity_subscriber, 
  nrow = 2,ncol = 2, common.legend = T, 
  legend="bottom", labels = c("a", "b", "c", "d"))

path = file.path(folder, 'figures', 'pub_capacity_profile.tiff')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
tiff(path, units="in", width=6, height=6, res=480)
print(pub_cap)
dev.off()


