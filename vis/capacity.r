library(ggpubr)
library(ggplot2)
library(tidyverse)
library(ggtext)

#Load the data
folder <- dirname(rstudioapi::getSourceEditorContext()$path)
data <-
  read.csv(file.path(
    folder,
    '..',
    'data',
    'processed',
    'interim_results_capacity.csv'
  ))
data$constellation = factor(data$constellation, 
                            levels = c('Starlink','OneWeb', 'Kuiper', 'GEO'))

#########################
##Channel capacity with##
#########################
df = data %>%
  group_by(constellation, cnr_scenario) %>%
  summarize(mean = mean(channel_capacity_mbps),
            sd = sd(channel_capacity_mbps),
            mean_gbps = round(mean(channel_capacity_mbps)/1e3,2),
            sd_gbps = round(sd(channel_capacity_mbps)/1e3,2))

df$cnr_scenario = as.factor(df$cnr_scenario)
df$CNR = factor(
  df$cnr_scenario,
  levels = c('low', 'baseline', 'high'),
  labels = c('Low', 'Baseline', 'High')
)

chn_capacity <-
  ggplot(df, aes(x = constellation, y = mean / 1e3, fill = CNR)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean / 1e3 - sd / 1e3,
        ymax = mean / 1e3 + sd / 1e3),
    width = .2,
    position = position_dodge(.98),
    color = 'red',
    size = 0.2
  ) +
  scale_fill_viridis_d(direction = -1) + 
  labs(
    colour = NULL,
    title = " ",
    subtitle = "A",
    x = NULL,
    y = "Channel Capacity \n(Gbps)",
    fill = 'QoS Scenario'
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE), limit = c(0, 0.7),
    expand = c(0, 0)
  ) + 
  theme(
    axis.title.y = element_text(size = 8),
    axis.text.x = element_text(size = 8),
    axis.text.y = element_text(size = 8),
    legend.position = 'bottom',
    axis.title = element_text(size = 8),
    legend.title = element_text(size = 8),
    legend.text = element_text(size = 8),
    plot.subtitle = element_text(size = 10, face = "bold"),
    plot.title = element_text(
      size = 10,
      face = "bold",
      hjust = -0.45,
      vjust = 2.12
    )
  )

#############################
##Single Satellite Capacity##
#############################

df = data %>%
  group_by(constellation, cnr_scenario) %>%
  summarise(
    mean = mean(capacity_per_single_satellite_mbps),
    sd = sd(capacity_per_single_satellite_mbps),
    mean_gbps = round(mean(capacity_per_single_satellite_mbps)/1e3,2),
    sd_gbps = round(sd(capacity_per_single_satellite_mbps)/1e3,1)
  ) %>%
  ungroup()

df$cnr_scenario = as.factor(df$cnr_scenario)

df$CNR = factor(
  df$cnr_scenario,
  levels = c('low', 'baseline', 'high'),
  labels = c('Low', 'Baseline', 'High')
)

sat_capacity <-
  ggplot(df, aes(x = constellation, y = mean / 1e3, fill = CNR)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean / 1e3 - sd / 1e3,
        ymax = mean / 1e3 + sd / 1e3),
    width = .2,
    position = position_dodge(.98),
    color = 'red',
    size = 0.2
  ) +
  scale_fill_viridis_d(direction = -1) + 
  labs(
    colour = NULL,
    title = " ",
    subtitle = "B",
    x = NULL,
    y = "Satellite Capacity\n(Gbps)",
    fill = 'QoS Scenario'
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0),
    limits = c(0, 980)
  ) +
  theme(
    axis.title.y = element_text(size = 8),
    axis.text.x = element_text(size = 8),
    axis.text.y = element_text(size = 8),
    legend.position = 'bottom',
    axis.title = element_text(size = 8),
    legend.title = element_text(size = 8),
    legend.text = element_text(size = 8),
    plot.subtitle = element_text(size = 10, face = "bold"),
    plot.title = element_text(
      size = 10,
      face = "bold",
      hjust = -0.45,
      vjust = 2.12
    )
  )


