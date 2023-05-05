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
    size = 0.2
  ) +
  scale_fill_brewer(palette = "Dark2") + theme_minimal() +
  theme(legend.position = 'right') +
  labs(
    colour = NULL,
    title = " ",
    subtitle = "By ground station and satelite \nlaunch scenario (Error bars: 1SD).",
    x = NULL,
    y = "Capex (Million US$)",
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
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) +
  theme(
    legend.title = element_text(size = 7),
    legend.text = element_text(size = 7),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10, face = "bold")
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
    size = 0.2
  ) +
  scale_fill_brewer(palette = "Dark2") + theme_minimal() +
  theme(legend.position = 'right') +
  labs(
    colour = NULL,
    title = " ",
    subtitle = "By maintenance and staff \nscenario (Error bars: 1SD).",
    x = NULL,
    y = "Opex (Million US$)",
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
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) +
  theme(
    legend.title = element_text(size = 7),
    legend.text = element_text(size = 7),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10, face = "bold")
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
    size = 0.2
  ) +
  scale_fill_brewer(palette = "Dark2") + theme_minimal() +
  theme(legend.position = 'right') +
  labs(
    colour = NULL,
    title = " ",
    subtitle = "By capex scenario (Error \nbars: 1SD).",
    x = NULL,
    y = "Opex (Million US$)",
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
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) +
  theme(
    legend.title = element_text(size = 7),
    legend.text = element_text(size = 7),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10, face = "bold")
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
    size = 0.2
  ) +
  scale_fill_brewer(palette = "Dark2") + theme_minimal() +
  theme(legend.position = 'right') +
  labs(
    colour = NULL,
    title = " ",
    subtitle = "By ground station and satelite \nlaunch scenario (Error bars: 1SD).",
    x = NULL,
    y = "Capex (US$ per User)",
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
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) +
  theme(
    legend.title = element_text(size = 7),
    legend.text = element_text(size = 7),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10, face = "bold")
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
    size = 0.2
  ) +
  scale_fill_brewer(palette = "Dark2") + theme_minimal() +
  theme(legend.position = 'right') +
  labs(
    colour = NULL,
    title = " ",
    subtitle = "By maintenance and staff \nscenario (Error bars: 1SD).",
    x = NULL,
    y = "Opex (US$ per User)",
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
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) +
  theme(
    legend.title = element_text(size = 7),
    legend.text = element_text(size = 7),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10, face = "bold")
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
    size = 0.2
  ) +
  scale_fill_brewer(palette = "Dark2") + theme_minimal() +
  theme(legend.position = 'right') +
  labs(
    colour = NULL,
    title = " ",
    subtitle = "By capex scenario \n(Error bars: 1SD).",
    x = NULL,
    y = "TCO (US$ per User)",
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
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) +
  theme(
    legend.title = element_text(size = 7),
    legend.text = element_text(size = 7),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10, face = "bold")
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
  ggplot(df, aes(x = Constellation, y = mean/1e6, fill = capex)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean/1e6 - sd/1e6,
        ymax = mean/1e6 + sd/1e6),
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
    subtitle = "By ground station and \nsatelite launch scenario \n(Error bars: 1SD)",
    x = NULL,
    y = "Capex (Million US$ per GB)",
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
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) +
  theme(
    legend.title = element_text(size = 7),
    legend.text = element_text(size = 7),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10, face = "bold")
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
  ggplot(df, aes(x = Constellation, y = mean/1e6, fill = opex)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean/1e6 - sd/1e6,
        ymax = mean/1e6 + sd/1e6),
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
    subtitle = "By maintenance and staff \ncosts scenario (Error bars: \n1SD)",
    x = NULL,
    y = "Opex (Million US$ per GB)",
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
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) +
  theme(
    legend.title = element_text(size = 7),
    legend.text = element_text(size =7),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10, face = "bold")
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
  ggplot(df, aes(x = Constellation, y = mean/1e6, fill = capex)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean/1e6 - sd/1e6,
        ymax = mean/1e6 + sd/1e6),
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
    subtitle = "By capital expenditure \ncost scenario (Error bars: \n1SD)",
    x = NULL,
    y = "TCO (Million US$ per GB)",
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
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = 'bottom', axis.title = element_text(size = 8)) +
  theme(
    legend.title = element_text(size = 7),
    legend.text = element_text(size =7),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10, face = "bold")
  )


#######################
##Total cost results###
#######################

total_cost <- ggarrange(
  constellation_capex,
  constellation_opex,
  constellation_tco,
  nrow = 1,
  ncol = 3,
  common.legend = T,
  legend = "bottom", 
  labels = c("a", "b", "c"),
  font.label = list(size = 9)
)

path = file.path(folder, 'figures', 'total_cost_profile.png')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
png(
  path,
  units = "in",
  width = 5.5,
  height = 2.5,
  res = 480
)
print(total_cost)
dev.off()

##########################
##per user cost results###
##########################

cost_per_user <- ggarrange(
  constellation_capex_per_user,
  constellation_opex_per_user,
  constellation_tco_per_user,
  nrow = 1,
  ncol = 3,
  common.legend = T,
  legend = "bottom", 
  labels = c("a", "b", "c"),
  font.label = list(size = 9)
)

path = file.path(folder, 'figures', 'cost_per_user.png')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
png(
  path,
  units = "in",
  width = 5.5,
  height = 2.5,
  res = 480
)
print(cost_per_user)
dev.off()

#########################
##Cost traffic results###
#########################

cost_traff <- ggarrange(
  constellation_capex_capacity,
  constellation_opex_capacity,
  constellation_tco_capacity,
  nrow = 1,
  ncol = 3,
  common.legend = T,
  legend = "bottom", 
  labels = c("a", "b", "c"),
  font.label = list(size = 9)
)

path = file.path(folder, 'figures', 'cost_traff.png')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
png(
  path,
  units = "in",
  width = 5.5,
  height = 2.5,
  res = 480
)
print(cost_traff)
dev.off()


