library(ggpubr)
library(ggplot2)
library(tidyverse)
library(ggtext)
library(scales)
library("readxl")

# Set folder
folder <- dirname(rstudioapi::getSourceEditorContext()$path)
visualizations = file.path(folder, '..', 'vis')

color_palette = 'Paired'

####################
## No of Launches ##
####################
data <-
  read.csv(file.path(folder, '..', 'data', 'raw', 'scenarios.csv'))
data <- data[data$scenario == "scenario1", ]

df = data %>%
  group_by(constellation, rocket_detailed, rocket_type) %>%
  summarize(no_launches = sum(no_of_launches))

df$combined = paste(df$constellation, df$rocket_detailed)

df$combined = factor(
  df$combined,
  levels = c("kuiper ariane_6_hydrogen", "kuiper falcon9",
             "kuiper glenn_hydrocarbon", "kuiper vulcan_hydrocarbon",
             "kuiper unknown_hydrocarbon", "kuiper unknown_hydrogen",
             "oneweb falcon9", "oneweb lvm3_hydrogen", "oneweb soyuz",
             "starlink falcon9", 
             "geo_generic unknown_hydrocarbon", "geo_generic unknown_hydrogen"  
  ),
  labels = c("Kuiper\nHYD", "Kuiper\nFalcon-9", 
             "Kuiper\nHYC", "Kuiper\nHYC", 
             "Kuiper\nHYC", "Kuiper\nHYD",
             
             "OneWeb\nFalcon-9", "OneWeb\nHYD", "OneWeb\nSoyuz-FG",
             "Starlink\nFalcon-9", 
             "GEO\nHYC", "GEO\nHYD")
)

df$rocket_type = factor(
  df$rocket_type,
  levels = c('hydrocarbon', 'hydrogen'),
  labels = c('Hydrocarbon\n(HYC)', 'Hydrogen\n(HYD)')
)

totals <- df %>%
  group_by(combined) %>%
  summarize(value = sum(no_launches))

sat_launches = 
  ggplot(df, aes(x = combined, y = no_launches)) +
  geom_bar(stat = "identity", aes(fill = rocket_type)) + 
  geom_text(
    aes(
      x = combined,
      y = value,
      label = round(after_stat(y), 2)
    ),
    size = 2,
    data = totals,
    vjust = -.5,
    hjust = 0.5,
    position = position_stack()
  ) +
  scale_fill_brewer(palette = color_palette) +
  labs(
    colour = NULL,
    title = "",
    subtitle = "a",
    x = NULL,
    y = "Rocket\nLaunches",
    fill = "Rocket\nFuel Type"
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y,
             scientific = FALSE),
    expand = c(0, 0),
    limits = c(0, 190)
  ) +
  theme_minimal() + theme(
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 7, angle = 90, hjust=1, vjust = .4), 
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
filename = "total_emissions.csv"
data <- read.csv(file.path(folder, '..', 'results', filename))

data = select(data, constellation, subscriber_scenario, subscribers, 
              annual_baseline_emissions_per_subscriber_kg, 
              annual_worst_case_emissions_per_subscriber_kg)

df = data %>%
  group_by(constellation, subscriber_scenario) %>%
  summarize(value = sum((annual_baseline_emissions_per_subscriber_kg)),
            value_wc = sum((annual_worst_case_emissions_per_subscriber_kg)))

df = df %>%
  pivot_longer(!c(constellation, subscriber_scenario),
               names_to = "value_type",
               values_to = "emissions_subscriber")

df = df %>%
  group_by(constellation, value_type) %>%
  summarize(mean = mean(emissions_subscriber),
            sd = sd(emissions_subscriber))

totals <- df
totals$mean = round(totals$mean, 0)
totals$sd = round(totals$sd, 0)

df$constellation = factor(
  df$constellation,
  levels = c('kuiper', 'oneweb', 'starlink', 'geo_generic'),
  labels = c('Kuiper', 'OneWeb', 'Starlink', 'GEO')
)

df$value_type = factor(
  df$value_type,
  levels = c('value', 'value_wc'),
  labels = c('Baseline', 'Worst-case')
)

