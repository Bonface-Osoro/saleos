library(ggpubr)
library(ggplot2)
library(dplyr)
library(tidyverse)

# Set default folder
folder <- dirname(rstudioapi::getSourceEditorContext()$path)

#Load the data
data <- read.csv(file.path(folder, '..', 'Results', "final_results.csv"))

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
           width = 0.9) +
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
    subtitle = NULL,
    x = NULL,
    y = "Capex\n(US$ Millions)",
    fill = 'Cost\nScenario'
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
           width = 0.9) +
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
    subtitle = NULL,
    x = NULL,
    y = "Opex\n(US$ Million)",
    fill = 'Cost\nScenario'
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
           width = 0.9) +
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
    subtitle = NULL,
    x = NULL,
    y = "TCO\n(US$ Million)",
    fill = 'Cost\nScenario'
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
           width = 0.9) +
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
    subtitle = NULL,
    x = NULL,
    y = "Capex\n(US$/User)",
    fill = 'Cost\nScenario'
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
           width = 0.9) +
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
    subtitle = NULL,
    x = NULL,
    y = "Opex\n(US$/User)",
    fill = 'Cost\nScenario'
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
           width = 0.9) +
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
    subtitle = NULL,
    x = NULL,
    y = "TCO\n(US$/User)",
    fill = 'Cost\nScenario'
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

#######################
#######################
cost_per_user <- ggarrange(
  constellation_capex,
  constellation_opex,
  constellation_tco,
  constellation_capex_per_user,
  constellation_opex_per_user,
  constellation_tco_per_user,
  nrow = 2,
  ncol = 3,
  common.legend = T,
  legend = "bottom", 
  labels = c("a", "b", "c", "d", "e", "f"),
  font.label = list(size = 9)
)

path = file.path(folder, 'figures', 'cost_per_user.png')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
png(
  path,
  units = "in",
  width = 6.5,
  height = 5,
  res = 480
)
print(cost_per_user)
dev.off()

