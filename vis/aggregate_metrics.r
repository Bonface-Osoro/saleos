library(ggpubr)
library(ggplot2)
library(tidyverse)
library(ggtext)
library(scales)
library("readxl")

# Set default folder
folder <- dirname(rstudioapi::getSourceEditorContext()$path)
visualizations = file.path(folder, '..', 'vis')

color_palette = 'Paired'

####################
## No of Launches ##
####################
data <-
  read.csv(file.path(folder, '..', 'data', 'raw', 'scenarios.csv'))

df = data %>%
  group_by(constellation, rocket, rocket_type) %>%
  summarize(no_launches = mean(no_of_launches))

df$constellation = factor(
  df$constellation,
  levels = c('starlink', 'oneweb', 'kuiper', 'geo_generic'),
  labels = c('Starlink', 'OneWeb', 'Kuiper', 'GEO')
)

df$rocket = factor(
  df$rocket,
  levels = c('unknown_hyc', 'unknown_hyg', 'falcon9', 'soyuz'),
  labels = c(
    'Hydrocarbon \nFuel Rocket',
    'Hydrogen \nFuel Rocket',
    'Falcon-9',
    'Soyuz-FG'
  )
)

df$rocket_type = factor(
  df$rocket_type,
  levels = c('hydrocarbon', 'hydrogen'),
  labels = c('Hydrocarbon', 'Hydrogen')
)

totals <- df %>%
  group_by(rocket) %>%
  summarize(value = signif(sum(no_launches), 2))

sat_launches = ggplot(df, aes(x = rocket, y = no_launches)) +
  geom_bar(stat = "identity", aes(fill = rocket_type)) +
  geom_text(
    aes(
      x = rocket,
      y = value,
      label = round(after_stat(y), 2)
    ),
    size = 2,
    data = totals,
    vjust = - 1.2,
    hjust = 0.5,
    position = position_stack()
  ) +
  scale_fill_brewer(palette = color_palette) + labs(
    colour = NULL,
    title = "",
    subtitle = "a",
    x = NULL,
    y = "No of Launches",
    fill = "Rocket Fuel Type"
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y,
             scientific = FALSE),
    expand = c(0, 0),
    limits = c(0, 180)
  ) +
  theme_minimal() + theme(
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 7),
    axis.text.y = element_text(size = 7),
    axis.title.y = element_text(size = 7),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    legend.direction = "horizontal",
    legend.position = c(0.5, 0.9),
    axis.title = element_text(size = 4),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    plot.subtitle = element_text(size = 8, face = "bold"),
    plot.title = element_text(size = 8, face = "bold")
  ) +
  guides(fill = guide_legend(ncol = 2))


###########################
## Emissions / subscriber##
###########################

folder <- dirname(rstudioapi::getSourceEditorContext()$path)
filename = "individual_emissions.csv"
data <- read.csv(file.path(folder, '..', 'results', filename))
data <- data[data$scenario == "scenario3", ]

df = data %>%
  group_by(constellation, subscriber_scenario) %>%
  summarize(value = sum((climate_change_baseline_kg / subscribers) / 1e3),
            value_wc = sum((climate_change_worst_case_kg / subscribers) / 1e3))

df = df %>%
  pivot_longer(!c(constellation, subscriber_scenario),
               names_to = "value_type",
               values_to = "emissions_subscriber")

df = df %>%
  spread(subscriber_scenario, emissions_subscriber)

df$constellation = factor(
  df$constellation,
  levels = c('geo_generic', 'kuiper', 'oneweb', 'starlink'),
  labels = c('GEO', 'Kuiper', 'OneWeb', 'Starlink')
)

df$value_type = factor(
  df$value_type,
  levels = c('value', 'value_wc'),
  labels = c('Baseline', 'Worst-case')
)

