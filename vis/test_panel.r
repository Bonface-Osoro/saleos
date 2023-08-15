library(ggpubr)
library(ggplot2)
library(tidyverse)
# install.packages("ggtext")
library(ggtext)
library("readxl")

# Set default folder
folder <- dirname(rstudioapi::getSourceEditorContext()$path)
visualizations = file.path(folder, '..', 'vis')

color_palette = 'Paired'

############################
## Fuel and emissions plots
############################

rockets <-
  c(
    "Starlink \n(Falcon-9)",
    "OneWeb \n(Soyuz-FG & \nFalcon-9)",
    "OneWeb \n(Soyuz-FG & \nFalcon-9)",
    "OneWeb \n(Soyuz-FG & \nFalcon-9)",
    "Kuiper \n(Ariane-5)",
    "Kuiper \n(Ariane-5)",
    "Kuiper \n(Ariane-5)")

fuel <- c("Kerosene",
          "Kerosene",
          "Hypergolic",
          "Kerosene",
          "Solid",
          "Cryogenic",
          "Hypergolic")

amount <- c(500000*74, 218150*11, 7360*11, 500000*7, 480000*54, 184900*54, 10000*54)

fuels_df <- data.frame(rockets, fuel, amount)

############################
## Fuel quantities
############################

totals <- fuels_df %>%
  group_by(rockets) %>%
  summarize(value = signif(sum(amount / 1e6), 2))

fuel_types = ggplot(fuels_df, aes(x = rockets, y = amount / 1e6)) +
  geom_bar(stat = "identity", aes(fill = fuel)) +
  geom_text(
    aes(
      x = rockets,
      y = value,
      label = round(after_stat(y), 2)
    ),
    size = 1.5,
    data = totals,
    vjust = -1.8,
    hjust = 0.5,
    position = position_stack()
  ) +
  scale_fill_brewer(palette = color_palette) + labs(
    colour = NULL,
    title = "",
    subtitle = "a",
    x = NULL,
    y = "Fuel Quantity\n(Mt)",
    fill = "Fuel"
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y,
             scientific = FALSE),
    expand = c(0, 0),
    limits = c(0, 60)
  ) +
  theme_minimal() + theme(
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    axis.title.y = element_text(size = 6),
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
  guides(fill = guide_legend(ncol = 2, nrow = 2))


###########################
## Emissions / subscriber##
###########################

folder <- dirname(rstudioapi::getSourceEditorContext()$path)
filename = "final_emissions_results.csv"
data <- read.csv(file.path(folder, '..', 'results', filename))

df = data %>%
  group_by(constellation, subscriber_scenario) %>%
  summarize(
    #this isn't a mean/shouldn't be a mean
    value = mean(per_subscriber_emission / 1e3)
  )

df = df %>% 
  spread(subscriber_scenario, value)

df$Constellation = factor(
  df$constellation,
  levels = c('Kuiper', 'OneWeb', 'Starlink'),
  labels = c(
    'Kuiper \n(Ariane-5)',
    'OneWeb \n(Soyuz-FG & \nFalcon-9)',
    'Starlink \n(Falcon-9)'
  )
)

emission_subscriber <- ggplot(df, aes(x = Constellation,
                                      y = subscribers_baseline)) +
  geom_bar(stat = "identity",
           width = 0.9, fill="lightgrey") + ##A6CEE3
  geom_errorbar(data=df, aes(
    y=subscribers_baseline, ymin=subscribers_low, ymax=subscribers_high),
    position = position_dodge(1),
    lwd = 0.2,
    show.legend = FALSE, width=0.1,  color="black") +
  scale_fill_brewer(palette = color_palette) + 
  theme_minimal() +
  labs(
    colour = NULL,
    title = "",
    subtitle = "b",
    x = NULL,
    fill = 'Scenario'
  ) + 
  ylab("Emissions/Subscriber<br>(t CO<sub>2</sub>eq)") +
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
    axis.title.y = element_markdown(),
    legend.position = c(0.8, 0.85),
    axis.title = element_text(size = 6),
    legend.title = element_text(size = 4),
    legend.text = element_text(size = 4),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    plot.subtitle = element_text(size = 8, face = "bold"),
    plot.title = element_text(size = 8, face = "bold"))

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
# df$Constellation = factor(df$constellation)
df$Constellation = factor(
  df$constellation,
  levels = c('Kuiper', 'OneWeb', 'Starlink'),
  labels = c(
    'Kuiper \n(Ariane-5)',
    'OneWeb \n(Soyuz-FG & \nFalcon-9)',
    'Starlink \n(Falcon-9)'
  )
)
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
    y = "Mean Capacity\n(Mbps/User)",
    fill = 'Adoption\nScenario'
  ) + 
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0),
    limits = c(0, 25)
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
        legend.direction = "horizontal",
        legend.position = c(0.5, 0.9),
        axis.title = element_text(size = 6),
        legend.title = element_text(size = 6),
        legend.text = element_text(size =6),
        plot.subtitle = element_text(size = 8, face = "bold"),
        plot.title = element_text(size = 10, face = "bold", hjust = -0.45, vjust=2.12))

