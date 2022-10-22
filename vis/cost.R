library(ggpubr)
library(ggplot2)
library(dplyr)
library(tidyverse)


# Set default folder
folder <- dirname(rstudioapi::getSourceEditorContext()$path)

#Load the data
data <- read.csv(file.path(folder, "mission_emission_results.csv"))

# INDIVIDUAL PLOTS WITH ERROR BARS #
data <- select(
  data,
  constellation,
  total_cost_ownership,
  tco_per_user,
  capex_costs,
  capex_scenario,
  capex_per_user,
  total_opex,
  opex_scenario,
  opex_per_user,
  capex_per_capacity,
  opex_per_capacity,
  tco_per_capacity,
)


######################################
##plot1 = Constellation Capex 
######################################

df = data %>%
  group_by(constellation, capex_scenario) %>%
  summarize(mean = mean(capex_costs),
            sd = sd(capex_costs))

df$capex_scenario = as.factor(df$capex_scenario)
df$Constellation = factor(df$constellation)
df$capex = factor(df$capex_scenario,
                levels = c('Low', 'Baseline', 'High'))

constellation_capex <-
  ggplot(df, aes(x = Constellation, y = mean / 1e6, fill = capex)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean / 1e6 - sd / 1e6,
        ymax = mean / 1e6 + sd / 1e6),
    width = .2,
    position = position_dodge(.9),
    color = 'black',
    size = 0.3
  ) +
  scale_fill_brewer(palette = "Paired") + theme_minimal() +
  theme(legend.position = 'right') +
  labs(
    colour = NULL,
    title = "Capital Expenditure (Capex) Costs",
    subtitle = "By ground station and satelite \nlaunch scenario (Error bars: 1SD).",
    x = NULL,
    y = "Capex \n(Million US$)",
    fill = 'Scenario'
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) + theme_minimal() +
  theme(
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 7),
    axis.text.y = element_text(size = 7),
    axis.title.y = element_text(size = 7),
    axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) +
  theme(
    legend.title = element_text(size = 7),
    legend.text = element_text(size = 7),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10)
  )


#############################################
##plot2 = Constellation Total operating Costs
#############################################

df = data %>%
  group_by(constellation, opex_scenario) %>%
  summarize(mean = mean(total_opex),
            sd = sd(total_opex))

df$opex_scenario = as.factor(df$opex_scenario)
df$Constellation = factor(df$constellation)
df$opex = factor(df$opex_scenario,
                  levels = c('Low', 'Baseline', 'High'))

constellation_opex <-
  ggplot(df, aes(x = Constellation, y = mean / 1e6, fill = opex)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean / 1e6 - sd / 1e6,
        ymax = mean / 1e6 + sd / 1e6),
    width = .2,
    position = position_dodge(.9),
    color = 'black',
    size = 0.3
  ) +
  scale_fill_brewer(palette = "Paired") + theme_minimal() +
  theme(legend.position = 'right') +
  labs(
    colour = NULL,
    title = "Total Operating (Opex) Costs",
    subtitle = "By maintenance and staff \nscenario (Error bars: 1SD).",
    x = NULL,
    y = "Opex \n(Million US$)",
    fill = 'Scenario'
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) + theme_minimal() +
  theme(
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 7),
    axis.text.y = element_text(size = 7),
    axis.title.y = element_text(size = 7),
    axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) +
  theme(
    legend.title = element_text(size = 7),
    legend.text = element_text(size = 7),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10)
  )


#############################################
##plot3 = Constellation Total Cost of Ownership
#############################################

df = data %>%
  group_by(constellation, capex_scenario) %>%
  summarize(mean = mean(total_cost_ownership),
            sd = sd(total_cost_ownership))

df$capex_scenario = as.factor(df$capex_scenario)
df$Constellation = factor(df$constellation)
df$capex = factor(df$capex_scenario,
                 levels = c('Low', 'Baseline', 'High'))

constellation_tco <-
  ggplot(df, aes(x = Constellation, y = mean / 1e6, fill = capex)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean / 1e6 - sd / 1e6,
        ymax = mean / 1e6 + sd / 1e6),
    width = .2,
    position = position_dodge(.9),
    color = 'black',
    size = 0.3
  ) +
  scale_fill_brewer(palette = "Paired") + theme_minimal() +
  theme(legend.position = 'right') +
  labs(
    colour = NULL,
    title = "Total Cost of Ownership (TCO)",
    subtitle = "By capex scenario (Error bars: 1SD).",
    x = NULL,
    y = "Opex \n(Million US$)",
    fill = 'Scenario'
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) + theme_minimal() +
  theme(
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 7),
    axis.text.y = element_text(size = 7),
    axis.title.y = element_text(size = 7),
    axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) +
  theme(
    legend.title = element_text(size = 7),
    legend.text = element_text(size = 7),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10)
  )


