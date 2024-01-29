library(ggpubr)
library(ggplot2)
library(dplyr)
library(tidyverse)
library("readxl")
library(ggtext)
library(scales)

###########################
## Read and Process Data ##
###########################
folder <- dirname(rstudioapi::getSourceEditorContext()$path)
visualizations = file.path(folder, '..', 'vis')
filename = "individual_emissions.csv"
data <- read.csv(file.path(folder, '..', 'results', filename))


data = select(
  data, 
  constellation, 
  impact_category,
  climate_change_baseline_kg,
  climate_change_worst_case_kg,
  ozone_depletion_baseline_kg,
  ozone_depletion_worst_case_kg,
  subscriber_scenario,
  subscribers
)

data$impact_category = factor(
  data$impact_category,
  levels =c(
    "launcher_production", "propellant_production",
    "launch_campaign", "launcher_transportation",
    "launcher_ait", "propellant_scheduling",
    "launch_event"),
  labels = c(
    "Launcher Production", "Launcher Propellant Production",
    "Launch Campaign", "Transportation of Launcher",
    "Launcher AIT", "SCHD of Propellant", "Launch Event"))

data$constellation = factor(
  data$constellation,
  levels = c('geo_generic', 'kuiper', 'oneweb', 'starlink'),
  labels = c('GEO', 'Kuiper', 'OneWeb', 'Starlink'))

data_aggregated <- data %>%
  group_by(constellation, 
           impact_category,
           climate_change_baseline_kg,
           climate_change_worst_case_kg,
           ozone_depletion_baseline_kg,
           ozone_depletion_worst_case_kg,
           subscriber_scenario) %>%
  summarize(subscribers = mean(subscribers))

individual_emissions <- spread(data_aggregated, key = subscriber_scenario, value = subscribers)

###############################
##Social carbon cost baseline##
###############################

df = individual_emissions %>%
  group_by(constellation, impact_category) %>%
  summarize(value = climate_change_baseline_kg)

#from kg to tonnes
df$emissions_t = df$value / 1e3 
df$social_cost_milions_usd = (df$emissions_t * 185) / 1e6

totals <- df %>%
  group_by(constellation) %>%
  summarize(social_cost_milions_usd = (sum(value/1e3) * 185)/1e6)

