library(ggpubr)
library(ggplot2)
library(tidyverse)
library(ggtext)
library(scales)

# Set folder
folder <- dirname(rstudioapi::getSourceEditorContext()$path)
visualizations = file.path(folder, '..', 'vis')

color_palette = 'Paired'

###########################
## Emissions / subscriber##
###########################

folder <- dirname(rstudioapi::getSourceEditorContext()$path)
filename = "sensitivity_emissions.csv"
data <- read.csv(file.path(folder, '..', 'results', filename))

data = select(data, constellation, scenario, subscriber_scenario, subscribers, 
              annual_baseline_emission_kg)

df = data %>%
  group_by(constellation, scenario, subscriber_scenario) %>%
  summarize(value = sum((annual_baseline_emission_kg / subscribers)))

df = df %>%
  pivot_longer(!c(constellation, scenario, subscriber_scenario),
               names_to = "value_type",
               values_to = "emissions_subscriber")

df = df %>%
  group_by(constellation, scenario, value_type) %>%
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

df$scenario = factor(
  df$scenario,
  levels = c('scenario1', 'scenario2', 'scenario3'),
  labels = c('Scenario 1 (Current/Planned)', 
             'Scenario 2 (All Hydrocarbon)', 'Scenario 3 (All Hydrogen)')
)

emission_subscriber <-
  ggplot(df,
         aes(x = constellation, y = mean,
             fill = constellation)) +
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
  ) +
  labs(
    colour = NULL,
    title = "Evaluating the Emissions Impacts of Rocket Fuel Type.",
    subtitle = "Reported for annual emissions per subscriber by rocket scenario and constellation.",
    x = NULL,
    fill = 'Emissions\nScenario'
  ) +
  ylab("Annual Emissions<br>(kg CO<sub>2</sub> eq/Subscriber)") +
  scale_fill_brewer(palette = "Paired") +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0),
    limits = c(0, 649)
  ) +
  theme(
    legend.position = 'none',
    axis.text.x = element_text(size = 9),
    panel.spacing = unit(0.6, "lines"),
    plot.title = element_text(size = 12, face = "bold"),
    plot.subtitle = element_text(size = 10),
    axis.text.y = element_text(size = 9),
    axis.title.y = element_markdown(size = 9),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    axis.title.x = element_text(size = 8)
  ) + facet_wrap( ~ scenario, ncol = 3)

############################
##PER SUBSCRIBER EMISSIONS##
############################
path = file.path(visualizations, 'figures', 'h_rocket_sensitivity_total_emissions.png')
dir.create(file.path(visualizations, 'figures'), showWarnings = FALSE)
png(
  path,
  units = "in",
  width = 8,
  height = 3,
  res = 480
)

print(emission_subscriber)
dev.off()
###################
##TOTAL EMISSIONS##
###################

data <- read.csv(file.path(folder, '..', 'results', 'sensitivity_emissions.csv'))

#Rename the constellation and emission type column values
data$constellation = factor(
  data$constellation,
  levels = c('geo_generic', 'starlink', 'oneweb', 'kuiper'),
  labels = c('GEO', 'Starlink', 'OneWeb', 'Kuiper')
)

df$scenario = factor(
  df$scenario,
  levels = c('scenario1', 'scenario2', 'scenario3'),
  labels = c('Scenario 1 (Current/Planned)', 
             'Scenario 2 (All Hydrocarbon)', 'Scenario 3 (All Hydrogen)')
)