emission_subscriber <-
  ggplot(df,
         aes(x = constellation, y = subscribers_baseline,
             fill = value_type)) +
  geom_bar(position = "dodge", stat = "identity") +
  geom_errorbar(
    data = df,
    aes(y = subscribers_baseline,
        ymin = subscribers_low, ymax = subscribers_high),
    position = position_dodge(.9),
    lwd = 0.2,
    show.legend = FALSE,
    width = 0.1,
    color = "black"
  ) +
  scale_fill_brewer(palette = color_palette) +
  theme_minimal() +
  labs(
    colour = NULL,
    title = "",
    subtitle = "b",
    x = NULL,
    fill = 'Emissions\nScenario'
  ) +
  ylab("Emissions<br>(t CO<sub>2</sub> eq/Subscriber)") +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0),
    limits = c(0, 6.5)
  ) + theme_minimal() +
  theme(
    axis.title.y = element_markdown(),
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 7),
    axis.text.y = element_text(size = 7),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    legend.direction = "horizontal",
    legend.position = c(0.5, 0.9),
    axis.title = element_text(size = 6),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    plot.subtitle = element_text(size = 8, face = "bold")
  )

#######################
##Capacity Panel plot##
#######################

folder <- dirname(rstudioapi::getSourceEditorContext()$path)
filename = "final_capacity_results.csv"
data <- read.csv(file.path(folder, '..', 'results', filename))

df = data %>%
  group_by(constellation, subscriber_scenario) %>%
  summarize(mean = mean(capacity_per_user),
            sd = sd(capacity_per_user))

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
    color = 'black',
    size = 0.2
  ) +
  scale_fill_brewer(palette = color_palette) +
  labs(
    colour = NULL,
    title = " ",
    subtitle = "c",
    x = NULL,
    y = "Mean Capacity\n(Mbps/Subscriber)",
    fill = 'Adoption\nScenario'
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0),
    limits = c(0, 48)
  ) + theme_minimal() +
  theme(
    axis.title.y = element_text(size = 6),
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 7),
    axis.text.y = element_text(size = 7),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    legend.direction = "horizontal",
    legend.position = c(0.5, 0.9),
    axis.title = element_text(size = 6),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    plot.subtitle = element_text(size = 8, face = "bold")
  )

##########################
## Monthly Traffic plot ##
##########################

df = data %>%
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

subscriber_traffic <-
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
    color = 'black',
    size = 0.2
  ) +
  scale_fill_brewer(palette = color_palette) +
  labs(
    colour = NULL,
    title = " ",
    subtitle = "d",
    x = NULL,
    y = "Mean Monthly Traffic\n(GB/Subscriber)",
    fill = 'Adoption\nScenario'
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0),
    limits = c(0, 49)
  ) + theme_minimal() +
  theme(
    axis.title.y = element_text(size = 6),
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 7),
    axis.text.y = element_text(size = 7),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    legend.direction = "horizontal",
    legend.position = c(0.5, 0.9),
    axis.title = element_text(size = 6),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    plot.subtitle = element_text(size = 8, face = "bold")
  )

##############
##Cost Panel##
##############

# Load data
folder <- dirname(rstudioapi::getSourceEditorContext()$path)
filename = "final_cost_results.csv"
data <- read.csv(file.path(folder, '..', 'results', filename))

#########
## TCO ##
#########

df = data %>%
  group_by(constellation, capex_scenario) %>%
  summarize(mean = mean(total_cost_ownership),
            sd = sd(total_cost_ownership))

df$capex_scenario = as.factor(df$capex_scenario)

df$capex = factor(df$capex_scenario,
                  levels = c('Low', 'Baseline', 'High'))

constellation_tco <-
  ggplot(df, aes(x = constellation, y = mean / 1e9, fill = capex)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.9) +
  geom_errorbar(
    aes(ymin = mean / 1e9 - sd / 1e9,
        ymax = mean / 1e9 + sd / 1e9),
    width = .2,
    position = position_dodge(.9),
    color = 'black',
    size = 0.2
  ) +
  scale_fill_brewer(palette = color_palette) + 
  theme_minimal() +
  theme(legend.position = 'right') +
  labs(
    colour = NULL,
    title = " ",
    subtitle = 'e',
    x = NULL,
    y = "TCO\n(US$ Billion)",
    fill = 'Cost\nScenario'
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0),
    limits = c(0, 20)
  ) + theme_minimal() +
  theme(
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 7),
    axis.text.y = element_text(size = 7),
    axis.title.y = element_text(size = 6),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    legend.direction = "horizontal",
    legend.position = c(0.5, 0.9),
    axis.title = element_text(size = 8),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    plot.subtitle = element_text(size = 8, face = "bold"),
    plot.title = element_text(size = 10, face = "bold"))