social_carbon_baseline <-
  ggplot(df, aes(x = constellation, y = social_cost_milions_usd)) +
  geom_bar(stat = "identity", aes(fill = impact_category)) +
  geom_text(
    aes(
      x = constellation,
      y = social_cost_milions_usd,
      label = paste0("$", comma(round(social_cost_milions_usd,0)), " mn")
    ),
    size = 2,
    data = totals,
    vjust = -.5,
    hjust = 0.5,
    position = position_stack()
  )  +
  scale_fill_brewer(palette = "Dark2") + 
  theme_minimal() +
  labs(
    colour = NULL,
    # title = "a",
    subtitle = "a",
    x = NULL,
    fill = "Satellite\nMission\nStage"
  ) +
  ylab("Social Cost<br>(Baseline) (US$ Millions)") + 
  scale_y_continuous(
    labels = comma,
    limits = c(0, 1600),
    expand = c(0, 0)
  ) +
  theme(
    legend.position = "bottom",
    axis.title = element_text(size = 6),
    axis.line = element_line(colour = "black"),
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    axis.title.y = element_markdown(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    axis.text.x = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    plot.subtitle = element_text(size = 8, face = "bold"),
    plot.title = element_text(size = 8, face = "bold")
  )

#################################
##Social Carbon cost worst case##
#################################

df = individual_emissions %>%
  group_by(constellation, impact_category) %>%
  summarize(value = climate_change_worst_case_kg)


#from kg to tonnes
df$emissions_t = df$value / 1e3 
df$social_cost_milions_usd = (df$emissions_t * 185) / 1e6

totals <- df %>%
  group_by(constellation) %>%
  summarize(social_cost_milions_usd = (sum(value/1e3) * 185)/1e6)

social_cost_worst_case <-
  ggplot(df, aes(x = constellation, y = social_cost_milions_usd)) +
  geom_bar(stat = "identity", aes(fill = impact_category)) +
  geom_text(
    aes(
      x = constellation,
      y = social_cost_milions_usd,
      label = paste0("$", comma(round(social_cost_milions_usd,0)), " mn")
    ),
    size = 2,
    data = totals,
    vjust = -.5,
    hjust = 0.5,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") + theme_minimal() +
  labs(
    colour = NULL,
    # title = "b",
    subtitle = "b",
    x = NULL,
    fill = "Satellite\nMission\nStage"
  ) +
  ylab("Social Cost<br>(Worst-case) (US$ Millions)") + # given t CO<sub>2</sub>eq
  scale_y_continuous(
    limits = c(0, 5000),
    labels = comma,
    expand = c(0, 0)
  ) +
  theme(
    legend.position = "bottom",
    axis.title = element_text(size = 6),
    axis.line = element_line(colour = "black"),
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    axis.title.y = element_markdown(),
    axis.text.x = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    plot.subtitle = element_text(size = 8, face = "bold"),
    plot.title = element_text(size = 8, face = "bold")
  )


########################################
##Social carbon cost per user baseline##
########################################

df = select(
  individual_emissions, 
  constellation, 
  impact_category,
  climate_change_baseline_kg,
  subscribers_baseline,
  subscribers_low,
  subscribers_high
  )

df$social_cost_usd_per_user_low = (
  ((df$climate_change_baseline_kg / 1e3) * 185) / df$subscribers_low 
)
df$social_cost_usd_per_user_baseline = (
  ((df$climate_change_baseline_kg / 1e3) * 185) / df$subscribers_baseline 
)
df$social_cost_usd_per_user_high = (
  ((df$climate_change_baseline_kg / 1e3) * 185) / df$subscribers_high 
)

totals <- df %>%
  group_by(constellation) %>%
  summarize(
    social_cost_usd_per_user_low = round(sum(social_cost_usd_per_user_low),1),
    social_cost_usd_per_user_baseline = round(sum(social_cost_usd_per_user_baseline),1),   
    social_cost_usd_per_user_high = round(sum(social_cost_usd_per_user_high),1),                                   
    )

data_aggregated  = df %>%
  group_by(constellation) %>%
  summarise(
    social_cost_usd_per_user_low = round(sum(social_cost_usd_per_user_low),1),
    social_cost_usd_per_user_baseline = round(sum(social_cost_usd_per_user_baseline),1),
    social_cost_usd_per_user_high = round(sum(social_cost_usd_per_user_high),1),
)
# data_aggregated = spread(data_aggregated, percentile, cell_count)

social_carbon_per_subscriber_baseline <-
  ggplot(df, aes(x = constellation, y = social_cost_usd_per_user_baseline)) +
  geom_bar(stat = "identity", aes(fill = impact_category)) +
  geom_errorbar(data=data_aggregated, 
                aes(y=social_cost_usd_per_user_baseline, 
                    ymin=social_cost_usd_per_user_low, 
                    ymax=social_cost_usd_per_user_high),
                position = position_dodge(1),
                lwd = 0.2,
                show.legend = FALSE, width=0.05,  color="#FF0000FF") +
  geom_text(
    aes(
      x = constellation,
      y = social_cost_usd_per_user_baseline,
      label = paste0("$", comma(round(social_cost_usd_per_user_baseline,0))
    )),
    size = 2,
    data = totals,
    vjust = -.5,
    hjust = 1.1,
    position = position_stack()
  )  +
  scale_fill_brewer(palette = "Dark2") + theme_minimal() +
  labs(
    colour = NULL,
    # title = "a",
    subtitle = "c",
    x = NULL,
    fill = "Satellite\nMission\nStage"
  ) +
  ylab("Social Cost/Subscriber<br>(Baseline) (US$)") + # given t CO<sub>2</sub>eq
  scale_y_continuous(
    limits = c(0, 2500),
    labels = comma,
    expand = c(0, 0)
  ) +
  theme(
    legend.position = "bottom",
    axis.title = element_text(size = 6),
    axis.line = element_line(colour = "black"),
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    axis.title.y = element_markdown(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    axis.text.x = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    plot.subtitle = element_text(size = 8, face = "bold"),
    plot.title = element_text(size = 8, face = "bold")
  )

##########################################
##Social carbon cost per user worst case##
##########################################

df = select(
  individual_emissions, 
  constellation, 
  impact_category,
  climate_change_worst_case_kg,
  subscribers_baseline,
  subscribers_low,
  subscribers_high
)

df$social_cost_usd_per_user_low = (
  ((df$climate_change_worst_case_kg / 1e3) * 185) / df$subscribers_low 
)
df$social_cost_usd_per_user_baseline = (
  ((df$climate_change_worst_case_kg / 1e3) * 185) / df$subscribers_baseline 
)
df$social_cost_usd_per_user_high = (
  ((df$climate_change_worst_case_kg / 1e3) * 185) / df$subscribers_high 
)

totals <- df %>%
  group_by(constellation) %>%
  summarize(
    social_cost_usd_per_user_low = round(sum(social_cost_usd_per_user_low),1),
    social_cost_usd_per_user_baseline = round(sum(social_cost_usd_per_user_baseline),1),   
    social_cost_usd_per_user_high = round(sum(social_cost_usd_per_user_high),1),                                   
  )

data_aggregated  = df %>%
  group_by(constellation) %>%
  summarise(
    social_cost_usd_per_user_low = round(sum(social_cost_usd_per_user_low),1),
    social_cost_usd_per_user_baseline = round(sum(social_cost_usd_per_user_baseline),1),
    social_cost_usd_per_user_high = round(sum(social_cost_usd_per_user_high),1),
  )

social_carbon_per_subscriber_worst_case <-
  ggplot(df, aes(x = constellation, y = social_cost_usd_per_user_baseline)) +
    geom_bar(stat = "identity", aes(fill = impact_category)) +
    geom_errorbar(data=data_aggregated, 
                  aes(y=social_cost_usd_per_user_baseline, 
                      ymin=social_cost_usd_per_user_low, 
                      ymax=social_cost_usd_per_user_high),
                  position = position_dodge(1),
                  lwd = 0.2,
                  show.legend = FALSE, width=0.05,  color="#FF0000FF") +
    geom_text(
      aes(
        x = constellation,
        y = social_cost_usd_per_user_baseline,
        label = paste0("$", comma(round(social_cost_usd_per_user_baseline,0))
      )),
      size = 2,
      data = totals,
      vjust = -.5,
      hjust = 1.1,
      position = position_stack()
    )  +
    scale_fill_brewer(palette = "Dark2") + theme_minimal() +
    labs(
      colour = NULL,
      # title = "a",
      subtitle = "d",
      x = NULL,
      fill = "Satellite\nMission\nStage"
    ) +
    ylab("Social Cost/Subscriber<br>(Worst-case) (US$)") + # given t CO<sub>2</sub>eq
    scale_y_continuous(
      limits = c(0, 6000),
      labels = comma,
      expand = c(0, 0)
    ) +
    theme(
      legend.position = "bottom",
      axis.title = element_text(size = 6),
      axis.line = element_line(colour = "black"),
      strip.text.x = element_blank(),
      panel.border = element_blank(),
      axis.title.y = element_markdown(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      legend.title = element_text(size = 6),
      legend.text = element_text(size = 6),
      axis.text.x = element_text(size = 6),
      axis.text.y = element_text(size = 6),
      axis.line.x  = element_line(size = 0.15),
      axis.line.y  = element_line(size = 0.15),
      plot.subtitle = element_text(size = 8, face = "bold"),
      plot.title = element_text(size = 8, face = "bold")
    )
  

social_cost_of_carbon_panel <-
  ggarrange(
    social_carbon_baseline,
    social_cost_worst_case,
    social_carbon_per_subscriber_baseline,
    social_carbon_per_subscriber_worst_case,
    common.legend = TRUE,
    legend = 'bottom',
    nrow = 2,
    ncol = 2
  )

path = file.path(visualizations, 'figures', 'e_social_carbon.png')
dir.create(file.path(visualizations, 'figures'), showWarnings = FALSE)
png(
  path,
  units = "in",
  width = 5.5,
  height = 4,
  res = 480
)
print(social_cost_of_carbon_panel)
dev.off()
