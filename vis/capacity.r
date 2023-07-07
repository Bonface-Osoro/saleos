library(ggpubr)
library(ggplot2)
library(tidyverse)
# install.packages("ggtext")
library(ggtext)

# Set default folder
folder <- dirname(rstudioapi::getSourceEditorContext()$path)

#Load the data
folder <- dirname(rstudioapi::getSourceEditorContext()$path)
data <- read.csv(file.path(folder, '..', 'results', "interim_results.csv"))

##############################
##Channel capacity with Bars##
##############################

df = data %>%
  group_by(constellation, cnr_scenario) %>%
  summarize(mean = mean(channel_capacity),
            sd = sd(channel_capacity))

df$cnr_scenario = as.factor(df$cnr_scenario)
df$Constellation = factor(df$constellation)
df$CNR = factor(
  df$cnr_scenario,
  levels = c('Low (<7.5 dB)', 'Baseline(7.6 - 10.5 dB)', 'High(>13.5 dB)'),
  labels = c('Low', 'Baseline', 'High')
)

chn_capacity <- ggplot(df, aes(x = Constellation, y = mean / 1e3, fill = CNR)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean / 1e3 - sd / 1e3,
        ymax = mean / 1e3 + sd / 1e3),
    width = .2,
    position = position_dodge(.98),
    color = 'black',
    size = 0.2
  ) +
  scale_fill_brewer(palette = "Dark2") + theme_minimal() +
  theme(legend.position = 'right') +
  labs(
    colour = NULL,
    title = " ",
    subtitle = "a",
    x = NULL,
    y = "Channel Capacity\n(Gbps)",
    fill = 'QoS\nScenario'
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) + theme_minimal() +
  theme(axis.title.y = element_text(size = 6),
        strip.text.x = element_blank(),
        panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(size = 6),
        axis.text.y = element_text(size = 6),
        axis.line.x  = element_line(size = 0.15),
        axis.line.y  = element_line(size = 0.15),
        axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = 'bottom', axis.title = element_text(size = 6)) +
  theme(
    legend.title = element_text(size = 6),
    legend.text = element_text(size =6),
    plot.subtitle = element_text(size = 8, face = "bold"),
    plot.title = element_text(size = 10, face = "bold", hjust = -0.45, vjust=2.12)
  )

#######################################
##Single Satellite Capacity with bars##
#######################################

df = data %>%
  group_by(constellation, cnr_scenario) %>%
  summarise(
    mean = mean(capacity_per_single_satellite),
    sd = sd(capacity_per_single_satellite)
  ) %>%
  ungroup()

df$cnr_scenario = as.factor(df$cnr_scenario)
df$Constellation = factor(df$constellation)
df$CNR = factor(
  df$cnr_scenario,
  levels = c('Low (<7.5 dB)', 'Baseline(7.6 - 10.5 dB)', 'High(>13.5 dB)'),
  labels = c('Low', 'Baseline', 'High')
)

sat_capacity <-
  ggplot(df, aes(x = Constellation, y = mean / 1e3, fill = CNR)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean / 1e3 - sd / 1e3,
        ymax = mean / 1e3 + sd / 1e3),
    width = .2,
    position = position_dodge(.98),
    color = 'black',
    size = 0.2
  ) +
  scale_fill_brewer(palette = "Dark2") + theme_minimal() +
  theme(legend.position = 'bottom') + labs(
    colour = NULL,
    title = " ",
    subtitle = "b",
    x = NULL,
    y = "Satellite Capacity\n(Gbps)",
    fill = 'QoS\nScenario'
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0),
    limits = c(0, 30)
  ) +
  theme_minimal() +  theme(axis.title.y = element_text(size = 6),
                           strip.text.x = element_blank(),
                           panel.border = element_blank(),
                           panel.grid.major = element_blank(),
                           panel.grid.minor = element_blank(),
                           axis.line.x  = element_line(size = 0.15),
                           axis.line.y  = element_line(size = 0.15),
                           axis.text.x = element_text(size = 6),
                           axis.text.y = element_text(size = 6),
                           axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = 'bottom', axis.title = element_text(size = 6)) +
  theme(
    legend.title = element_text(size = 6),
    legend.text = element_text(size =6),
    plot.subtitle = element_text(size = 8, face = "bold"),
    plot.title = element_text(size = 10, face = "bold", hjust = -0.45, vjust=2.12)
  )