#############################################
##plot4 = Constellation Capex per User
#############################################

df = data %>%
  group_by(constellation, capex_scenario) %>%
  summarize(mean = mean(capex_per_user),
            sd = sd(capex_per_user))

df$capex_scenario = as.factor(df$capex_scenario)
df$Constellation = factor(df$constellation)
df$capex = factor(df$capex_scenario,
                  levels = c('Low', 'Baseline', 'High'))

constellation_capex_per_user <-
  ggplot(df, aes(x = Constellation, y = mean, fill = capex)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean - sd,
        ymax = mean + sd),
    width = .2,
    position = position_dodge(.9),
    color = 'black',
    size = 0.3
  ) +
  scale_fill_brewer(palette = "Paired") + theme_minimal() +
  theme(legend.position = 'right') +
  labs(
    colour = NULL,
    title = "Capex per User",
    subtitle = "By ground station and satelite \nlaunch scenario (Error bars: 1SD).",
    x = NULL,
    y = "Capex \n(US$ per User",
    fill = 'Scenario'
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) + theme_minimal() +
  theme(
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 7),
    axis.text.y = element_text(size = 7),
    axis.title.y = element_text(size = 7),
    axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) +
  theme(
    legend.title = element_text(size = 7),
    legend.text = element_text(size = 7),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10)
  )


#############################################
##plot5 = Constellation Opex per User
#############################################

df = data %>%
  group_by(constellation, opex_scenario) %>%
  summarize(mean = mean(opex_per_user),
            sd = sd(opex_per_user))

df$opex_scenario = as.factor(df$opex_scenario)
df$Constellation = factor(df$constellation)
df$opex = factor(df$opex_scenario,
                  levels = c('Low', 'Baseline', 'High'))

constellation_opex_per_user <-
  ggplot(df, aes(x = Constellation, y = mean, fill = opex)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean - sd,
        ymax = mean + sd),
    width = .2,
    position = position_dodge(.9),
    color = 'black',
    size = 0.3
  ) +
  scale_fill_brewer(palette = "Paired") + theme_minimal() +
  theme(legend.position = 'right') +
  labs(
    colour = NULL,
    title = "Opex per User",
    subtitle = "By maintenance and staff \nscenario (Error bars: 1SD).",
    x = NULL,
    y = "Opex \n(US$ per User",
    fill = 'Scenario'
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) + theme_minimal() +
  theme(
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 7),
    axis.text.y = element_text(size = 7),
    axis.title.y = element_text(size = 7),
    axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) +
  theme(
    legend.title = element_text(size = 7),
    legend.text = element_text(size = 7),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10)
  )


#############################################
##plot6 = Constellation TCO per User
#############################################

df = data %>%
  group_by(constellation, capex_scenario) %>%
  summarize(mean = mean(tco_per_user),
            sd = sd(tco_per_user))

df$capex_scenario = as.factor(df$capex_scenario)
df$Constellation = factor(df$constellation)
df$capex = factor(df$capex_scenario,
                 levels = c('Low', 'Baseline', 'High'))

constellation_tco_per_user <-
  ggplot(df, aes(x = Constellation, y = mean, fill = capex)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean - sd,
        ymax = mean + sd),
    width = .2,
    position = position_dodge(.9),
    color = 'black',
    size = 0.3
  ) +
  scale_fill_brewer(palette = "Paired") + theme_minimal() +
  theme(legend.position = 'right') +
  labs(
    colour = NULL,
    title = "TCO per User",
    subtitle = "By capex scenario (Error bars: 1SD).",
    x = NULL,
    y = "TCO \n(US$ per User",
    fill = 'Scenario'
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) + theme_minimal() +
  theme(
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 7),
    axis.text.y = element_text(size = 7),
    axis.title.y = element_text(size = 7),
    axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) +
  theme(
    legend.title = element_text(size = 7),
    legend.text = element_text(size = 7),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10)
  )


#############################################
##plot7 = Constellation Capex per Capacity
#############################################

df = data %>%
  group_by(constellation, capex_scenario) %>%
  summarize(mean = mean(capex_per_capacity),
            sd = sd(capex_per_capacity))

