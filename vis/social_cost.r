library(ggpubr)
library(ggplot2)
library(dplyr)
library(tidyverse)
library(ggtext)
library(scales)

###########################
## Read and Process Data ##
###########################
folder <- dirname(rstudioapi::getSourceEditorContext()$path)
visualizations = file.path(folder, '..', 'vis')
filename = "individual_emissions.csv"
data <- read.csv(file.path(folder, '..', 'results', filename))
data <- data[data$scenario == "scenario1", ]

data = select(
  data, 
  constellation, 
  impact_category,
  rocket_type,
  annual_baseline_emission_kg,
  baseline_social_carbon_cost_usd,
  worst_case_social_carbon_cost_usd,
  annual_baseline_scc_per_subscriber_usd,
  annual_worst_case_scc_per_subscriber_usd,
  subscriber_scenario
)

###############################
##Social carbon cost baseline##
###############################

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
  levels = c('starlink', 'oneweb', 'kuiper', 'geo_generic'),
  labels = c('Starlink', 'OneWeb', 'Kuiper', 'GEO'))

data <- data[data$subscriber_scenario == "subscribers_baseline", ]

#obtain the total sum of emissions to match to the value in Fig 4.
#e.g., Starlink has 3.285 Mt of emissions, equaling ~0.657 Mt annually
check_sums = data %>%
  group_by(constellation) %>%
  summarize(annual_baseline_emission_Mt = round(
    sum(annual_baseline_emission_kg)/1e9,3)) 

df = data %>%
  group_by(constellation, impact_category, rocket_type) %>%
  summarize(baseline_social_carbon_cost_millions = baseline_social_carbon_cost_usd / 1e6) 

totals <- df %>%
  group_by(constellation) %>%
  summarize(total_baseline_scc = (sum(baseline_social_carbon_cost_millions)))

social_carbon_baseline <-
  ggplot(df, aes(x = constellation, y = baseline_social_carbon_cost_millions)) +
  geom_bar(stat = "identity", aes(fill = impact_category)) +
  geom_text(
    aes(
      x = constellation,
      y = total_baseline_scc,
      label = paste0("$", comma(round(total_baseline_scc,0)), " mn")
    ),
    size = 2,
    data = totals,
    vjust = -.5,
    hjust = 0.5,
    position = position_stack()
  )  +
  scale_fill_viridis_d(direction = -1) + 
  labs(
    colour = NULL,
    subtitle = "A",
    x = NULL,
    y = "Total Social Cost \n(Baseline) (US$ Millions)",
    fill = "Satellite\nMission\nStage"
  ) +
  scale_y_continuous(
    labels = comma,
    limits = c(0, 1439),
    expand = c(0, 0)
  ) +
  theme(
    legend.position = "bottom",
    axis.title = element_text(size = 6),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    axis.text.x = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    plot.subtitle = element_text(size = 8, face = "bold"),
    plot.title = element_text(size = 8, face = "bold")
  )

#################################
##Social carbon cost worst case##
#################################

df1 = data %>%
  group_by(constellation, impact_category, rocket_type) %>%
  summarize(wc_social_carbon_cost_millions = worst_case_social_carbon_cost_usd / 1e6)

totals <- df1 %>%
  group_by(constellation) %>%
  summarize(total_wc_scc = (sum(wc_social_carbon_cost_millions)))

social_cost_worst_case <-
  ggplot(df1, aes(x = constellation, y = wc_social_carbon_cost_millions)) +
  geom_bar(stat = "identity", aes(fill = impact_category)) +
  geom_text(
    aes(
      x = constellation,
      y = total_wc_scc,
      label = paste0("$", comma(round(total_wc_scc,0)), " mn")
    ),
    size = 2,
    data = totals,
    vjust = -.5,
    hjust = 0.5,
    position = position_stack()
  )  +
  scale_fill_viridis_d(direction = -1) + 
  labs(
    colour = NULL,
    subtitle = "B",
    x = NULL,
    y = "Total Social Cost \nWorst Case) (US$ Millions)",
    fill = "Satellite\nMission\nStage"
  ) +
  scale_y_continuous(
    labels = comma,
    limits = c(0, 1439),
    expand = c(0, 0)
  ) +
  theme(
    legend.position = "bottom",
    axis.title = element_text(size = 6),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    axis.text.x = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    plot.subtitle = element_text(size = 8, face = "bold"),
    plot.title = element_text(size = 8, face = "bold")
  )

