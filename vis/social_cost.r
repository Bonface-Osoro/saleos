library(ggpubr)
library(ggplot2)
library(dplyr)
library(tidyverse)
# install.packages("readxl")
library("readxl")
library(ggtext)

######################
##Social cost legend##
######################

folder <- dirname(rstudioapi::getSourceEditorContext()$path)
visualizations = file.path(folder, '..', 'vis')
filename = 'life_cycle_data.xlsx'
path = file.path(folder, '..', 'data', 'raw', filename)
individual_emissions <- read_excel(path, sheet = "Transpose")
colnames(individual_emissions) <- as.character(unlist(individual_emissions[1,]))
individual_emissions = individual_emissions[3:23,]

colnames(individual_emissions)[colnames(individual_emissions) == "Impact category"] = "category"

folder <- dirname(rstudioapi::getSourceEditorContext()$path)
filename = "final_emissions_results.csv"
data <- read.csv(file.path(folder, '..', 'results', filename))
data$Constellation = data$constellation
data = select(data, Constellation, subscriber_scenario, subscribers)
data = unique(data)
data = spread(data, key = subscriber_scenario, value = subscribers)
individual_emissions = merge(individual_emissions, data,by="Constellation")

individual_emissions$category = gsub('Ariane 5 ' , '', individual_emissions$category)
individual_emissions$category = gsub('of Ariane 5' , '', individual_emissions$category)
individual_emissions$category = gsub('Falcon 9 ', '', individual_emissions$category)
individual_emissions$category = gsub(' of by truck' , '', individual_emissions$category)
individual_emissions$category = gsub('Soyuz-FG ', '', individual_emissions$category)
individual_emissions$category = gsub(' of by train' , '', individual_emissions$category)
individual_emissions$category = gsub('Transportation ' , 'Transportation', individual_emissions$category)

individual_emissions$category = factor(
  individual_emissions$category,
  levels =c(
    "Production",
    "Propellant Production",
    "Launch Campaign",
    "Transportation",
    "AIT",
    "SCHD of Propellant",
    "Launches"
  ),
  labels = c(
    "Launcher Production",
    "Launcher Propellant Production",
    "Launch Campaign",
    "Transportation of Launcher",
    "Launcher AIT",
    "SCHD of Propellant",
    "Launch Event"
  )
)

individual_emissions <- individual_emissions %>%
  mutate_at(c(3:9), as.numeric)

individual_emissions$Constellation = factor(
  individual_emissions$Constellation,
  levels = c('Kuiper', 'OneWeb', 'Starlink'),
  labels = c(
    'Kuiper \n(Ariane-5)',
    'OneWeb \n(Soyuz-FG & \nFalcon-9)',
    'Starlink \n(Falcon-9)'
  )
)

###############################
##Social carbon cost baseline##
###############################

df = individual_emissions %>%
  group_by(`Constellation`, category) %>%
  summarize(value = `Climate Change - Global Warming Potential 100a`)

#from kg to tonnes
df$emissions_t = df$value / 1e3 
df$social_cost_milions_usd = (df$emissions_t * 185) / 1e6

# folder <- dirname(rstudioapi::getSourceEditorContext()$path)
# folder = file.path(folder, '..', 'vis')
# filename = 'test_results.csv'
# path = file.path(folder, filename)
# write.csv(df, path)

totals <- df %>%
  group_by(`Constellation`) %>%
  summarize(social_cost_milions_usd = (sum(value/1e3) * 185)/1e6)

