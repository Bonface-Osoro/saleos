library(ggpubr)
library(ggplot2)
library(dplyr)
library(tidyverse)
library(scales)

# Set default folder
folder <- dirname(rstudioapi::getSourceEditorContext()$path)

#Load the data
data <-
  read.csv(file.path(folder, '..', 'results', 'final_cost_results.csv'))

# Select columns to use #
data <- select(
  data,
  constellation,
  total_cost_ownership,
  tco_per_user,
  capex_costs,
  capex_per_user,
  opex_costs,
  opex_per_user,
  subscriber_scenario
)

#######################
##Constellation Capex##
#######################

df = data %>%
  group_by(constellation) %>%
  summarize(mean = mean(capex_costs),
  
                      sd = sd(capex_costs))
df$constellation = factor(
  df$constellation,
  labels = c('Kuiper', 'OneWeb', 'Starlink', 'GEO')
)

df$Constellation = factor(df$constellation)

constellation_capex <-
  ggplot(df, aes(x = Constellation, y = mean / 1e6)) +
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
  scale_fill_brewer(palette = "Paired") + theme_minimal() +
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
    axis.text.x = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    axis.title.y = element_text(size = 6),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    legend.position = 'bottom',
    axis.title = element_text(size = 8),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10, face = "bold")
  )


#######################################
##Constellation Total operating Costs##
#######################################

df = data %>%
  group_by(constellation) %>%
  summarize(mean = mean(opex_costs),
            sd = sd(opex_costs))

df$constellation = factor(
  df$constellation,
  labels = c('Kuiper', 'OneWeb', 'Starlink', 'GEO')
)

constellation_opex <-
  ggplot(df, aes(x = constellation, y = mean / 1e6)) + 
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
  scale_fill_brewer(palette = "Paired") + theme_minimal() +
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
    axis.text.x = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    axis.title.y = element_text(size = 6),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    legend.position = 'bottom',
    axis.title = element_text(size = 8),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10, face = "bold")
  )


#########################################
##Constellation Total Cost of Ownership##
#########################################


df = data %>%
  group_by(constellation) %>%
  summarize(mean = mean(total_cost_ownership),
            sd = sd(total_cost_ownership))

df$constellation = factor(
  df$constellation,
  labels = c('Kuiper', 'OneWeb', 'Starlink', 'GEO')
)

constellation_tco <-
  ggplot(df, aes(x = constellation, y = mean / 1e6)) + #, fill = capex
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
  scale_fill_brewer(palette = "Paired") + theme_minimal() +
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
    axis.text.x = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    axis.title.y = element_text(size = 6),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    legend.position = 'bottom',
    axis.title = element_text(size = 8),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10, face = "bold")
  )

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


################################
##Constellation Capex per User##
################################

# Set default folder
folder <- dirname(rstudioapi::getSourceEditorContext()$path)

#Load the data
data <-
  read.csv(file.path(folder, '..', 'results', 'final_cost_results.csv'))

# Select columns to use #
data <- select(
  data,
  constellation,
  total_cost_ownership,
  tco_per_user,
  capex_costs,
  capex_per_user,
  opex_costs,
  opex_per_user,
  subscriber_scenario
)

df = data %>%
  group_by(constellation, subscriber_scenario) %>%
  summarize(mean = mean(capex_per_user),
            sd = sd(capex_per_user))

df$subscriber_scenario = as.factor(df$subscriber_scenario)
df$constellation = factor(
  df$constellation,
  labels = c('Kuiper', 'OneWeb', 'Starlink', 'GEO')
)

df$subscriber_scenario = factor(
  df$subscriber_scenario,
                  levels = c('subscribers_low', 'subscribers_baseline', 'subscribers_high'),
                  labels = c('Low', 'Baseline', 'High')
  )

constellation_capex_per_user <-
  ggplot(df, aes(x = constellation, y = mean, fill = subscriber_scenario)) +
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
  scale_fill_brewer(palette = "Paired") + theme_minimal() +
  labs(
    colour = NULL,
    title = " ",
    subtitle = NULL,
    x = NULL,
    y = "Capex\n(US$/Subscriber)",
    fill = 'Adoption\nScenario'
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
    axis.text.x = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    axis.title.y = element_text(size = 6),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    legend.position = 'bottom',
    axis.title = element_text(size = 8),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10, face = "bold")
  )


###############################
##Constellation Opex per User##
###############################

df = data %>%
  group_by(constellation, subscriber_scenario) %>%
  summarize(mean = mean(opex_per_user),
            sd = sd(opex_per_user))

df$subscriber_scenario = as.factor(df$subscriber_scenario)
df$constellation = factor(
  df$constellation,
  labels = c('Kuiper', 'OneWeb', 'Starlink', 'GEO')
)

df$subscriber_scenario = factor(
  df$subscriber_scenario,
  levels = c('subscribers_low', 'subscribers_baseline', 'subscribers_high'),
  labels = c('Low', 'Baseline', 'High')
)

constellation_opex_per_user <-
  ggplot(df, aes(x = constellation, y = mean, fill = subscriber_scenario)) +
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
  scale_fill_brewer(palette = "Paired") + theme_minimal() +
  labs(
    colour = NULL,
    title = " ",
    subtitle = NULL,
    x = NULL,
    y = "Opex\n(US$/Subscriber)",
    fill = 'Adoption\nScenario'
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
    axis.text.x = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    axis.title.y = element_text(size = 6),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    legend.position = 'bottom',
    axis.title = element_text(size = 8),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10, face = "bold")
  )

##############################
##Constellation TCO per User##
##############################

df = data %>%
  group_by(constellation, subscriber_scenario) %>%
  summarize(mean = mean(tco_per_user),
            sd = sd(tco_per_user))

df$subscriber_scenario = as.factor(df$subscriber_scenario)
df$constellation = factor(
  df$constellation,
  labels = c('Kuiper', 'OneWeb', 'Starlink', 'GEO')
)

df$subscriber_scenario = factor(
  df$subscriber_scenario,
  levels = c('subscribers_low', 'subscribers_baseline', 'subscribers_high'),
  labels = c('Low', 'Baseline', 'High')
)

constellation_tco_per_user <-
  ggplot(df, aes(x = constellation, y = mean, fill = subscriber_scenario)) +
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
  scale_fill_brewer(palette = "Paired") + theme_minimal() +
  labs(
    colour = NULL,
    title = " ",
    subtitle = NULL,
    x = NULL,
    y = "TCO\n(US$/Subscriber)",
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
    axis.text.x = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    axis.title.y = element_text(size = 6),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    legend.position = 'bottom',
    axis.title = element_text(size = 8),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10, face = "bold")
  )


##################
##Combined plots##
##################

cost_per_user <- ggarrange(
  constellation_capex_per_user,
  constellation_opex_per_user,
  constellation_tco_per_user,
  nrow = 1,
  ncol = 3,
  common.legend = T,
  legend = "bottom",
  labels = c("d", "e", "f"),
  font.label = list(size = 9)
)

output <- ggarrange(
  total_cost,
  cost_per_user,
  nrow = 2,
  ncol = 1,
  common.legend = F,
  legend = "bottom",
  font.label = list(size = 9),
  heights = c(.8, 1)
)

path = file.path(folder, 'figures', 'i_cost_metrics.png')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
png(
  path,
  units = "in",
  width = 9,
  height = 6,
  res = 480
)
print(output)
dev.off()