df$capex_scenario = as.factor(df$capex_scenario)
df$Constellation = factor(df$constellation)
df$capex = factor(df$capex_scenario,
                  levels = c('Low', 'Baseline', 'High'))

constellation_capex_capacity <-
  ggplot(df, aes(x = Constellation, y = mean, fill = capex)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean - sd,
        ymax = mean + sd),
    width = .2,
    position = position_dodge(.9),
    color = 'black',
    size = 0.3
  ) +
  scale_fill_brewer(palette = "Paired") + theme_minimal() +
  theme(legend.position = 'right') +
  labs(
    colour = NULL,
    title = "Capex per Capacity",
    subtitle = "By ground station and satelite \nlaunch scenario (Error bars: 1SD).",
    x = NULL,
    y = "Capex \n(US$ per MBps",
    fill = 'Scenario'
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) + theme_minimal() +
  theme(
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 7),
    axis.text.y = element_text(size = 7),
    axis.title.y = element_text(size = 7),
    axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) +
  theme(
    legend.title = element_text(size = 7),
    legend.text = element_text(size = 7),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10)
  )



#############################################
##plot8 = Constellation Opex per Capacity
#############################################

df = data %>%
  group_by(constellation, opex_scenario) %>%
  summarize(mean = mean(opex_per_capacity),
            sd = sd(opex_per_capacity))

df$opex_scenario = as.factor(df$opex_scenario)
df$Constellation = factor(df$constellation)
df$opex = factor(df$opex_scenario,
                  levels = c('Low', 'Baseline', 'High'))

constellation_opex_capacity <-
  ggplot(df, aes(x = Constellation, y = mean, fill = opex)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean - sd,
        ymax = mean + sd),
    width = .2,
    position = position_dodge(.9),
    color = 'black',
    size = 0.3
  ) +
  scale_fill_brewer(palette = "Paired") + theme_minimal() +
  theme(legend.position = 'right') +
  labs(
    colour = NULL,
    title = "Opex per Capacity",
    subtitle = "By maintenance and staff \nscenario (Error bars: 1SD).",
    x = NULL,
    y = "Opex \n(US$ per MBps",
    fill = 'Scenario'
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) + theme_minimal() +
  theme(
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 7),
    axis.text.y = element_text(size = 7),
    axis.title.y = element_text(size = 7),
    axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) +
  theme(
    legend.title = element_text(size = 7),
    legend.text = element_text(size =7),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10)
  )


#############################################
##plot9 = Constellation TCO per Capacity
#############################################

df = data %>%
  group_by(constellation, capex_scenario) %>%
  summarize(mean = mean(tco_per_capacity),
            sd = sd(tco_per_capacity))

df$capex_scenario = as.factor(df$capex_scenario)
df$Constellation = factor(df$constellation)
df$capex = factor(df$capex_scenario,
                 levels = c('Low', 'Baseline', 'High'))

constellation_tco_capacity <-
  ggplot(df, aes(x = Constellation, y = mean, fill = capex)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean - sd,
        ymax = mean + sd),
    width = .2,
    position = position_dodge(.9),
    color = 'black',
    size = 0.3
  ) +
  scale_fill_brewer(palette = "Paired") + theme_minimal() +
  theme(legend.position = 'right') +
  labs(
    colour = NULL,
    title = "TCO per Capacity",
    subtitle = "By ground station and satelite \nlaunch scenario (Error bars: 1SD).",
    x = NULL,
    y = "Opex \n(US$ per MBps",
    fill = 'Scenario'
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) + theme_minimal() +
  theme(
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 7),
    axis.text.y = element_text(size = 7),
    axis.title.y = element_text(size = 7),
    axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) +
  theme(
    legend.title = element_text(size = 7),
    legend.text = element_text(size =7),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10)
  )


####################################
## Combine all the capacity plots ##
####################################

pub_const_cost <- ggarrange(
  constellation_capex,
  constellation_opex,
  constellation_tco,
  constellation_capex_per_user,
  constellation_opex_per_user,
  constellation_tco_per_user,
  constellation_capex_capacity,
  constellation_opex_capacity,
  constellation_tco_capacity,
  nrow = 3,
  ncol = 3,
  common.legend = T,
  legend = "bottom",
  labels = c("a", "b", "c", "d", "e", "f", "g", "h", "i")
)

path = file.path(folder, 'figures', 'pub_cost_profile.tiff')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
tiff(
  path,
  units = "in",
  width = 8.1,
  height = 7.5,
  res = 480
)
print(pub_const_cost)
dev.off()





