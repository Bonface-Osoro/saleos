library(ggpubr)
library(ggplot2)
library(dplyr)
library(tidyverse)
# install.packages("readxl")
library("readxl")
library(ggtext)

folder <- dirname(rstudioapi::getSourceEditorContext()$path)
visualizations = file.path(folder, '..', 'vis')
filename = 'life_cycle_data.xlsx'
path = file.path(folder, '..', 'data', filename)
individual_emissions <- read_excel(path, sheet = "Transpose")
colnames(individual_emissions) <- as.character(unlist(individual_emissions[1,]))
individual_emissions = individual_emissions[3:23,]

colnames(individual_emissions)[colnames(individual_emissions) == "Impact category"] = "category"
str(individual_emissions)
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

##########################
##Climate Change Bseline##
##########################

df = individual_emissions %>%
  group_by(`Constellation`, category) %>%
  summarize(cc_baseline = `Climate Change - Global Warming Potential 100a`)

totals <- individual_emissions %>%
  group_by(`Constellation`) %>%
  summarize(value = signif(sum(`Climate Change - Global Warming Potential 100a`)))

climate_change <-
  ggplot(df, aes(x = Constellation, y = cc_baseline / 1e9)) +
  geom_bar(stat = "identity", aes(fill = category)) +
  geom_text(
    aes(
      x = `Constellation`,
      y = value / 1e9,
      label = round(value / 1e9, 1)
    ),
    size = 2,
    data = totals,
    vjust = 0.5,
    hjust = -0.09,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") + theme_minimal() + coord_flip() +
    labs(
    colour = NULL,
    title = "a",
    subtitle = " ",
    x = NULL,
    y = bquote("Climate Change (Mt CO"["2"]~" eq)"),
    fill = "Satellite Mission Stage"
  ) + scale_y_continuous(
    limits = c(0, 2.1),
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
    axis.text.x = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    plot.subtitle = element_text(size = 6),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    plot.title = element_text(size = 8, face = "bold")
  )

#############################
##climate change worst case##
#############################

df = individual_emissions %>%
  group_by(`Constellation`, category) %>%
  summarize(cc_worst_case = `Climate Change WC - Global Warming Potential 100a`)

totals <- individual_emissions %>%
  group_by(`Constellation`) %>%
  summarize(value = signif(sum(`Climate Change WC - Global Warming Potential 100a`)))

climate_change_wc <-
  ggplot(df, aes(x = Constellation, y = cc_worst_case / 1e9)) +
  geom_bar(stat = "identity", aes(fill = category)) +
  geom_text(
    aes(
      x = Constellation,
      y = value / 1e9,
      label = round(value / 1e9, 1)
    ),
    size = 2,
    data = totals,
    vjust = 0.5,
    hjust = -0.09,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") + theme_minimal() + coord_flip() +
    labs(
    colour = NULL,
    title = "b",
    subtitle = " ",
    x = NULL,
    y = bquote("Climate Change (Mt CO"["2"]~" eq)"),
    fill = "Satellite Mission Stage"
  ) + scale_y_continuous(
    limits = c(0, 8.5),
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
    axis.text.x = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    plot.subtitle = element_text(size = 6),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    plot.title = element_text(size = 8, face = "bold")
  )

############################
##ozone depletion baseline##
############################

df = individual_emissions %>%
  group_by(`Constellation`, category) %>%
  summarize(ozone_baseline = `Ozone Depletion - Ozone Depletion Potential (Steady State)`)

totals <- individual_emissions %>%
  group_by(`Constellation`) %>%
  summarize(value = signif(sum(`Ozone Depletion - Ozone Depletion Potential (Steady State)`)))

ozone_depletion <-
  ggplot(df, aes(x = `Constellation`, y = ozone_baseline / 1e6)) +
  geom_bar(stat = "identity", aes(fill = category)) +
  geom_text(
    aes(
      x = Constellation,
      y = value/1e6,
      label = round(value/1e6, 1)
    ),
    size = 2,
    data = totals,
    vjust = 0.5,
    hjust = -0.09,
    position = position_stack()
  )  +
  scale_fill_brewer(palette = "Dark2") +
  theme_minimal() + coord_flip() +
  labs(
    colour = NULL,
    title = "c",
    subtitle = " ",
    x = NULL,
    y = bquote("Ozone Depletion (kt CFC-11 eq)"),
    fill = "Satellite Mission Stage"
  ) +
  scale_y_continuous(
    limits = c(0, max(totals$value)/1e6+1),
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
    axis.text.x = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    plot.subtitle = element_text(size = 6),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    plot.title = element_text(size = 8, face = "bold")
  )

##############################
##ozone depletion worst case##
##############################

df = individual_emissions %>%
  group_by(Constellation, category) %>%
  summarize(ozone_worst_case = `Ozone Depletion WC - Ozone Depletion Potential (Steady State)`)

totals <- individual_emissions %>%
  group_by(Constellation) %>%
  summarize(value = signif(
    sum(`Ozone Depletion WC - Ozone Depletion Potential (Steady State)`)))

max_y = max(totals$value)

ozone_depletion_wc <-
  ggplot(df, aes(x = Constellation, y = ozone_worst_case / 1e6)) +
  geom_bar(stat = "identity", aes(fill = category)) +
  geom_text(
    aes(
      x = Constellation,
      y = value / 1e6,
      label = round(value / 1e6, 2)
    ),
    size = 2,
    data = totals,
    vjust = 0.5,
    hjust = -0.09,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") + theme_minimal() + coord_flip() +
    labs(
    colour = NULL,
    title = "d",
    subtitle = " ",
    x = NULL,
    y = bquote("Ozone Depletion (kt CFC-11 eq)"),
    fill = "Satellite Mission Stage"
  ) + scale_y_continuous(
    limits = c(0, max_y/1e6+1),
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
    axis.text.x = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    plot.subtitle = element_text(size = 6),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    plot.title = element_text(size = 8, face = "bold")
  )

######################
##Resource depletion##
######################

df = individual_emissions %>%
  group_by(Constellation, category) %>%
  summarize(resources = `Resource Depletion - Mineral Resource Depletion Potential`)

totals <- individual_emissions %>%
  group_by(Constellation) %>%
  summarize(value = signif(
    sum(`Resource Depletion - Mineral Resource Depletion Potential`)))

resource_depletion <-
  ggplot(df, aes(x = Constellation, y = resources / 1e3)) +
  geom_bar(stat = "identity", aes(fill = category)) +
  geom_text(
    aes(
      x = Constellation,
      y = value / 1e3,
      label = round(value / 1e3, 0)
    ),
    size = 2,
    data = totals,
    vjust = 0.5,
    hjust = -0.09,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") + theme_minimal() + coord_flip() +
    labs(
    colour = NULL,
    title = "e",
    subtitle = " ",
    x = NULL,
    y = bquote("Resource Depletion (t Sb eq)"),
    fill = "Satellite Mission Stage"
  ) + scale_y_continuous(
    limits = c(0, 280),
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
    axis.text.x = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    plot.subtitle = element_text(size = 6),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    plot.title = element_text(size = 8, face = "bold")
  )

#######################
##Freshwater toxicity##
#######################

df = individual_emissions %>%
  group_by(Constellation, category) %>%
  summarize(freshwater = `Toxicity - Freshwater Aquatic Ecotoxicity`)

totals <- individual_emissions %>%
  group_by(Constellation) %>%
  summarize(value = signif(
    sum(`Toxicity - Freshwater Aquatic Ecotoxicity`)))

freshwater_ecotixicity <-
  ggplot(df, aes(x = Constellation, y = freshwater / 1e8)) +
  geom_bar(stat = "identity", aes(fill = category)) +
  geom_text(
    aes(
      x = Constellation,
      y = value / 1e8,
      label = round(value / 1e8, 0)
    ),
    size = 2,
    data = totals,
    vjust = 0.5,
    hjust = -0.09,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") + theme_minimal() + coord_flip() +
    labs(
    colour = NULL,
    title = "f",
    subtitle = " ",
    x = NULL,
    y = bquote('Water Amount (PAF.M3.DAY' *  ~ 10 ^ 8 * ')'),
    fill = "Satellite Mission Stage"
  ) + scale_y_continuous(
    limits = c(0, 105),
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
    axis.text.x = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    plot.subtitle = element_text(size = 6),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    plot.title = element_text(size = 8, face = "bold")
  )

##################
##Human Toxicity##
##################

df = individual_emissions %>%
  group_by(Constellation, category) %>%
  summarize(human = `Toxicity - Human Toxicity`)

totals <- individual_emissions %>%
  group_by(Constellation) %>%
  summarize(value = signif(sum(`Toxicity - Human Toxicity`)))

human_toxicity <-
  ggplot(df, aes(x = Constellation, y = human)) +
  geom_bar(stat = "identity", aes(fill = category)) +
  geom_text(
    aes(
      x = Constellation,
      y = value,
      label = round(value, 0)
    ),
    size = 2,
    data = totals,
    vjust = 0.5,
    hjust = -0.09,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") + theme_minimal() + coord_flip() +
    labs(
    colour = NULL,
    title = "g",
    subtitle = " ",
    x = NULL,
    y = "Cases of Human Ecotoxicity",
    fill = "Satellite Mission Stage"
  ) + scale_y_continuous(
    limits = c(0, 800),
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
    axis.text.x = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    plot.subtitle = element_text(size = 6),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    plot.title = element_text(size = 8, face = "bold")
  )

####################
##Emissions Legend##
####################

df = individual_emissions %>%
  group_by(Constellation, category) %>%
  summarize(toxicity = `Toxicity - Human Toxicity`)

totals <- individual_emissions %>%
  group_by(Constellation) %>%
  summarize(value = signif(sum(`Toxicity - Human Toxicity`)))

df$Category = df$category

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
    legend.position = c(0.6, 0.4),
    legend.key.size = unit(.8, "cm"),
    legend.text = element_text(size =  6),
    legend.title = element_text(size = 6, face = "bold")
  ) +
  guides(colour = guide_legend(
    override.aes = list(size = 8),
    ncol = 2,
    nrow = 8
  ))

##################
##Combined plots##
##################

pub_emission <- ggarrange(
  climate_change,
  climate_change_wc,
  ozone_depletion,
  ozone_depletion_wc,
  resource_depletion,
  freshwater_ecotixicity,
  human_toxicity,
  legends,
  nrow = 2,
  ncol = 4
)

path = file.path(visualizations, 'figures', 'lca_metrics_panel.png')
dir.create(file.path(visualizations, 'figures'), showWarnings = FALSE)
png(
  path,
  units = "in",
  width = 8,
  height = 5.3,
  res = 480
)
print(pub_emission)
dev.off()

############################
## Fuel and emissions plots
############################
folder <- dirname(rstudioapi::getSourceEditorContext()$path)
data <- read.csv(file.path(folder, '..', 'results', "final_results.csv"))

# Variables to Consider
data <-
  select(
    data,
    constellation,
    constellation_capacity,
    subscriber_scenario,
    impact_category,
    per_subscriber_emission,
    total_emissions,
    total_climate_emissions,
    total_climate_emissions_wc,
    monthly_gb,
  )


fuel <- c("Kerosene",
          "Kerosene",
          "Hypergolic",
          "Kerosene",
          "Solid",
          "Cryogenic",
          "Hypergolic")
rockets <-
  c(
    "Starlink \n(Falcon-9)",
    "OneWeb \n(Soyuz-FG & \nFalcon-9)",
    "OneWeb \n(Soyuz-FG & \nFalcon-9)",
    "OneWeb \n(Soyuz-FG & \nFalcon-9)",
    "Kuiper \n(Ariane-5)",
    "Kuiper \n(Ariane-5)",
    "Kuiper \n(Ariane-5)")
amount <- c(500000*74, 218150*11, 7360*11, 500000*7, 10000*54, 480000*54, 184900*54)
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
  scale_fill_brewer(palette = "Dark2") + labs(
    colour = NULL,
    title = "a",
    subtitle = " ",
    x = NULL,
    y = "Fuel Quantity (Mt)",
    fill = "Fuel"
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y,
             scientific = FALSE),
    expand = c(0, 0),
    limits = c(0, 50)
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
    legend.title = element_text(size = 4),
    legend.text = element_text(size = 4),
    plot.subtitle = element_text(size = 6),
    plot.title = element_text(size = 8, face = "bold")) +
  guides(fill = guide_legend(ncol = 4, nrow = 1))



###########################
## Emissions / subscriber##
###########################
df = data %>%
  group_by(constellation, subscriber_scenario) %>%
  summarize(
    #this isn't a mean/shouldn't be a mean
    value = mean(per_subscriber_emission / 1e3)
  )

df$subscriber_scenario = as.factor(df$subscriber_scenario)
df$Constellation = factor(
  df$constellation,
  levels = c('Kuiper', 'OneWeb', 'Starlink'),
  labels = c(
    'Kuiper \n(Ariane-5)',
    'OneWeb \n(Soyuz-FG & \nFalcon-9)',
    'Starlink \n(Falcon-9)'
  )
)
df$scenario = factor(
  df$subscriber_scenario,
  levels = c(
    'subscribers_low',
    'subscribers_baseline',
    'subscribers_high'
  ),
  labels = c('Low', 'Baseline', 'High')
)

emission_subscriber <- ggplot(df, aes(x = Constellation,
                                      y = value, fill = scenario)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.9) +
  scale_fill_brewer(palette = "Dark2") + theme_minimal() +
    labs(
    colour = NULL,
    title = "b",
    subtitle = " ",
    x = NULL,
    y = bquote("Emissions / Subscriber (t CO"["2"]~"eq)"),
    fill = 'Scenario'
  ) + scale_y_continuous(
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
    legend.position = c(0.8, 0.85),
    axis.title = element_text(size = 4),
    legend.title = element_text(size = 4),
    legend.text = element_text(size = 4),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    plot.subtitle = element_text(size = 6),
    plot.title = element_text(size = 8, face = "bold"))

##############
##Panel plot##
##############

pub_emission <-
  ggarrange(fuel_types,
            emission_subscriber,
            nrow = 1,
            ncol = 2)

path = file.path(visualizations, 'figures', 'fuel_and_emissions_panel.png')
dir.create(file.path(visualizations, 'figures'), showWarnings = FALSE)
png(
  path,
  units = "in",
  width = 6.5,
  height = 3.5,
  res = 480
)
print(pub_emission)
dev.off()

######################
##Social cost legend##
######################
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
    title = "a",
    subtitle = " ",
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
    plot.subtitle = element_text(size = 6),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
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

social_cost_worse <-
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
    title = "b",
    subtitle = " ",
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
    plot.subtitle = element_text(size = 6),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    plot.title = element_text(size = 8, face = "bold")
  )

pub_carbon <-
  ggarrange(
    social_carbon_baseline,
    social_cost_worse,
    legends,
    nrow = 1,
    ncol = 3
  )

path = file.path(visualizations, 'figures', 'social_carbon.png')
dir.create(file.path(visualizations, 'figures'), showWarnings = FALSE)
tiff(
  path,
  units = "in",
  width = 7,
  height = 2.5,
  res = 480
)
print(pub_carbon)
dev.off()