###################################################
##Annualized Social carbon cost per user baseline##
###################################################
df2 = data %>%
  group_by(constellation, impact_category, rocket_type) %>%
  summarize(baseline_annual_scc_sub_millions = annual_baseline_scc_per_subscriber_usd) 

totals <- df2 %>%
  group_by(constellation) %>%
  summarize(total_baseline_annual_per_sub_scc = (sum(baseline_annual_scc_sub_millions)))

social_carbon_per_subscriber_baseline <-
  ggplot(df2, aes(x = constellation, y = baseline_annual_scc_sub_millions)) +
  geom_bar(stat = "identity", aes(fill = impact_category)) +
  geom_text(
    aes(
      x = constellation,
      y = total_baseline_annual_per_sub_scc,
      label = paste0("$", comma(round(total_baseline_annual_per_sub_scc,0)), "")
    ),
    size = 2,
    data = totals,
    vjust = -.5,
    hjust = 0.5,
    position = position_stack()
  )  +
  scale_fill_viridis_d(direction = -1) + 
  labs(
    colour = NULL,
    subtitle = "B",
    x = NULL,
    y = "Annual Social Cost/User \n(Baseline) (US$)",
    fill = "Satellite\nMission\nStage"
  ) +
  scale_y_continuous(
    labels = comma,
    limits = c(0, 114),
    expand = c(0, 0)
  ) +
  theme(
    legend.position = "bottom",
    axis.title = element_text(size = 6),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    axis.text.x = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    plot.subtitle = element_text(size = 8, face = "bold"),
    plot.title = element_text(size = 8, face = "bold")
  )

#####################################################
##Annualized Social carbon cost per user worst case##
#####################################################
df3 = data %>%
  group_by(constellation, impact_category, rocket_type) %>%
  summarize(wc_annual_scc_sub_millions = annual_worst_case_scc_per_subscriber_usd)

totals <- df3 %>%
  group_by(constellation) %>%
  summarize(total_wc_annual_per_sub_scc = (sum(wc_annual_scc_sub_millions)))

social_carbon_per_subscriber_worst_case <-
  ggplot(df3, aes(x = constellation, y = wc_annual_scc_sub_millions)) +
  geom_bar(stat = "identity", aes(fill = impact_category)) +
  geom_text(
    aes(
      x = constellation,
      y = total_wc_annual_per_sub_scc,
      label = paste0("$", comma(round(total_wc_annual_per_sub_scc,0)), "")
    ),
    size = 2,
    data = totals,
    vjust = -.5,
    hjust = 0.5,
    position = position_stack()
  )  +
  scale_fill_viridis_d(direction = -1) + 
  theme_minimal() +
  labs(
    colour = NULL,
    subtitle = "D",
    x = NULL,
    y = "Annual Social Cost/User \n(Worst-case) (US$)",
    fill = "Satellite\nMission\nStage"
  ) +
  scale_y_continuous(
    labels = comma,
    limits = c(0, 114),
    expand = c(0, 0)
  ) +
  theme(
    legend.position = "bottom",
    axis.title = element_text(size = 6),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    axis.text.x = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    plot.subtitle = element_text(size = 8, face = "bold"),
    plot.title = element_text(size = 8, face = "bold")
  )


social_cost_of_carbon_panel <-
  ggarrange(
    social_carbon_baseline,
    social_carbon_per_subscriber_baseline,
    common.legend = TRUE,
    legend = 'bottom',
    nrow = 1,
    ncol = 2
  )

path = file.path(visualizations, 'figures', 'e_social_carbon.png')
dir.create(file.path(visualizations, 'figures'), showWarnings = FALSE)
png(
  path,
  units = "in",
  width = 5.5,
  height = 3,
  res = 480
)
print(social_cost_of_carbon_panel)
dev.off()



