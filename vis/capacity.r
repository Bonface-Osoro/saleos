library(ggpubr)
library(ggplot2)
library(tidyverse)


# Set default folder
folder <- dirname(rstudioapi::getSourceEditorContext()$path)

#Load the data
folder <- dirname(rstudioapi::getSourceEditorContext()$path)
data <- read.csv(file.path(folder, "uq_results.csv"))

# INDIVIDUAL PLOTS WITH ERROR BARS #
data <- select(
  data,
  constellation,
  cnr_scenario,
  channel_capacity,
  capacity_per_single_satellite,
  constellation_capacity,
  cnr
)


######################################
##plot1 = Channel capacity with Bars
######################################

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

chn_capacity <-
  ggplot(df, aes(x = Constellation, y = mean / 1e3, fill = CNR)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean / 1e3 - sd / 1e3,
        ymax = mean / 1e3 + sd / 1e3),
    width = .2,
    position = position_dodge(.9),
    color = 'black',
    size = 0.2
  ) +
  scale_fill_brewer(palette = "Dark2") + theme_minimal() +
  theme(legend.position = 'right') +
  labs(
    colour = NULL,
    title = " ",
    subtitle = "Channel Capacity",
    x = NULL,
    y = "Capacity (Gbps)",
    fill = 'Scenario'
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
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) +
  theme(
    legend.title = element_text(size = 6),
    legend.text = element_text(size =6),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10, face = "bold")
  )


######################################
##plot2 = Single Satellite Capacity with bars
######################################

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
    position = position_dodge(.9),
    color = 'black',
    size = 0.2
  ) +
  scale_fill_brewer(palette = "Dark2") + theme_minimal() +
  theme(legend.position = 'bottom') + labs(
    colour = NULL,
    title = " ",
    subtitle = "Satellite Capacity",
    x = NULL,
    y = "Capacity (Gbps)",
    fill = 'Scenario'
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
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) +
  theme(
    legend.title = element_text(size = 6),
    legend.text = element_text(size =6),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10, face = "bold")
  )


######################################
##plot3 = Constellation capacity with error bars
######################################

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
    position = position_dodge(.9),
    color = 'black',
    size = 0.2
  ) +
  scale_fill_brewer(palette = "Dark2") +
  labs(
    colour = NULL,
    title = " ",
    subtitle = "Usable Constellation Capacity",
    x = NULL,
    y = "Capacity (Tbps)",
    fill = 'Scenario'
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
    axis.title = element_text(size = 8),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    legend.position = 'bottom'
  ) +
  theme(
    legend.title = element_text(size = 6),
    legend.text = element_text(size =6),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10, face = "bold")
  )


######################################
##plot4 = capacity_subscriber
######################################

data2 <- read.csv(file.path(folder, "mission_emission_results.csv"))

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
    position = position_dodge(.9),
    color = 'black',
    size = 0.2
  ) +
  scale_fill_brewer(palette = "Accent") +
  labs(
    colour = NULL,
    title = " ",
    subtitle = "Monthly Traffic",
    x = NULL,
    y = "Traffic (GB/user)",
    fill = 'Scenario'
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
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) +
  theme(
    legend.title = element_text(size = 6),
    legend.text = element_text(size =6),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10, face = "bold")
  )


######################################
##plot5 = Mean capacity per subscriber
######################################

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
    position = position_dodge(.9),
    color = 'black',
    size = 0.2
  ) +
  scale_fill_brewer(palette = "Accent") +
  labs(
    colour = NULL,
    title = " ",
    subtitle = "Mean Capacity per User",
    x = NULL,
    y = "Mean capacity (Mbps/user)",
    fill = 'Scenario'
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
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) +
  theme(
    legend.title = element_text(size = 6),
    legend.text = element_text(size =6),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10, face = "bold")
  )


##################################
##plot6 = Average users per area##
##################################

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
  scale_fill_brewer(palette = "Accent") +
  labs(
    colour = NULL,
    title = " ",
    subtitle = "Mean User per Area",
    x = NULL,
    y = 'Mean subscriber per (bquote(~km^2))',
    fill = 'Scenario'
  ) + ylab(bquote('Mean subscriber per '*km^2*'')) + 
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
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) +
  theme(
    legend.title = element_text(size = 6),
    legend.text = element_text(size =6),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10, face = "bold")
  )


####################################
## Combine all the capacity plots ##
####################################
pub_qos <- ggarrange(
  chn_capacity,
  sat_capacity,
  const_capacity,
  ncol = 3,
  labels = c("(A) Satellite Capacity results for different quality of service scenario"),
  common.legend = T,
  legend = "bottom",
  font.label = list(size = 9)
)


pub_subs <- ggarrange(
  capacity_subscriber,
  capacity_per_user,
  per_user_area,
  ncol = 3,
  labels = "(B) Global traffic and per user results by different subscriber scenario",
  common.legend = T,
  legend = "bottom",
  font.label = list(size = 9)
)


pub_cap <- ggarrange(
  pub_qos,
  pub_subs,
  nrow = 2,
  common.legend = T,
  legend = "bottom",
  font.label = list(size = 9)
)

path = file.path(folder, 'figures', 'pub_capacity_profile.tiff')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
tiff(
  path,
  units = "in",
  width = 6.5,
  height = 5,
  res = 480
)
print(pub_cap)
dev.off()