##################
## TCO Per User ##
##################
folder <- dirname(rstudioapi::getSourceEditorContext()$path)
filename = "final_cost_results.csv"
data <- read.csv(file.path(folder, '..', 'results', filename))

df <- data %>%
  group_by(constellation, capex_scenario) %>%
  summarize(mean = mean(tco_per_user),
            sd = sd(tco_per_user))

df$capex_scenario = as.factor(df$capex_scenario)
df$capex = factor(df$capex_scenario,
                  levels = c('Low', 'Baseline', 'High'))

constellation_tco_per_user <-
  ggplot(df, aes(x = constellation, y = mean, fill = capex)) +
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
  scale_fill_brewer(palette = color_palette) +
  theme_minimal() +
  labs(
    colour = NULL,
    title = " ",
    subtitle = 'f',
    x = NULL,
    y = "TCO\n(US$/Subscriber)",
    fill = 'Cost\nScenario'
  ) +
  scale_y_continuous(
    labels = comma,
    expand = c(0, 0),
    limits = c(0, 14900)
  ) + theme_minimal() +
  theme(
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 7),
    axis.text.y = element_text(size = 7),
    axis.title.y = element_text(size = 6),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    legend.direction = "horizontal",
    legend.position = c(0.5, 0.9),
    axis.title = element_text(size = 8),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    plot.subtitle = element_text(size = 8, face = "bold"),
    plot.title = element_text(size = 10, face = "bold")
  )

###################################
## Average Monthly Cost per User ##
###################################


df <- data %>%
  group_by(constellation, capex_scenario) %>%
  summarize(mean = mean(user_monthly_cost),
            sd = sd(user_monthly_cost))

df$capex_scenario = as.factor(df$capex_scenario)
df$capex = factor(df$capex_scenario,
                  levels = c('Low', 'Baseline', 'High'))

constellation_monthly_cost_per_user <-
  ggplot(df, aes(x = constellation, y = mean, fill = capex)) +
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
  scale_fill_brewer(palette = color_palette) +
  theme_minimal() +
  labs(
    colour = NULL,
    title = " ",
    subtitle = 'f',
    x = NULL,
    y = "Average Monthly Cost \nper Subscriber(US$/Subscriber)",
    fill = 'Cost\nScenario'
  ) +
  scale_y_continuous(
    labels = comma,
    expand = c(0, 0),
    limits = c(0, 80)
  ) + theme_minimal() +
  theme(
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 7),
    axis.text.y = element_text(size = 7),
    axis.title.y = element_text(size = 6),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    legend.direction = "horizontal",
    legend.position = c(0.5, 0.9),
    axis.title = element_text(size = 8),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    plot.subtitle = element_text(size = 8, face = "bold"),
    plot.title = element_text(size = 10, face = "bold")
  )


#################
## Mega panel
#################
row1 = ggarrange(
  sat_launches,
  emission_subscriber,
  capacity_per_user,
  nrow = 1,
  ncol = 3
)

row2 =   ggarrange(
  subscriber_traffic,
  constellation_tco,
  constellation_monthly_cost_per_user,
  nrow = 1,
  ncol = 3
)

aggregate_metrics =   ggarrange(row1,
                                row2,
                                nrow = 2,
                                ncol = 1)

path = file.path(folder, 'figures', 'c_aggregate_metrics.png')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
png(
  path,
  units = "in",
  width = 9,
  height = 6.3,
  res = 480
)
print(aggregate_metrics)
dev.off()

