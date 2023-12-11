library(ggpubr)
library(ggplot2)
library(dplyr)
library(tidyverse)
library("readxl")
library(ggtext)

# Set default folder
folder <- dirname(rstudioapi::getSourceEditorContext()$path)
visualizations = file.path(folder, '..', 'vis')

#Load the data
data <- read.csv(file.path(folder, '..', 'results', 'individual_emissions.csv'))
data <- data[data$scenario == "scenario3", ]

data$constellation = factor(
  data$constellation,
  levels = c('starlink', 'oneweb', 'kuiper', 'geo_generic'),
  labels = c('Starlink', 'OneWeb', 'Kuiper', 'Hypothetical GEO'))

data$rocket_type = factor(
  data$rocket_type,
  levels = c('hydrocarbon', 'hydrogen'),
  labels = c('Hydrocarbon', 'Hydrogen'))

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


###########################
##Climate Change Baseline##
###########################

df = data %>%
  group_by(constellation, rocket_type, impact_category) %>%
  summarize(cc_baseline = climate_change_baseline)

totals <- data %>%
  group_by(constellation, rocket_type) %>%
  summarize(value = signif(sum(climate_change_baseline)))

climate_change <-
  ggplot(df, aes(x = constellation, y = cc_baseline / 1e9)) +
  geom_bar(stat = "identity", aes(fill = impact_category)) +
  geom_text(aes(x = constellation, y = value / 1e9,
      label = round(value / 1e9, 3)), size = 2, data = totals,
    vjust = 0.5, hjust = -0.09, position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") + coord_flip() +
  labs( colour = NULL, title = "a", subtitle = " ",
    x = NULL, y = bquote("Climate Change (Mt CO"["2"]~" eq)"),
    fill = "Satellite Mission Stage") + scale_y_continuous(limits = c(0, 3.8),
    labels = function(y) format(y, scientific = FALSE),
    expand = c(0, 0)) + scale_x_discrete(limits=rev) +
  theme(
    legend.position = 'none',
    axis.text.x = element_text(size = 6),
    panel.spacing = unit(0.6, "lines"),
    plot.title = element_text(size = 8, face = "bold"),
    plot.subtitle = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    axis.title.y = element_markdown(size = 6),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    axis.title.x = element_text(size = 6)
  ) + facet_wrap(~ rocket_type, ncol = 2)


#############################
##climate change worst case##
#############################

df1 = data %>%
  group_by(constellation, rocket_type, impact_category) %>%
  summarize(cc_worst_case = climate_change_worst_case)

totals <- data %>%
  group_by(constellation, rocket_type) %>%
  summarize(value = signif(sum(climate_change_worst_case)))

climate_change_wc <-
  ggplot(df1, aes(x = constellation, y = cc_worst_case / 1e9)) +
  geom_bar(stat = "identity", aes(fill = impact_category)) +
  geom_text(aes( x = constellation, y = value / 1e9,
      label = round(value / 1e9, 1)), size = 2, data = totals,
    vjust = 0.5, hjust = -0.09, position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") + coord_flip() +
  labs(colour = NULL, title = "b", subtitle = " ",
    x = NULL, y = bquote("Climate Change (Mt CO"["2"]~" eq)"),
    fill = "Satellite Mission Stage") + scale_y_continuous(
    limits = c(0, 8.5), labels = function(y)
    format(y, scientific = FALSE), expand = c(0, 0)
  ) + scale_x_discrete(limits=rev) +
  theme(
    legend.position = 'none',
    axis.text.x = element_text(size = 6),
    panel.spacing = unit(0.6, "lines"),
    plot.title = element_text(size = 8, face = "bold"),
    plot.subtitle = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    axis.title.y = element_markdown(size = 6),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    axis.title.x = element_text(size = 6)
  ) + facet_wrap(~ rocket_type, ncol = 2)

############################
##ozone depletion baseline##
############################

df2 = data %>%
  group_by(constellation, rocket_type, impact_category) %>%
  summarize(ozone_baseline = ozone_depletion_baseline)

totals <- data %>%
  group_by(constellation, rocket_type) %>%
  summarize(value = signif(sum(ozone_depletion_baseline)))

ozone_depletion <-
  ggplot(df2, aes(x = constellation, y = ozone_baseline / 1e6)) +
  geom_bar(stat = "identity", aes(fill = impact_category)) +
  geom_text(aes(x = constellation, y = value/1e6,
      label = round(value/1e6, 1)), size = 2, data = totals,
    vjust = 0.5, hjust = -0.09, position = position_stack()) +
  scale_fill_brewer(palette = "Dark2") + coord_flip() +
  labs(colour = NULL, title = "c", subtitle = " ",
    x = NULL, y = bquote("Ozone Depletion (kt CFC-11 eq)"),
    fill = "Satellite Mission Stage") +
  scale_y_continuous(limits = c(0, max(totals$value)/1e6+1),
    labels = function(y) format(y, scientific = FALSE),
    expand = c(0, 0)) + scale_x_discrete(limits=rev) +
  theme(
    legend.position = 'none',
    axis.text.x = element_text(size = 6),
    panel.spacing = unit(0.6, "lines"),
    plot.title = element_text(size = 8, face = "bold"),
    plot.subtitle = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    axis.title.y = element_markdown(size = 6),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    axis.title.x = element_text(size = 6)
  ) + facet_wrap(~ rocket_type, ncol = 2)

##############################
##ozone depletion worst case##
##############################

df3 = data %>%
  group_by(constellation, rocket_type, impact_category) %>%
  summarize(ozone_worst_case = ozone_depletion_worst_case)

totals <- data %>%
  group_by(constellation, rocket_type) %>%
  summarize(value = signif(sum(ozone_depletion_worst_case)))

max_y = max(totals$value)

ozone_depletion_wc <-
  ggplot(df3, aes(x = constellation, y = ozone_worst_case / 1e6)) +
  geom_bar(stat = "identity", aes(fill = impact_category)) +
  geom_text(aes(x = constellation, y = value / 1e6,
      label = round(value / 1e6, 2)), size = 2, data = totals,
    vjust = 0.5, hjust = -0.09, position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") + coord_flip() +
  labs(colour = NULL, title = "d", subtitle = " ", x = NULL,
    y = bquote("Ozone Depletion (kt CFC-11 eq)"),
    fill = "Satellite Mission Stage") + scale_y_continuous(
    limits = c(0, max_y/1e6+1.5), labels = function(y)
    format(y, scientific = FALSE), expand = c(0, 0)
  ) + scale_x_discrete(limits=rev) +
  theme(
    legend.position = 'none',
    axis.text.x = element_text(size = 6),
    panel.spacing = unit(0.6, "lines"),
    plot.title = element_text(size = 8, face = "bold"),
    plot.subtitle = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    axis.title.y = element_markdown(size = 6),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    axis.title.x = element_text(size = 6)
  ) + facet_wrap(~ rocket_type, ncol = 2)

######################
##Resource depletion##
######################

df4 = data %>%
  group_by(constellation, rocket_type, impact_category) %>%
  summarize(resources = resource_depletion)

totals <- data %>%
  group_by(constellation, rocket_type) %>%
  summarize(value = signif(sum(resource_depletion)))

resource_depletion <-
  ggplot(df4, aes(x = constellation, y = resources / 1e3)) +
  geom_bar(stat = "identity", aes(fill = impact_category)) +
  geom_text(aes(x = constellation, y = value / 1e3,
      label = round(value / 1e3, 0)), size = 2, data = totals,
    vjust = 0.5, hjust = -0.09, position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") + coord_flip() +
  labs(colour = NULL, title = "e", subtitle = " ", x = NULL,
    y = bquote("Resource Depletion (t Sb eq)"),
    fill = "Satellite Mission Stage") + scale_y_continuous(
    limits = c(0, 280), labels = function(y)
    format(y, scientific = FALSE), expand = c(0, 0)
  ) + scale_x_discrete(limits = rev) +
  theme(
    legend.position = 'none',
    axis.text.x = element_text(size = 6),
    panel.spacing = unit(0.6, "lines"),
    plot.title = element_text(size = 8, face = "bold"),
    plot.subtitle = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    axis.title.y = element_markdown(size = 6),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    axis.title.x = element_text(size = 6)
  ) + facet_wrap(~ rocket_type, ncol = 2)

#######################
##Freshwater toxicity##
#######################

df5 = data %>%
  group_by(constellation, rocket_type, impact_category) %>%
  summarize(freshwater = freshwater_toxicity)

totals <- data %>%
  group_by(constellation, rocket_type) %>%
  summarize(value = signif(sum(freshwater_toxicity)))

freshwater_ecotixicity <-
  ggplot(df5, aes(x = constellation, y = freshwater / 1e8)) +
  geom_bar(stat = "identity", aes(fill = impact_category)) +
  geom_text(aes(x = constellation, y = value / 1e8,
      label = round(value / 1e8, 0)), size = 2, data = totals,
    vjust = 0.5, hjust = -0.09, position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") + coord_flip() +
  labs(colour = NULL, title = "f", subtitle = " ", x = NULL,
    y = bquote('Water Amount (PAF.M3.Day' *  ~ 10 ^ 8 * ')'), #"["2"]~"
    fill = "Satellite Mission Stage"
  ) + scale_y_continuous(limits = c(0, 145), labels = function(y)
      format(y, scientific = FALSE), expand = c(0, 0)
  ) + scale_x_discrete(limits=rev) +
  theme(
    legend.position = 'none',
    axis.text.x = element_text(size = 6),
    panel.spacing = unit(0.6, "lines"),
    plot.title = element_text(size = 8, face = "bold"),
    plot.subtitle = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    axis.title.y = element_markdown(size = 6),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    axis.title.x = element_text(size = 6)
  ) + facet_wrap(~ rocket_type, ncol = 2)

##################
##Human Toxicity##
##################

df6 = data %>%
  group_by(constellation, rocket_type, impact_category) %>%
  summarize(human = human_toxicity)

totals <- data %>%
  group_by(constellation, rocket_type) %>%
  summarize(value = signif(sum(human_toxicity)))

human_toxicity <-
  ggplot(df6, aes(x = constellation, y = human)) +
  geom_bar(stat = "identity", aes(fill = impact_category)) +
  geom_text(aes(x = constellation, y = value,
      label = round(value, 0)), size = 2, data = totals,
    vjust = 0.5, hjust = -0.09, position = position_stack()) + 
  scale_fill_brewer(palette = "Dark2") + coord_flip() +
  labs(colour = NULL, title = "g", subtitle = " ", x = NULL,
    y = "Cases of Human Ecotoxicity",
    fill = "Satellite Mission Stage") + scale_y_continuous(
    limits = c(0, 1100), labels = function(y)
    format(y, scientific = FALSE), expand = c(0, 0)
  ) + scale_x_discrete(limits = rev) +
  theme(
    legend.position = 'none',
    axis.text.x = element_text(size = 6),
    panel.spacing = unit(0.6, "lines"),
    plot.title = element_text(size = 8, face = "bold"),
    plot.subtitle = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    axis.title.y = element_markdown(size = 6),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    axis.title.x = element_text(size = 6)
  ) + facet_wrap(~ rocket_type, ncol = 2)

####################
##Emissions Legend##
####################

df = data %>%
  group_by(constellation, impact_category) %>%
  summarize(toxicity = human_toxicity)

totals <- data %>%
  group_by(constellation) %>%
  summarize(value = signif(sum(human_toxicity)))

df$impact_category = df$impact_category

df$impact_category = factor(
  df$impact_category,
  levels =c(
    "Launcher Production", "Launcher Propellant Production",
    "Launch Campaign", "Transportation of Launcher",
    "Launcher AIT", "SCHD of Propellant","Launch Event"),
  labels = c(
    "Launcher Production", "Launcher Propellant Production",
    "Launch Campaign", "Transportation of Launcher",
    "Launcher Assembly, Integration\nand Testing (AIT)",
    "Storage, Containment, Handling\nand Decontamination (SCHD)\nof Propellant",
    "Launch Event"))

legends <- ggplot(df, aes(x = toxicity, y = toxicity, color = impact_category)) +
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
    override.aes = list(size = 8), ncol = 2, nrow = 4))

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
  nrow = 4,
  ncol = 2
)

path = file.path(visualizations, 'figures', 'd_lca_metrics_panel.png')
dir.create(file.path(visualizations, 'figures'), showWarnings = FALSE)
png(
  path,
  units = "in",
  width = 9,
  height = 10,
  res = 480)

print(pub_emission)
dev.off()

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
    subtitle = "a",
    x = NULL,
    fill = "Satellite Mission Stage"
  ) +
  ylab("Social Cost of Carbon (Baseline)<br>(US$ Millions)") + # given t CO<sub>2</sub>eq
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
    subtitle = "b",
    x = NULL,
    fill = "Satellite Mission Stage"
  ) +
  ylab("Social Cost of Carbon (Worst Case)<br>(US$ Millions)") + # given t CO<sub>2</sub>eq
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

path = file.path(visualizations, 'figures', 'e_social_carbon.png')
dir.create(file.path(visualizations, 'figures'), showWarnings = FALSE)
tiff(
  path,
  units = "in",
  width = 8,
  height = 2.65,
  res = 480
)
print(social_cost_of_carbon_panel)
dev.off()