#######################################
##Total Usable Constellation capacity##
#######################################

df = data %>%
  group_by(constellation, cnr_scenario) %>%
  summarise(
    mean = mean(constellation_capacity_mbps * 0.65),
    sd = sd(constellation_capacity_mbps * 0.65),
    mean_gbps = round(mean(constellation_capacity_mbps * 0.65)/1e6,2),
    sd_gbps = round(sd(constellation_capacity_mbps * 0.65)/1e6,1)
  ) %>%
  ungroup()

df$cnr_scenario = as.factor(df$cnr_scenario)

df$CNR = factor(
  df$cnr_scenario,
  levels = c('low', 'baseline', 'high'),
  labels = c('Low', 'Baseline', 'High')
)

const_capacity <-
  ggplot(df, aes(
    x = constellation,
    y = (mean) * 0.65 / 1e6,
    fill = CNR
  )) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(
      ymin = mean * 0.65 / 1e6 - sd * 0.65 / 1e6,
      ymax = mean * 0.65 / 1e6 + sd * 0.65 / 1e6
    ),
    width = .2,
    position = position_dodge(.98),
    color = 'red',
    size = 0.2
  ) +
  scale_fill_viridis_d(direction = -1) +
  labs(
    colour = NULL,
    title = " ",
    subtitle = "C",
    x = NULL,
    y = "Total Usable Constellation\nCapacity (Tbps)",
    fill = 'QoS Scenario'
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0),
    limits = c(0, 45)
  ) +
  theme(
    axis.title.y = element_text(size = 8),
    axis.text.x = element_text(size = 8),
    axis.text.y = element_text(size = 8),
    legend.position = 'bottom',
    axis.title = element_text(size = 8),
    legend.title = element_text(size = 8),
    legend.text = element_text(size = 8),
    plot.subtitle = element_text(size = 10, face = "bold"),
    plot.title = element_text(
      size = 10,
      face = "bold",
      hjust = -0.45,
      vjust = 2.12
    )
  )


################################
##Mean capacity per subscriber##
################################

folder <- dirname(rstudioapi::getSourceEditorContext()$path)
data2 <- read.csv(file.path(folder, '..', 'results', 'final_capacity_results.csv'))
data2$constellation = factor(data2$constellation, 
                             levels = c('Starlink','OneWeb', 'Kuiper', 'GEO'))

df = data2 %>%
  group_by(constellation, subscriber_scenario) %>%
  summarize(mean = mean(capacity_per_user),
            sd = sd(capacity_per_user),
  )

df$subscriber_scenario = as.factor(df$subscriber_scenario)

df$subscriber_scenario = factor(
  df$subscriber_scenario,
  levels = c(
    'subscribers_low',
    'subscribers_baseline',
    'subscribers_high'
  ),
  labels = c('Low', 'Baseline', 'High')
)

capacity_per_user <-
  ggplot(df, aes(x = constellation, y = mean,
                 fill = subscriber_scenario)) +
  geom_bar(stat = "identity",
           width = 0.98,
           position = position_dodge()) +
  geom_errorbar(
    aes(ymin = mean - sd,
        ymax = mean + sd),
    width = .2,
    position = position_dodge(.98),
    color = 'red',
    size = 0.2
  ) +
  scale_fill_viridis_d(direction = -1) +
  labs(
    colour = NULL,
    title = " ",
    subtitle = "D",
    x = NULL,
    y = "Mean Peak Capacity\n(Mbps/User)",
    fill = 'Adoption Scenario'
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),limit = c(0, 159),
    expand = c(0, 0),
  ) + 
  theme(
    axis.title.y = element_text(size = 8),
    axis.text.x = element_text(size = 8),
    axis.text.y = element_text(size = 8),
    legend.position = 'bottom',
    axis.title = element_text(size = 8),
    legend.title = element_text(size = 8),
    legend.text = element_text(size = 8),
    plot.subtitle = element_text(size = 10, face = "bold"),
    plot.title = element_text(
      size = 10,
      face = "bold",
      hjust = -0.45,
      vjust = 2.12
    )
  )