social_carbon_baseline <-
  ggplot(df, aes(x = Constellation, y = social_cost_milions_usd)) +
  geom_bar(stat = "identity", aes(fill = category)) +
  geom_text(
    aes(
      x = Constellation,
      y = social_cost_milions_usd,
      label = paste0("$", round(social_cost_milions_usd,0), "m")
    ),
    size = 2,
    data = totals,
    vjust = -.5,
    hjust = 1.1,
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
    limits = c(0, 1550),
    labels = function(y)
      format(y, scientific = FALSE),
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
  group_by(`Constellation`, category) %>%
  summarize(value = `Climate Change WC - Global Warming Potential 100a`)

#from kg to tonnes
df$emissions_t = df$value / 1e3 
df$social_cost_milions_usd = (df$emissions_t * 185) / 1e6

totals <- df %>%
  group_by(`Constellation`) %>%
  summarize(social_cost_milions_usd = (sum(value/1e3) * 185)/1e6)

social_cost_worst_case <-
  ggplot(df, aes(x = Constellation, y = social_cost_milions_usd)) +
  geom_bar(stat = "identity", aes(fill = category)) +
  geom_text(
    aes(
      x = Constellation,
      y = social_cost_milions_usd,
      label = paste0("$", round(social_cost_milions_usd,0), "m")
    ),
    size = 2,
    data = totals,
    vjust = -.5,
    hjust = 1.1,
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
    limits = c(0, 1550),
    labels = function(y)
      format(y, scientific = FALSE),
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
  Constellation, 
  category,
  `Climate Change - Global Warming Potential 100a`,
  subscribers_baseline,
  subscribers_low,
  subscribers_high
  )

df$social_cost_usd_per_user_low = (
  ((df$`Climate Change - Global Warming Potential 100a` / 1e3) * 185) / df$subscribers_low 
)
df$social_cost_usd_per_user_baseline = (
  ((df$`Climate Change - Global Warming Potential 100a` / 1e3) * 185) / df$subscribers_baseline 
)
df$social_cost_usd_per_user_high = (
  ((df$`Climate Change - Global Warming Potential 100a` / 1e3) * 185) / df$subscribers_high 
)

totals <- df %>%
  group_by(`Constellation`) %>%
  summarize(
    social_cost_usd_per_user_low = round(sum(social_cost_usd_per_user_low),1),
    social_cost_usd_per_user_baseline = round(sum(social_cost_usd_per_user_baseline),1),   
    social_cost_usd_per_user_high = round(sum(social_cost_usd_per_user_high),1),                                   
    )

data_aggregated  = df %>%
  group_by(Constellation) %>%
  summarise(
    social_cost_usd_per_user_low = round(sum(social_cost_usd_per_user_low),1),
    social_cost_usd_per_user_baseline = round(sum(social_cost_usd_per_user_baseline),1),
    social_cost_usd_per_user_high = round(sum(social_cost_usd_per_user_high),1),
)
# data_aggregated = spread(data_aggregated, percentile, cell_count)

social_carbon_per_subscriber_baseline <-
  ggplot(df, aes(x = Constellation, y = social_cost_usd_per_user_baseline)) +
  geom_bar(stat = "identity", aes(fill = category)) +
  geom_errorbar(data=data_aggregated, 
                aes(y=social_cost_usd_per_user_baseline, 
                    ymin=social_cost_usd_per_user_low, 
                    ymax=social_cost_usd_per_user_high),
                position = position_dodge(1),
                lwd = 0.2,
                show.legend = FALSE, width=0.05,  color="#FF0000FF") +
  geom_text(
    aes(
      x = Constellation,
      y = social_cost_usd_per_user_baseline,
      label = paste0("$", round(social_cost_usd_per_user_baseline,0))
    ),
    size = 2,
    data = totals,
    vjust = -.5,
    hjust = 1.3,
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
    limits = c(0, 1000),
    labels = function(y)
      format(y, scientific = FALSE),
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
  Constellation, 
  category,
  `Climate Change WC - Global Warming Potential 100a`,
  subscribers_baseline,
  subscribers_low,
  subscribers_high
)

df$social_cost_usd_per_user_low = (
  ((df$`Climate Change WC - Global Warming Potential 100a` / 1e3) * 185) / df$subscribers_low 
)
df$social_cost_usd_per_user_baseline = (
  ((df$`Climate Change WC - Global Warming Potential 100a` / 1e3) * 185) / df$subscribers_baseline 
)
df$social_cost_usd_per_user_high = (
  ((df$`Climate Change WC - Global Warming Potential 100a` / 1e3) * 185) / df$subscribers_high 
)

totals <- df %>%
  group_by(`Constellation`) %>%
  summarize(
    social_cost_usd_per_user_low = round(sum(social_cost_usd_per_user_low),1),
    social_cost_usd_per_user_baseline = round(sum(social_cost_usd_per_user_baseline),1),   
    social_cost_usd_per_user_high = round(sum(social_cost_usd_per_user_high),1),                                   
  )

data_aggregated  = df %>%
  group_by(Constellation) %>%
  summarise(
    social_cost_usd_per_user_low = round(sum(social_cost_usd_per_user_low),1),
    social_cost_usd_per_user_baseline = round(sum(social_cost_usd_per_user_baseline),1),
    social_cost_usd_per_user_high = round(sum(social_cost_usd_per_user_high),1),
  )

social_carbon_per_subscriber_worst_case <-
  ggplot(df, aes(x = Constellation, y = social_cost_usd_per_user_baseline)) +
    geom_bar(stat = "identity", aes(fill = category)) +
    geom_errorbar(data=data_aggregated, 
                  aes(y=social_cost_usd_per_user_baseline, 
                      ymin=social_cost_usd_per_user_low, 
                      ymax=social_cost_usd_per_user_high),
                  position = position_dodge(1),
                  lwd = 0.2,
                  show.legend = FALSE, width=0.05,  color="#FF0000FF") +
    geom_text(
      aes(
        x = Constellation,
        y = social_cost_usd_per_user_baseline,
        label = paste0("$", round(social_cost_usd_per_user_baseline,0))
      ),
      size = 2,
      data = totals,
      vjust = -.5,
      hjust = 1.3,
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
      limits = c(0, 1000),
      labels = function(y)
        format(y, scientific = FALSE),
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
tiff(
  path,
  units = "in",
  width = 5.5,
  height = 4,
  res = 480
)
print(social_cost_of_carbon_panel)
dev.off()