data$impact_category = factor(
  data$impact_category,
  levels = c(
    "launcher_production",
    "propellant_production",
    "launch_campaign",
    "launcher_transportation",
    "launcher_ait",
    "propellant_scheduling",
    "launch_event"
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

###########################
##Climate Change Baseline##
###########################

df = data %>%
  group_by(constellation, scenario, rocket_detailed, impact_category) %>%
  summarize(cc_baseline = climate_change_baseline_kg) %>%
  distinct(scenario, .keep_all = TRUE)

check_sums = df %>%
  group_by(constellation, scenario) %>%
  summarize(cc_baseline_sum = round(
    sum(cc_baseline)/ 1e9,3)) 

df$scenario = factor(
  df$scenario,
  levels = c('scenario1', 'scenario2', 'scenario3'),
  labels = c('Scenario 1 (Current/Planned)', 
             'Scenario 2 (All Hydrocarbon)', 'Scenario 3 (All Hydrogen)')
)

totals <- df %>%
  group_by(constellation, scenario) %>%
  summarize(value = signif(sum(cc_baseline)))

climate_change <-
  ggplot(df, aes(x = constellation, y = cc_baseline / 1e9)) +
  geom_bar(stat = "identity", aes(fill = impact_category)) +
  geom_text(
    aes(
      x = constellation,
      y = value / 1e9,
      label = round(value / 1e9, 3)
    ),
    size = 2.5,
    data = totals,
    vjust = 0.5,
    hjust = -0.09,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") + coord_flip() +
  labs(
    colour = NULL,
    title = "a",
    subtitle = " ",
    x = NULL,
    y = bquote("Climate Change (Mt CO"["2"] ~ " eq)"),
    fill = "Satellite Mission Stage"
  ) + scale_y_continuous(
    limits = c(0, 31.9),
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) + scale_x_discrete(limits = rev) +
  theme(
    legend.position = 'none',
    axis.text.x = element_text(size = 9),
    panel.spacing = unit(0.6, "lines"),
    plot.title = element_text(size = 12, face = "bold"),
    plot.subtitle = element_text(size = 6),
    axis.text.y = element_text(size = 9),
    axis.title.y = element_markdown(size = 9),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    axis.title.x = element_text(size = 8)
  ) + facet_wrap( ~ scenario, ncol = 3)


#############################
##climate change worst case##
#############################

df1 = data %>%
  group_by(constellation, scenario, rocket_detailed, impact_category) %>%
  summarize(cc_worst_case = climate_change_worst_case_kg) %>%
  distinct(scenario, .keep_all = TRUE)

check_sums = df1 %>%
  group_by(constellation, scenario) %>%
  summarize(cc_worst_case_sum = round(
    sum(cc_worst_case)/ 1e9,3)) 

df1$scenario = factor(
  df1$scenario,
  levels = c('scenario1', 'scenario2', 'scenario3'),
  labels = c('Scenario 1 (Current/Planned)', 
             'Scenario 2 (All Hydrocarbon)', 'Scenario 3 (All Hydrogen)')
)

totals <- df1 %>%
  group_by(constellation, scenario) %>%
  summarize(value = signif(sum(cc_worst_case)))

climate_change_wc <-
  ggplot(df1, aes(x = constellation, y = cc_worst_case / 1e9)) +
  geom_bar(stat = "identity", aes(fill = impact_category)) +
  geom_text(
    aes(
      x = constellation,
      y = value / 1e9,
      label = round(value / 1e9, 1)
    ),
    size = 2.5,
    data = totals,
    vjust = 0.5,
    hjust = -0.09,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") + coord_flip() +
  labs(
    colour = NULL,
    title = "b",
    subtitle = " ",
    x = NULL,
    y = bquote("Climate Change (Mt CO"["2"] ~ " eq)"),
    fill = "Satellite Mission Stage"
  ) + scale_y_continuous(
    limits = c(0, 31.9),
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) + scale_x_discrete(limits = rev) +
  theme(
    legend.position = 'none',
    axis.text.x = element_text(size = 9),
    panel.spacing = unit(0.6, "lines"),
    plot.title = element_text(size = 12, face = "bold"),
    plot.subtitle = element_text(size = 6),
    axis.text.y = element_text(size = 9),
    axis.title.y = element_markdown(size = 9),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    axis.title.x = element_text(size = 8)
  ) + facet_wrap( ~ scenario, ncol = 3)

############################
##ozone depletion baseline##
############################

df2 = data %>%
  group_by(constellation, scenario, rocket_detailed, impact_category) %>%
  summarize(ozone_baseline = ozone_depletion_baseline_kg) %>%
  distinct(scenario, .keep_all = TRUE)

check_sums = df2 %>%
  group_by(constellation, scenario) %>%
  summarize(ozone_baseline_sum = round(
    sum(ozone_baseline),3)) 

df2$scenario = factor(
  df2$scenario,
  levels = c('scenario1', 'scenario2', 'scenario3'),
  labels = c('Scenario 1 (Current/Planned)', 
             'Scenario 2 (All Hydrocarbon)', 'Scenario 3 (All Hydrogen)')
)

totals <- df2 %>%
  group_by(constellation, scenario) %>%
  summarize(value = signif(sum(ozone_baseline)))

ozone_depletion <-
  ggplot(df2, aes(x = constellation, y = ozone_baseline / 1e6)) +
  geom_bar(stat = "identity", aes(fill = impact_category)) +
  geom_text(
    aes(
      x = constellation,
      y = value / 1e6,
      label = round(value / 1e6, 2)
    ),
    size = 2.5,
    data = totals,
    vjust = 0.5,
    hjust = -0.09,
    position = position_stack()
  ) +
  scale_fill_brewer(palette = "Dark2") + coord_flip() +
  labs(
    colour = NULL,
    title = "c",
    subtitle = " ",
    x = NULL,
    y = bquote("Ozone Depletion (kt CFC-11 eq)"),
    fill = "Satellite Mission Stage"
  ) +
  scale_y_continuous(
    limits = c(0, 49.9),
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) + scale_x_discrete(limits = rev) +
  theme(
    legend.position = 'none',
    axis.text.x = element_text(size = 9),
    panel.spacing = unit(0.6, "lines"),
    plot.title = element_text(size = 12, face = "bold"),
    plot.subtitle = element_text(size = 6),
    axis.text.y = element_text(size = 9),
    axis.title.y = element_markdown(size = 9),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    axis.title.x = element_text(size = 8)
  ) + facet_wrap( ~ scenario, ncol = 3)

##############################
##ozone depletion worst case##
##############################

df3 = data %>%
  group_by(constellation, scenario, rocket_detailed, impact_category) %>%
  summarize(ozone_worst_case = ozone_depletion_worst_case_kg)%>%
  distinct(scenario, .keep_all = TRUE)

check_sums = df3 %>%
  group_by(constellation, scenario) %>%
  summarize(ozone_worst_case_sum = round(
    sum(ozone_worst_case)/ 1e9,3)) 

df3$scenario = factor(
  df3$scenario,
  levels = c('scenario1', 'scenario2', 'scenario3'),
  labels = c('Scenario 1 (Current/Planned)', 
             'Scenario 2 (All Hydrocarbon)', 'Scenario 3 (All Hydrogen)')
)

totals <- df3 %>%
  group_by(constellation, scenario) %>%
  summarize(value = signif(sum(ozone_worst_case)))

max_y = max(totals$value)

ozone_depletion_wc <-
  ggplot(df3, aes(x = constellation, y = ozone_worst_case / 1e6)) +
  geom_bar(stat = "identity", aes(fill = impact_category)) +
  geom_text(
    aes(
      x = constellation,
      y = value / 1e6,
      label = round(value / 1e6, 2)
    ),
    size = 2.5,
    data = totals,
    vjust = 0.5,
    hjust = -0.09,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") + coord_flip() +
  labs(
    colour = NULL,
    title = "d",
    subtitle = " ",
    x = NULL,
    y = bquote("Ozone Depletion (kt CFC-11 eq)"),
    fill = "Satellite Mission Stage"
  ) + scale_y_continuous(
    limits = c(0, 49.9),
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) + scale_x_discrete(limits = rev) +
  theme(
    legend.position = 'none',
    axis.text.x = element_text(size = 9),
    panel.spacing = unit(0.6, "lines"),
    plot.title = element_text(size = 12, face = "bold"),
    plot.subtitle = element_text(size = 6),
    axis.text.y = element_text(size = 9),
    axis.title.y = element_markdown(size = 9),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    axis.title.x = element_text(size = 8)
  ) + facet_wrap( ~ scenario, ncol = 3)

######################
##Resource depletion##
######################

df4 = data %>%
  group_by(constellation, scenario, rocket_detailed, impact_category) %>%
  summarize(resources = resource_depletion_kg)%>%
  distinct(scenario, .keep_all = TRUE)

check_sums = df4 %>%
  group_by(constellation, scenario) %>%
  summarize(resources_sum = round(
    sum(resources)/ 1e3,3)) 

df4$scenario = factor(
  df4$scenario,
  levels = c('scenario1', 'scenario2', 'scenario3'),
  labels = c('Scenario 1 (Current/Planned)', 
             'Scenario 2 (All Hydrocarbon)', 'Scenario 3 (All Hydrogen)')
)

totals <- df4 %>%
  group_by(constellation, scenario) %>%
  summarize(value = signif(sum(resources)))

resource_depletion <-
  ggplot(df4, aes(x = constellation, y = resources / 1e3)) +
  geom_bar(stat = "identity", aes(fill = impact_category)) +
  geom_text(
    aes(
      x = constellation,
      y = value / 1e3,
      label = round(value / 1e3, 0)
    ),
    size = 2.5,
    data = totals,
    vjust = 0.5,
    hjust = -0.09,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") + coord_flip() +
  labs(
    colour = NULL,
    title = "e",
    subtitle = " ",
    x = NULL,
    y = bquote("Resource Depletion (t Sb eq)"),
    fill = "Satellite Mission Stage"
  ) + scale_y_continuous(
    limits = c(0, 1750),
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) + scale_x_discrete(limits = rev) +
  theme(
    legend.position = 'none',
    axis.text.x = element_text(size = 9),
    panel.spacing = unit(0.6, "lines"),
    plot.title = element_text(size = 12, face = "bold"),
    plot.subtitle = element_text(size = 6),
    axis.text.y = element_text(size = 9),
    axis.title.y = element_markdown(size = 12),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    axis.title.x = element_text(size = 8)
  ) + facet_wrap( ~ scenario, ncol = 3)

#######################
##Freshwater toxicity##
#######################

df5 = data %>%
  group_by(constellation, scenario, rocket_detailed, impact_category) %>%
  summarize(freshwater = freshwater_toxicity_m3)%>%
  distinct(scenario, .keep_all = TRUE)

check_sums = df5 %>%
  group_by(constellation, scenario) %>%
  summarize(freshwater_sum = round(
    sum(freshwater)/ 1e8,3)) 

df5$scenario = factor(
  df5$scenario,
  levels = c('scenario1', 'scenario2', 'scenario3'),
  labels = c('Scenario 1 (Current/Planned)', 
             'Scenario 2 (All Hydrocarbon)', 'Scenario 3 (All Hydrogen)')
)

totals <- df5 %>%
  group_by(constellation, scenario) %>%
  summarize(value = signif(sum(freshwater)))

freshwater_ecotixicity <-
  ggplot(df5, aes(x = constellation, y = freshwater / 1e8)) +
  geom_bar(stat = "identity", aes(fill = impact_category)) +
  geom_text(
    aes(
      x = constellation,
      y = value / 1e8,
      label = round(value / 1e8, 0)
    ),
    size = 2.5,
    data = totals,
    vjust = 0.5,
    hjust = -0.09,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") + coord_flip() +
  labs(
    colour = NULL,
    title = "f",
    subtitle = " ",
    x = NULL,
    y = bquote('Water Amount (PAF.M3.Day' *  ~ 10 ^ 8 * ')'),
    #"["2"]~"
    fill = "Satellite Mission Stage"
  ) + scale_y_continuous(
    limits = c(0, 499),
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) + scale_x_discrete(limits = rev) +
  theme(
    legend.position = 'none',
    axis.text.x = element_text(size = 9),
    panel.spacing = unit(0.6, "lines"),
    plot.title = element_text(size = 12, face = "bold"),
    plot.subtitle = element_text(size = 6),
    axis.text.y = element_text(size = 9),
    axis.title.y = element_markdown(size = 12),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    axis.title.x = element_text(size = 8)
  ) + facet_wrap( ~ scenario, ncol = 3)

##################
##Human Toxicity##
##################

df6 = data %>%
  group_by(constellation, scenario, rocket_detailed, impact_category) %>%
  summarize(human = human_toxicity)%>%
  distinct(scenario, .keep_all = TRUE)

check_sums = df6 %>%
  group_by(constellation, scenario) %>%
  summarize(human_sum = round(
    sum(human),3)) 

df6$scenario = factor(
  df6$scenario,
  levels = c('scenario1', 'scenario2', 'scenario3'),
  labels = c('Scenario 1 (Current/Planned)', 
             'Scenario 2 (All Hydrocarbon)', 'Scenario 3 (All Hydrogen)')
)

totals <- df6 %>%
  group_by(constellation, scenario) %>%
  summarize(value = signif(sum(human)))

human_toxicity <-
  ggplot(df6, aes(x = constellation, y = human)) +
  geom_bar(stat = "identity", aes(fill = impact_category)) +
  geom_text(
    aes(
      x = constellation,
      y = value,
      label = round(value, 0)
    ),
    size = 2.5,
    data = totals,
    vjust = 0.5,
    hjust = -0.09,
    position = position_stack()
  ) +
  scale_fill_brewer(palette = "Dark2") + coord_flip() +
  labs(
    colour = NULL,
    title = "g",
    subtitle = " ",
    x = NULL,
    y = "Cases of Human Ecotoxicity",
    fill = "Satellite Mission Stage"
  ) + scale_y_continuous(
    limits = c(0, 3800),
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) + scale_x_discrete(limits = rev) +
  theme(
    legend.position = 'none',
    axis.text.x = element_text(size = 9),
    panel.spacing = unit(0.6, "lines"),
    plot.title = element_text(size = 12, face = "bold"),
    plot.subtitle = element_text(size = 6),
    axis.text.y = element_text(size = 9),
    axis.title.y = element_markdown(size = 12),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    axis.title.x = element_text(size = 8)
  ) + facet_wrap( ~ scenario, ncol = 3)

####################
##Emissions Legend##
####################

df = data %>%
  group_by(constellation, impact_category) %>%
  summarize(toxicity = human_toxicity)%>%
  distinct(impact_category, .keep_all = TRUE)

totals <- df %>%
  group_by(constellation) %>%
  summarize(value = signif(sum(toxicity)))

df$impact_category = df$impact_category

df$impact_category = factor(
  df$impact_category,
  levels = c(
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

legends <-
  ggplot(df, aes(x = toxicity, y = toxicity, color = impact_category)) +
  geom_point(size = 0.005) +
  lims(x = c(0, 0), y = c(1, 1)) +
  labs(fill = "Satellite Mission Stage", color = NULL) +
  theme_void() +
  scale_color_brewer(palette = "Dark2") +
  theme(
    legend.direction = "vertical",
    legend.position = c(0.5, 0.6),
    legend.key.size = unit(.8, "cm"),
    legend.text = element_text(size =  9),
    legend.title = element_text(size = 9, face = "bold")
  ) +
  guides(colour = guide_legend(
    override.aes = list(size = 8),
    ncol = 2,
    nrow = 4
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
  nrow = 4,
  ncol = 2
)

path = file.path(visualizations, 'figures', 'g_rocket_sensitivity_lca_metrics_panel.png')
dir.create(file.path(visualizations, 'figures'), showWarnings = FALSE)
png(
  path,
  units = "in",
  width = 12,
  height = 11,
  res = 480
)

print(pub_emission)
dev.off()