####################
##Monthly Traffic ##
####################

df = data2 %>%
  group_by(constellation, subscriber_scenario) %>%
  summarize(mean = mean(monthly_gb),
            sd = sd(monthly_gb))

df$subscriber_scenario = as.factor(df$subscriber_scenario)

df$subscriber_scenario = factor(
  df$subscriber_scenario,
  levels = c(
    'subscribers_low',
    'subscribers_baseline',
    'subscribers_high'
  ),
  labels = c('Low', 'Baseline', 'High')
)

monthly_traffic <-
  ggplot(df, aes(x = constellation, y = mean,
                 fill = subscriber_scenario)) +
  geom_bar(stat = "identity",
           width = 0.98,
           position = position_dodge()) +
  geom_errorbar(
    aes(ymin = mean - sd,
        ymax = mean + sd),
    width = .2,
    position = position_dodge(.98),
    color = 'red',
    size = 0.2
  ) +
  scale_fill_viridis_d(direction = -1) +
  labs(
    colour = NULL,
    title = " ",
    subtitle = "E",
    x = NULL,
    y = "Mean Peak Monthly \nTraffic (GB/User)",
    fill = 'Adoption Scenario'
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE), limit = c(0, 2200),
    expand = c(0, 0),
  ) + 
  theme(
    axis.title.y = element_text(size = 8),
    axis.text.x = element_text(size = 8),
    axis.text.y = element_text(size = 8),
    legend.position = 'bottom',
    axis.title = element_text(size = 8),
    legend.title = element_text(size = 8),
    legend.text = element_text(size = 8),
    plot.subtitle = element_text(size = 10, face = "bold")
  )


##########################
##Average users per area##
##########################

df = data2 %>%
  group_by(constellation, subscriber_scenario) %>%
  summarize(mean = round(mean(user_per_area),5),
            sd = round(sd(user_per_area),6))

df$subscriber_scenario = as.factor(df$subscriber_scenario)

df$subscriber_scenario = factor(
  df$subscriber_scenario,
  levels = c(
    'subscribers_low',
    'subscribers_baseline',
    'subscribers_high'
  ),
  labels = c('Low', 'Baseline', 'High')
)

per_user_area <-
  ggplot(df, aes(x = constellation, y = mean,
                 fill = subscriber_scenario)) +
  geom_bar(stat = "identity",
           width = 0.98,
           position = position_dodge()) +
  geom_text(
    aes(label = as.character(signif(mean, 2))),
    size = 2,
    position = position_dodge(1),
    vjust = 0.5,
    hjust = -0.1,
    angle = 90
  ) +
  scale_fill_viridis_d(direction = -1) +
  labs(
    colour = NULL,
    title = " ",
    subtitle = "F",
    x = NULL,
    y = "Mean Users (Users/km²)",
    fill = 'Adoption Scenario'
  ) + 
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0),
    limits = c(0, 0.0153)
  ) +
  theme(
    axis.title.y = element_markdown(size = 8),
    axis.text.x = element_text(size = 8),
    axis.text.y = element_text(size = 8),
    legend.position = 'bottom',
    axis.title = element_text(size = 8),
    legend.title = element_text(size = 8),
    legend.text = element_text(size = 8),
    plot.subtitle = element_text(size = 10, face = "bold"),
    plot.title = element_text(
      size = 10,
      face = "bold",
      hjust = -0.45,
      vjust = 2.12
    )
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
  capacity_per_user,
  monthly_traffic,
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
path = file.path(folder, 'figures', 'g_capacity_metrics.png')
png(
  path,
  units = "in",
  width = 9,
  height = 6,
  res = 480
)
print(pub_cap)
dev.off()