df = data %>%
  group_by(constellation, subscriber_scenario) %>%
  summarize(mean = mean(monthly_gb),
            sd = sd(monthly_gb))

df$subscriber_scenario = as.factor(df$subscriber_scenario)
# df$Constellation = factor(df$constellation)
df$Constellation = factor(
  df$constellation,
  levels = c('Kuiper', 'OneWeb', 'Starlink'),
  labels = c(
    'Kuiper \n(Ariane-5)',
    'OneWeb \n(Soyuz-FG & \nFalcon-9)',
    'Starlink \n(Falcon-9)'
  )
)
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
    position = position_dodge(.98),
    color = 'black',
    size = 0.2
  ) +
  scale_fill_brewer(palette=color_palette) +
  labs(
    colour = NULL,
    title = " ",
    subtitle = "d",
    x = NULL,
    y = "Mean Monthly Traffic\n(GB/User)",
    fill = 'Adoption\nScenario'
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0),
    limits = c(0, 30)
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
        legend.direction = "horizontal",
        legend.position = c(0.5, 0.9),
        # legend.position = 'bottom', 
        axis.title = element_text(size = 6),
        legend.title = element_text(size = 6),
        legend.text = element_text(size =6),
        plot.subtitle = element_text(size = 8, face = "bold"))

##############
##Cost Panel##
##############

# Load data
folder <- dirname(rstudioapi::getSourceEditorContext()$path)
filename = "final_cost_results.csv"
data <- read.csv(file.path(folder, '..', 'results', filename))

# data <- select(
#   data,
#   constellation,
#   total_cost_ownership,
#   tco_per_user,
#   capex_costs,
#   capex_scenario,
#   capex_per_user,
#   total_opex,
#   opex_scenario,
#   opex_per_user,
# )

df = data %>%
  group_by(constellation, capex_scenario) %>%
  summarize(mean = mean(total_cost_ownership),
            sd = sd(total_cost_ownership))

df$capex_scenario = as.factor(df$capex_scenario)
# df$Constellation = factor(df$constellation)
df$Constellation = factor(
  df$constellation,
  levels = c('Kuiper', 'OneWeb', 'Starlink'),
  labels = c(
    'Kuiper \n(Ariane-5)',
    'OneWeb \n(Soyuz-FG & \nFalcon-9)',
    'Starlink \n(Falcon-9)'
  )
)
df$capex = factor(df$capex_scenario,
                  levels = c('Low', 'Baseline', 'High'))

constellation_tco <-
  ggplot(df, aes(x = Constellation, y = mean / 1e9, fill = capex)) +
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
    limits = c(0, 3.2)
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
    legend.direction = "horizontal",
    legend.position = c(0.5, 0.9),
    axis.title = element_text(size = 8),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    plot.subtitle = element_text(size = 8, face = "bold"),
    plot.title = element_text(size = 10, face = "bold"))


df = data %>%
  group_by(constellation, capex_scenario) %>%
  summarize(mean = mean(tco_per_user),
            sd = sd(tco_per_user))

df$capex_scenario = as.factor(df$capex_scenario)
# df$Constellation = factor(df$constellation)
df$Constellation = factor(
  df$constellation,
  levels = c('Kuiper', 'OneWeb', 'Starlink'),
  labels = c(
    'Kuiper \n(Ariane-5)',
    'OneWeb \n(Soyuz-FG & \nFalcon-9)',
    'Starlink \n(Falcon-9)'
  )
)
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
  scale_fill_brewer(palette = color_palette) + 
  theme_minimal() +
  labs(
    colour = NULL,
    title = " ",
    subtitle = 'f',
    x = NULL,
    y = "TCO\n(US$/User)",
    fill = 'Cost\nScenario'
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0),
    limits = c(0, 4500)
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
    legend.direction = "horizontal",
    legend.position = c(0.5, 0.9),
    # legend.position = 'bottom', 
    axis.title = element_text(size = 8),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    plot.subtitle = element_text(size = 8, face = "bold"),
    plot.title = element_text(size = 10, face = "bold"))

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
# str(individual_emissions)
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

df = individual_emissions %>%
  group_by(Constellation, category) %>%
  summarize(toxicity = `Toxicity - Human Toxicity`)

totals <- individual_emissions %>%
  group_by(Constellation) %>%
  summarize(value = signif(sum(`Toxicity - Human Toxicity`)))