##########################################
##Constellation capacity with error bars##
##########################################

df = data %>%
  group_by(constellation, cnr_scenario) %>%
  summarise(mean = mean(constellation_capacity * 0.65),
            sd = sd(constellation_capacity * 0.65)) %>%
  ungroup()

df$cnr_scenario = as.factor(df$cnr_scenario)
df$Constellation = factor(df$constellation)
df$CNR = factor(
  df$cnr_scenario,
  levels = c('Low (<7.5 dB)', 'Baseline(7.6 - 10.5 dB)', 'High(>13.5 dB)'),
  labels = c('Low', 'Baseline', 'High')
)

const_capacity <-
  ggplot(df, aes(x = Constellation, y = (mean) * 0.65 / 1e6,
                 fill = CNR)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean * 0.65 / 1e6 - sd * 0.65 / 1e6,
        ymax = mean * 0.65 / 1e6 + sd * 0.65 / 1e6),
    width = .2,
    position = position_dodge(.98),
    color = 'black',
    size = 0.2
  ) +
  scale_fill_brewer(palette = "Dark2") +
  labs(
    colour = NULL,
    title = " ",
    subtitle = "c",
    x = NULL,
    y = "Total Usable Constellation\nCapacity (Tbps)",
    fill = 'QoS\nScenario'
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0),
    limits = c(0, 60)
  ) +
  theme_minimal() + theme(axis.title.y = element_text(size = 6),
                          strip.text.x = element_blank(),
                          panel.border = element_blank(),
                          panel.grid.major = element_blank(),
                          panel.grid.minor = element_blank(),
                          axis.line = element_line(colour = "black"),
                          axis.text.x = element_text(size = 6),
                          axis.text.y = element_text(size = 6),
                          axis.title = element_text(size = 6),
                          axis.line.x  = element_line(size = 0.15),
                          axis.line.y  = element_line(size = 0.15),
                          legend.position = 'bottom'
  ) +
  theme(
    legend.title = element_text(size = 6),
    legend.text = element_text(size =6),
    plot.subtitle = element_text(size = 8, face = "bold"),
    plot.title = element_text(size = 10, face = "bold", hjust = -0.45, vjust=2.12)
  )


#######################
##capacity_subscriber##
#######################

folder <- dirname(rstudioapi::getSourceEditorContext()$path)
data2 <- read.csv(file.path(folder, '..', 'Results', "final_results.csv"))

df = data2 %>%
  group_by(constellation, subscriber_scenario) %>%
  summarize(mean = mean(monthly_gb),
            sd = sd(monthly_gb))

df$subscriber_scenario = as.factor(df$subscriber_scenario)
df$Constellation = factor(df$constellation)
df$subscriber_scenario = factor(
  df$subscriber_scenario,
  levels = c('subscribers_low', 'subscribers_baseline', 'subscribers_high'),
  labels = c('Low', 'Baseline', 'High')
)

capacity_subscriber <-
  ggplot(df, aes(x = Constellation, y = mean,
                 fill = subscriber_scenario)) +
  geom_bar(stat = "identity",
           width = 0.98,
           position = position_dodge()) +
  geom_errorbar(
    aes(ymin = mean - sd,
        ymax = mean + sd),
    width = .2,
    position = position_dodge(.98),
    color = 'black',
    size = 0.2
  ) +
  scale_fill_brewer(palette = "Dark2") +
  labs(
    colour = NULL,
    title = " ",
    subtitle = "d",
    x = NULL,
    y = "Mean Monthly Traffic\n(GB/User)",
    fill = 'Adoption\nScenario'
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0),
    #limits = c(0, 35)
  ) + theme_minimal() +
  theme(axis.title.y = element_text(size = 6),
        strip.text.x = element_blank(),
        panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(size = 6),
        axis.text.y = element_text(size = 6),
        axis.line.x  = element_line(size = 0.15),
        axis.line.y  = element_line(size = 0.15),
        axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = 'bottom', axis.title = element_text(size = 6)) +
  theme(
    legend.title = element_text(size = 6),
    legend.text = element_text(size =6),
    plot.subtitle = element_text(size = 8, face = "bold"),
    plot.title = element_text(size = 10, face = "bold", hjust = -0.45, vjust=2.12)
  )


################################
##Mean capacity per subscriber##
################################

df = data2 %>%
  group_by(constellation, subscriber_scenario) %>%
  summarize(mean = mean(capacity_per_user),
            sd = sd(capacity_per_user))