emission_subscriber <-
  ggplot(df,
         aes(x = constellation, y = mean,
             fill = value_type)) +
  geom_bar(position = "dodge", stat = "identity") +
  geom_errorbar(
    data = df,
    aes(ymin = mean - sd,
        ymax = mean + sd),
    position = position_dodge(.9),
    lwd = 0.2,
    show.legend = FALSE,
    width = 0.1,
    color = "black"
  ) +scale_fill_brewer(palette = color_palette) +
  theme_minimal() +
  labs(
    colour = NULL,
    title = "",
    subtitle = "b",
    x = NULL,
    fill = 'Emissions\nScenario'
  ) +
  ylab("Annual Emissions<br>(kg CO<sub>2</sub> eq/Subscriber)") +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0),
    limits = c(0, 1150)
  ) +
  theme_minimal() +
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
data$constellation = factor(data$constellation, 
    levels = c('Kuiper', 'OneWeb', 'Starlink', 'GEO'))

data = select(data, constellation, subscriber_scenario,  
              capacity_per_user)

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

totals <- df
totals$mean = round(totals$mean, 0)
totals$sd = round(totals$sd, 0)

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
    y = "Mean Peak Capacity\n(Mbps/Subscriber)",
    fill = 'Adoption\nScenario'
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0),
    limits = c(0, 2250)
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
folder <- dirname(rstudioapi::getSourceEditorContext()$path)
filename = "final_capacity_results.csv"
data <- read.csv(file.path(folder, '..', 'results', filename))
data$constellation = factor(data$constellation, 
    levels = c('Kuiper', 'OneWeb', 'Starlink', 'GEO'))

data = select(data, constellation, subscriber_scenario,  
              monthly_gb)
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

totals <- df
totals$mean = round(totals$mean, 0)
totals$sd = round(totals$sd, 0)

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
    y = "Mean Peak Monthly \nTraffic (GB/Subscriber)",
    fill = 'Adoption\nScenario'
  ) +
  scale_y_continuous(
    labels = comma,
    expand = c(0, 0), limits = c(0, 27990)
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
data$constellation = factor(data$constellation, 
    levels = c('Kuiper', 'OneWeb', 'Starlink', 'GEO'))

data = select(data, constellation, subscriber_scenario,  
              tco_per_user_annualized)

df = data %>%
  group_by(constellation, subscriber_scenario) %>%
  summarize(mean = mean(tco_per_user_annualized),
            sd = sd(tco_per_user_annualized))

df$subscriber_scenario = as.factor(df$subscriber_scenario)
df$Constellation = factor(df$constellation)
df$subscriber_scenario = factor(
  df$subscriber_scenario,
  levels = c('subscribers_low', 'subscribers_baseline', 'subscribers_high'),
  labels = c('Low', 'Baseline', 'High')
)

constellation_tco_per_user <-
  ggplot(df, aes(x = Constellation, y = mean, fill = subscriber_scenario)) +
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
    subtitle = 'e',
    x = NULL,
    y = "Annualized TCO \n(US$/Subscriber)",
    fill = 'Adoption\nScenario'
  ) +
  scale_y_continuous(
    labels = comma,
    expand = c(0, 0), limits = c(0, 6000)
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
folder <- dirname(rstudioapi::getSourceEditorContext()$path)
filename = "final_cost_results.csv"
data <- read.csv(file.path(folder, '..', 'results', filename))
data$constellation = factor(data$constellation, 
    levels = c('Kuiper', 'OneWeb', 'Starlink', 'GEO'))

data = select(data, constellation, subscriber_scenario,  
              user_monthly_cost)

df <- data %>%
  group_by(constellation, subscriber_scenario) %>%
  summarize(mean = mean(user_monthly_cost),
            sd = sd(user_monthly_cost))

df$subscriber_scenario = as.factor(df$subscriber_scenario)
df$subscriber_scenario = factor(
  df$subscriber_scenario,
  levels = c('subscribers_low', 'subscribers_baseline', 'subscribers_high'),
  labels = c('Low', 'Baseline', 'High')
)

constellation_monthly_cost_per_user <-
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
  scale_fill_brewer(palette = color_palette) +
  theme_minimal() +
  labs(
    colour = NULL,
    title = " ",
    subtitle = 'f',
    x = NULL,
    y = "Mean Monthly TCO \n(US$/Subscriber)",
    fill = 'Adoption\nScenario'
  ) +
  scale_y_continuous(
    labels = comma,
    expand = c(0, 0),
    limits = c(0, 500)
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
  constellation_tco_per_user,
  constellation_monthly_cost_per_user,
  nrow = 1,
  ncol = 3
)

aggregate_metrics = ggarrange(row1, row2, nrow = 2, ncol = 1)

path = file.path(folder, 'figures', 'c_aggregate_metrics.png')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
png(
  path,
  units = "in",
  width = 9,
  height = 6,
  res = 480
)
print(aggregate_metrics)
dev.off()