df$Category = factor(
  df$category,
  levels =c(
    "Launcher Production",
    "Launcher Propellant Production",
    "Launch Campaign",
    "Transportation of Launcher",
    "Launcher AIT",
    "SCHD of Propellant",
    "Launch Event"
  ),
  labels = c(
    "Launcher Production",
    "Launcher Propellant Production",
    "Launch Campaign",
    "Transportation of Launcher",
    "Launcher Assembly, Integration\nand Testing (AIT)",
    "Storage, Containment, Handling\nand Decontamination (SCHD)\nof Propellant",
    "Launch Event"
  )
)

legends <- ggplot(df, aes(x = toxicity, y = toxicity, color = Category)) +
  geom_point(size = 0.005) +
  lims(x = c(0, 0), y = c(1, 1)) + 
  labs(fill = "Satellite Mission Stage", color=NULL) +
  theme_void() + 
  scale_color_brewer(palette = "Dark2") +
  theme(
    legend.direction = "vertical",
    legend.position = c(0.55, 0.45),
    legend.key.size = unit(.8, "cm"),
    legend.text = element_text(size =  6),
    legend.title = element_text(size = 6, face = "bold")
  ) +
  guides(colour = guide_legend(
    override.aes = list(size = 8),
    ncol = 2,
    nrow = 8
  ))

###############################
##Social carbon cost baseline##
###############################

df = individual_emissions %>%
  group_by(`Constellation`, category) %>%
  summarize(value = `Climate Change - Global Warming Potential 100a`)

totals <- individual_emissions %>%
  group_by(`Constellation`) %>%
  summarize(value = signif(sum(`Climate Change - Global Warming Potential 100a`)))

social_carbon_baseline <-
  ggplot(df, aes(x = Constellation, y = ((value / 1e3) * 185) / 1e6)) +
  geom_bar(stat = "identity", aes(fill = category)) +
  geom_text(
    aes(
      x = Constellation,
      y = ((value / 1e3) * 185) / 1e6,
      label = round(((value / 1e3) * 185) / 1e6, 0)
    ),
    size = 2,
    data = totals,
    vjust = -0.5,
    hjust = 0.5,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") + theme_minimal() +
  labs(
    colour = NULL,
    # title = "a",
    subtitle = "g",
    x = NULL,
    fill = "Satellite Mission Stage"
  ) +
  ylab("Social Cost (Baseline)<br>(US$ Millions/t CO<sub>2</sub>eq)") +
  scale_y_continuous(
    limits = c(0, 370),
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) +
  theme(
    legend.position = "none",
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
  summarize(mean = `Climate Change WC - Global Warming Potential 100a`)

totals <- individual_emissions %>%
  group_by(`Constellation`) %>%
  summarize(value = signif(sum(`Climate Change WC - Global Warming Potential 100a`)))

social_cost_worst_case <-
  ggplot(df, aes(x = Constellation, y = ((mean / 1e3) * 185) / 1e6)) +
  geom_bar(stat = "identity", aes(fill = category)) +
  geom_text(
    aes(
      x = Constellation,
      y = ((value / 1e3) * 185) / 1e6,
      label = round(((value / 1e3) * 185) / 1e6, 0)
    ),
    size = 2,
    data = totals,
    vjust = -0.5,
    hjust = 0.5,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") + theme_minimal() +
  labs(
    colour = NULL,
    # title = "b",
    subtitle = "h",
    x = NULL,
    fill = "Satellite Mission Stage"
  ) +
  ylab("Social Cost (Worst Case)<br>(US$ Millions/t CO<sub>2</sub>eq)") +
  scale_y_continuous(
    limits = c(0, 1500),
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) +
  theme(
    legend.position = "none",
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

social_cost_of_carbon_panel <-
  ggarrange(
    social_carbon_baseline,
    social_cost_worst_case,
    legends,
    nrow = 1,
    ncol = 3
  )

#################
## Mega panel
#################
row1 = ggarrange(
    fuel_types,
    emission_subscriber,
    capacity_per_user,
    nrow = 1,
    ncol = 3
  )

row2 =   ggarrange(
  capacity_subscriber,
  constellation_tco,
  constellation_tco_per_user,
  nrow = 1,
  ncol = 3
)

test_panel =   ggarrange(
  row1,
  row2,
  social_cost_of_carbon_panel,
  nrow = 3,
  ncol = 1
)

path = file.path(visualizations, 'figures', 'test_panel.png')
dir.create(file.path(visualizations, 'figures'), showWarnings = FALSE)
ggsave(
  'test_panel.png',
  plot = last_plot(),
  device = "png",
  path=file.path(visualizations, 'figures'),
  units = c("in"),
  width = 8.3,
  height = 8.3,
  bg="white"
)