df$subscriber_scenario = as.factor(df$subscriber_scenario)
df$Constellation = factor(df$constellation)
df$subscriber_scenario = factor(
  df$subscriber_scenario,
  levels = c('subscribers_low', 'subscribers_baseline', 'subscribers_high'),
  labels = c('Low', 'Baseline', 'High')
)

capacity_per_user <-
  ggplot(df, aes(x = Constellation, y = mean,
                 fill = subscriber_scenario)) +
  geom_bar(stat = "identity",
           width = 0.98,
           position = position_dodge()) +
  geom_errorbar(
    aes(ymin = mean - sd,
        ymax = mean + sd),
    width = .2,
    position = position_dodge(.98),
    color = 'black',
    size = 0.2
  ) +
  scale_fill_brewer(palette = "Dark2") +
  labs(
    colour = NULL,
    title = " ",
    subtitle = "e",
    x = NULL,
    y = "Mean Capacity\n(Mbps/User)",
    fill = 'Adoption\nScenario'
  ) + 
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0),
    #limits = c(0, 35)
  ) + theme_minimal() +
  theme(axis.title.y = element_text(size = 6),
        strip.text.x = element_blank(),
        panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(size = 6),
        axis.text.y = element_text(size = 6),
        axis.line.x  = element_line(size = 0.15),
        axis.line.y  = element_line(size = 0.15),
        axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = 'bottom', axis.title = element_text(size = 6)) +
  theme(
    legend.title = element_text(size = 6),
    legend.text = element_text(size =6),
    plot.subtitle = element_text(size = 8, face = "bold"),
    plot.title = element_text(size = 10, face = "bold", hjust = -0.45, vjust=2.12)
  )

##########################
##Average users per area##
##########################

df = data2 %>%
  group_by(constellation, subscriber_scenario) %>%
  summarize(mean = mean(user_per_area),
            sd = sd(user_per_area))

df$subscriber_scenario = as.factor(df$subscriber_scenario)
df$Constellation = factor(df$constellation)
df$subscriber_scenario = factor(
  df$subscriber_scenario,
  levels = c('subscribers_low', 'subscribers_baseline', 'subscribers_high'),
  labels = c('Low', 'Baseline', 'High')
)

per_user_area <-
  ggplot(df, aes(x = Constellation, y = mean,
                 fill = subscriber_scenario)) +
  geom_bar(stat = "identity",
           width = 0.98,
           position = position_dodge()) +
  scale_fill_brewer(palette = "Dark2") +
  labs(
    colour = NULL,
    title = " ",
    subtitle = "f",
    x = NULL,
    fill = 'Adoption\nScenario'
  ) + ylab('Mean Subscribers<br>(Users/km<sup>2</sup>)') +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0),
  ) + theme_minimal() +
  theme(axis.title.y = element_markdown(size = 6),
        strip.text.x = element_blank(),
        panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(size = 6),
        axis.text.y = element_text(size = 6),
        axis.line.x  = element_line(size = 0.15),
        axis.line.y  = element_line(size = 0.15),
        axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = 'bottom', axis.title = element_text(size = 6)) +
  theme(
    legend.title = element_text(size = 6),
    legend.text = element_text(size =6),
    plot.subtitle = element_text(size = 8, face = "bold"),
    plot.title = element_text(size = 10, face = "bold", hjust = -0.45, vjust=2.12)
  )


####################################
## Combine all the capacity plots ##
####################################

#Row 1, subplots a-c
pub_qos <- ggarrange(
  chn_capacity,
  sat_capacity,
  const_capacity,
  ncol = 3,
  common.legend = T,
  legend = "bottom",
  font.label = list(size = 9)
)

#Row 2, subplots d-f
pub_subs <- ggarrange(
  capacity_subscriber,
  capacity_per_user,
  per_user_area,
  ncol = 3,
  common.legend = T,
  legend = "bottom",
  font.label = list(size = 9)
)

#Assemble rows 1 and 2
pub_cap <- ggarrange(
  pub_qos,
  pub_subs,
  nrow = 2,
  common.legend = F,
  legend = "bottom",
  font.label = list(size = 9)
)

dir.create(file.path(folder, 'figures'), showWarnings = FALSE)

path = file.path(folder, 'figures', 'capacity_profile.png')
png(
  path,
  units = "in",
  width = 5.5,
  height = 4,
  res = 480
)
print(pub_cap)
dev.off()
