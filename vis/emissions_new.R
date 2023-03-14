library(ggpubr)
library(ggplot2)
library(dplyr)
library(tidyverse)

# Set default folder
folder <- dirname(rstudioapi::getSourceEditorContext()$path)

#Load the data
data <- read.csv(file.path(folder, "mission_emission_results.csv"))

constellation <- c("Kuiper", "Kuiper", "Kuiper", "Kuiper", 
                   "Kuiper", "Kuiper", "Kuiper", "OneWeb",
                   "OneWeb", "OneWeb", "OneWeb", "OneWeb",
                   "OneWeb", "OneWeb", "Starlink", "Starlink",
                   "Starlink", "Starlink", "Starlink", "Starlink", 
                   "Starlink")

category <- c("launcher", "ait", "propellant", "scheduling", 
              "transportation", "campaign", "launching",
              "launcher", "ait", "propellant", "scheduling", 
              "transportation", "campaign", "launching", 
              "launcher", "ait", "propellant", "scheduling", 
              "transportation", "campaign", "launching")

climate_change <- c(595012795.9, 87278232.09, 258836443.9, 
      485150868.1, 596332.0885, 305994064.1, 25262107.2,
      893608259.6, 32325271.14, 19378203.99, 64466609.67,
      86572.07616, 113331134.8, 5773102.192, 290566364.3,
      119603503.2, 122743338.5, 414029327.8, 1274333.643,
      419325198.9, 46654494)

ozone_depletion <- c(40.26969277, 8.455065994, 12.05780847,
      40.71209018, 0.102211235, 42.00500185, 4683344.4, 
      62.23635459, 3.131505924, 2.19997646, 5.756972014,
      0.026791027, 15.55740809, 63142.8, 21.74603442,
      11.58657192, 14.14725189, 36.95730308, 0.264053,
      57.56240995, 505951.32)

resource_depletion <- c(146865.1871, 845.3518747, 1868.207118,
      27550.91438, 10.51849324, 1794.204539, 0, 
      249468.1721, 313.0932869, 134.3250098, 3195.51396,
      3.169871489, 664.5201996, 0, 185361.9891,
      1158.445162, 851.7881636, 20554.01542, 61.92850138,
      2458.724739, 0)

freshwater_ecotixicity <- c(3765692024, 415859129.6, 924701310.2,
      3344674898, 936461.4005, 1008903428, 0, 
      5614078610, 154021899.9, 62280861.96, 425394806.9,
      458632.7734, 373667936.3, 0, 1550644626, 569881029.5, 
      395617591, 2734227013, 3520269.053, 1382571364, 0)

human_toxicity <- c(247.6108105, 26.25664416, 82.09370489, 
      225.7798525, 0.089312019, 91.57651386, 0, 
      382.722538, 9.724683023, 5.628195203, 27.99105678,
      0.051607458, 33.91722736, 0, 113.3807527,
      35.98132718, 35.66669564, 179.9625968, 0.352734648, 
      125.4937412, 0)

individual_emissions <- data.frame(constellation, category, 
      climate_change, ozone_depletion, resource_depletion, 
      freshwater_ecotixicity, human_toxicity)
##########################
##plot1 = Global warming##
##########################
df = individual_emissions %>%
  group_by(constellation, category) %>%
  summarize(
    mean = mean(climate_change),
    sd = sd(climate_change)
  )

totals <- individual_emissions %>%
  group_by(constellation) %>%
  summarize(value = signif(sum(climate_change)))

df$Constellation = factor(df$constellation)
df$category = factor(df$category, levels = 
  c("ait", "campaign", "launcher", "launching", 
    "propellant", "scheduling", "transportation"),
  labels = c("Launcher AIT", "Launch Campaign", "Launcher Production", 
    "Launch Event", "Launcher Propellant Production", 
    "SCHD of Propellant", "Transportation of Launcher"))
climate_change <- ggplot(df, aes(x = Constellation, y = mean/1e6)) +
  geom_bar(stat = "identity", aes(fill = category)) + 
  geom_text(
    aes(x = constellation, y = value/1e6, label = round(value/1e6, 1)),
    size = 1.2,
    data = totals,
    vjust = -1,
    hjust = 0.5,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Set1") + theme_minimal() + 
  theme(legend.position = "right") + labs(
    colour = NULL,
    title = "(A) Climate Change",
    subtitle = "By emission at different stage of satellite mission",
    x = NULL,
    y = "Kt CO2 Equivalent",
    fill = "Category"
  ) + scale_y_continuous(limits = c(0, 2000),
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) +   theme(plot.title = element_text(face = "bold")) + 
  theme(legend.position = "bottom", axis.title = element_text(size = 6)) + 
  theme(axis.line = element_line(colour = "black"),
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
        plot.title = element_text(size = 8)
  )


###########################
##plot2 = Ozone Depletion##
###########################
df = individual_emissions %>%
  group_by(constellation, category) %>%
  summarize(
    mean = mean(ozone_depletion),
    sd = sd(ozone_depletion)
  )

totals <- individual_emissions %>%
  group_by(constellation) %>%
  summarize(value = signif(sum(ozone_depletion)))

df$Constellation = factor(df$constellation)
df$category = factor(df$category, levels = 
                       c("ait", "campaign", "launcher", "launching", 
                         "propellant", "scheduling", "transportation"),
                     labels = c("Launcher AIT", "Launch Campaign", "Launcher Production", 
                                "Launch Event", "Launcher Propellant Production", 
                                "SCHD of Propellant", "Transportation of Launcher"))
ozone_depletion <- ggplot(df, aes(x = Constellation, y = mean/1e6)) +
  geom_bar(stat = "identity", aes(fill = category)) + 
  geom_text(
    aes(x = constellation, y = value/1e6, label = round(value/1e6, 1)),
    size = 1.2,
    data = totals,
    vjust = -1,
    hjust = 0.5,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Set1") + theme_minimal() + 
  theme(legend.position = "right") + labs(
    colour = NULL,
    title = "(B) Ozone Depletion",
    subtitle = "By emission at different stage of satellite mission",
    x = NULL,
    y = "Kt CFC-11 Equivalent",
    fill = "Category"
  ) + scale_y_continuous(limits = c(0, 5),
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) +  theme(plot.title = element_text(face = "bold")) + 
  theme(legend.position = "bottom", axis.title = element_text(size = 6)) + 
  theme(axis.line = element_line(colour = "black"),
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
    plot.title = element_text(size = 8)
  )

##############################
##plot3 = Resource Depletion##
##############################
df = individual_emissions %>%
  group_by(constellation, category) %>%
  summarize(
    mean = mean(resource_depletion),
    sd = sd(resource_depletion)
  )

totals <- individual_emissions %>%
  group_by(constellation) %>%
  summarize(value = signif(sum(resource_depletion)))

df$Constellation = factor(df$constellation)
df$category = factor(df$category, levels = 
                       c("ait", "campaign", "launcher", "launching", 
                         "propellant", "scheduling", "transportation"),
                     labels = c("Launcher AIT", "Launch Campaign", "Launcher Production", 
                                "Launch Event", "Launcher Propellant Production", 
                                "SCHD of Propellant", "Transportation of Launcher"))
resource_depletion <- ggplot(df, aes(x = Constellation, y = mean/1e3)) +
  geom_bar(stat = "identity", aes(fill = category)) + 
  geom_text(
    aes(x = constellation, y = value/1e3, label = round(value/1e3, 1)),
    size = 1.2,
    data = totals,
    vjust = -1,
    hjust = 0.5,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Set1") + theme_minimal() + 
  theme(legend.position = "right") + labs(
    colour = NULL,
    title = "(C) Resource Depletion",
    subtitle = "By emission at different stage of satellite mission",
    x = NULL,
    y = "Tonnes Sb. Equivalent",
    fill = "Category"
  ) + scale_y_continuous(limits = c(0, 300),
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) +   theme(plot.title = element_text(face = "bold")) + 
  theme(legend.position = "bottom", axis.title = element_text(size = 6)) + 
  theme(axis.line = element_line(colour = "black"),
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
        plot.title = element_text(size = 8)
  )
##########################################
##plot4 = Freshwater Aquatic Ecotoxicity##
##########################################
df = individual_emissions %>%
  group_by(constellation, category) %>%
  summarize(
    mean = mean(freshwater_ecotixicity),
    sd = sd(freshwater_ecotixicity)
  )

totals <- individual_emissions %>%
  group_by(constellation) %>%
  summarize(value = signif(sum(freshwater_ecotixicity)))

df$Constellation = factor(df$constellation)
df$category = factor(df$category, levels = 
                       c("ait", "campaign", "launcher", "launching", 
                         "propellant", "scheduling", "transportation"),
                     labels = c("Launcher AIT", "Launch Campaign", "Launcher Production", 
                                "Launch Event", "Launcher Propellant Production", 
                                "SCHD of Propellant", "Transportation of Launcher"))
freshwater_ecotixicity <- ggplot(df, aes(x = Constellation, y = mean/1e6)) +
  geom_bar(stat = "identity", aes(fill = category)) + 
  geom_text(
    aes(x = constellation, y = value/1e6, label = round(value/1e6, 1)),
    size = 1.2,
    data = totals,
    vjust = -1,
    hjust = 0.5,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Set1") + theme_minimal() + 
  theme(legend.position = "right") + labs(
    colour = NULL,
    title = "(D) Freshwater Aquatic Ecotoxicity",
    subtitle = "By emission at different stage of satellite mission",
    x = NULL,
    y = "PAF.M3.DAY (million)",
    fill = "Category"
  ) + scale_y_continuous(limits = c(0, 10000),
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) +  theme(plot.title = element_text(face = "bold")) + 
  theme(legend.position = "bottom", axis.title = element_text(size = 6)) + 
  theme(axis.line = element_line(colour = "black"),
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
        plot.title = element_text(size = 8)
  )


##########################
##plot4 = Human Toxicity##
##########################
df = individual_emissions %>%
  group_by(constellation, category) %>%
  summarize(
    mean = mean(human_toxicity),
    sd = sd(human_toxicity)
  )

totals <- individual_emissions %>%
  group_by(constellation) %>%
  summarize(value = signif(sum(human_toxicity)))

df$Constellation = factor(df$constellation)
df$category = factor(df$category, levels = 
                       c("ait", "campaign", "launcher", "launching", 
                         "propellant", "scheduling", "transportation"),
                     labels = c("Launcher AIT", "Launch Campaign", "Launcher Production", 
                                "Launch Event", "Launcher Propellant Production", 
                                "SCHD of Propellant", "Transportation of Launcher"))
human_toxicity <- ggplot(df, aes(x = Constellation, y = mean)) +
  geom_bar(stat = "identity", aes(fill = category)) + 
  geom_text(
    aes(x = constellation, y = value, label = value),
    size = 1,
    data = totals,
    vjust = -1,
    hjust = 0.5,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Set1") +
  theme(legend.position = "right") + labs(
    colour = NULL,
    title = "(E) Human Ecotoxicity",
    subtitle = "By emission at different stage of satellite mission",
    x = NULL,
    y = "CASES",
    fill = "Category"
  ) + scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) +
  theme(plot.title = element_text(face = "bold")) + 
  theme(axis.text.x = element_text(size = 6),
        axis.text.y = element_text(size = 6),
        axis.line = element_line(colour = "black")) +
  theme(legend.position = "bottom", axis.title = element_text(size = 6)) +
  theme(
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    plot.subtitle = element_text(size = 6),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    plot.title = element_text(size = 8)
  )

####################################
## Combine all the emission plots ##
####################################

pub_emission <- ggarrange(
  climate_change,
  ozone_depletion,
  resource_depletion,
  freshwater_ecotixicity,
  nrow = 2,
  ncol = 2,
  common.legend = T,
  legend = "bottom"
)

path = file.path(folder, 'figures', 'pub_individual_emission.tiff')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
tiff(
  path,
  units = "in",
  width = 6,
  height = 6,
  res = 480
)
print(pub_emission)
dev.off()


######################################
##plot1 = Emission per Subscriber
######################################
# Variables to Consider
data <-
  select(
    data,
    constellation,
    constellation_capacity,
    subscriber_scenario,
    impact_category,
    per_subscriber_emission,
    emission_per_capacity,
    per_cost_emission,
    total_emissions
  )

###########################
##plot1 = Total Emissions##
###########################
df = data %>%
  group_by(constellation, impact_category) %>%
  summarize(
    mean = mean(total_emissions),
    sd = sd(total_emissions)
  )

totals <- data %>%
  group_by(constellation) %>%
  summarize(value = signif(sum(total_emissions)))


df$impact_category = as.factor(df$impact_category)
df$Constellation = factor(df$constellation)
df$category = factor(df$impact_category, levels = 
    c("total_global_warming_em", "total_ozone_depletion_em", 
    "total_mineral_depletion", "total_freshwater_toxicity", 
    "total_human_toxicity", "total_water_depletion"),
    labels = c("Climate Change", "Ozone Depletion", 
    "Resource Depletion", "Freshwater Ecotoxicity", 
    "Human Ecotoxicity", "Freshwater Depletion"))

emission_totals <- ggplot(df, aes(x = Constellation, y = mean/1e9)) +
  geom_bar(stat = "identity", aes(fill = category)) + 
  scale_fill_brewer(palette = "Set1") +
  theme(legend.position = "right") + labs(
    colour = NULL,
    title = "(A) Total Emissions",
    subtitle = "By impact category",
    x = NULL,
    y = "Total Emissions (Mt)",
    fill = "Category"
  ) + scale_y_continuous(limits = c(0, 55),
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) + theme_minimal() + theme(plot.title = element_text(face = "bold")) +
  theme(strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    axis.line = element_line(colour = "black")) +
  theme(legend.position = "bottom", axis.title = element_text(size = 4)) +
  theme(
    legend.direction = "horizontal",
    legend.position = c(0.37, 0.88),
    legend.title = element_text(size = 4),
    legend.text = element_text(size = 4),
    plot.subtitle = element_text(size = 6),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    plot.title = element_text(size = 8)
  ) + guides(fill = guide_legend(ncol = 2, nrow = 3))

##########################################
##plot2 = Emissions Vs Capacity Provided##
##########################################

df = data %>%
  group_by(constellation) %>%
  summarize(
    mean = mean(emission_per_capacity),
    sd = sd(emission_per_capacity)
  )

df$Constellation = factor(df$constellation)
emission_capacity <- ggplot(df, aes(x = Constellation, 
  y = mean, fill = Constellation)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean - sd/1e2, ymax = mean + sd/1e2),
    width = .2,
    position = position_dodge(.9),
    color = "black",
    size = 0.2
  ) + geom_text(
    aes(label = round(after_stat(y), 1), group = Constellation),
    stat = "summary",
    fun = sum,
    vjust = -.5,
    hjust = -0.8,
    size = 1.5
  ) +
  scale_fill_brewer(palette = "Set1") + theme_minimal() +
  theme(legend.position = 'right') + labs(
    colour = NULL,
    title = "(C) Emissions vs Provided Capacity",
    subtitle = "Error bars: 1 SD.",
    x = NULL,
    y = "Emissions \n(t/Gbps)",
    fill = "Constellations"
  ) + scale_y_continuous(limits = c(0, 1000),
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
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
    axis.line = element_line(colour = "black")
  ) + theme(plot.title = element_text(face = "bold")) +
  theme(legend.position = "none", axis.title = element_text(size = 6)) +
  theme(
    legend.text = element_text(size = 6),
    plot.subtitle = element_text(size = 6),
    plot.title = element_text(size = 8)
  )

##############################
##plot3 = Emissions Vs Cost###
##############################
df = data %>%
  group_by(constellation) %>%
  summarize(
    mean = mean(per_cost_emission),
    sd = sd(per_cost_emission)
  )

df$Constellation = factor(df$constellation)

emission_cost <- ggplot(df, aes(x = Constellation, 
  y = mean, fill = Constellation)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean - sd/1e2, ymax = mean + sd/1e2),
    width = .2,
    position = position_dodge(.9),
    color = "black",
    size = 0.2
  ) + geom_text(
    aes(label = round(after_stat(y), 1), group = Constellation),
    stat = "summary",
    fun = sum,
    vjust = -.5,
    hjust = -1.2,
    size = 1.5
  ) + 
  scale_fill_brewer(palette = "Set1") + theme_minimal() +
  theme(legend.position = 'right') + labs(
    colour = NULL,
    title = "(D) Emissions vs Investment Cost",
    subtitle = "Error bars: 1 SD.",
    x = NULL,
    y = "Emissions \n(kg/US$)",
    fill = "Constellations"
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0), limits = c(0, 4),
  ) + theme_minimal() + theme(
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    axis.title.y = element_text(size = 6),
    axis.line = element_line(colour = "black")
  ) + theme(plot.title = element_text(face = "bold")) +
  theme(legend.position = "none", axis.title = element_text(size = 6)) +
  theme(
    legend.text = element_text(size = 6),
    plot.subtitle = element_text(size = 6),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    plot.title = element_text(size = 8)
  )

######################################
##plot4 = Emission per Subscriber
######################################

df = data %>%
  group_by(constellation, subscriber_scenario) %>%
  summarize(
    mean = mean(per_subscriber_emission/1e3),
    sd = sd(per_subscriber_emission/1e3))

df$subscriber_scenario = as.factor(df$subscriber_scenario)
df$Constellation = factor(df$constellation)
df$scenario = factor(df$subscriber_scenario, 
  levels = c('subscribers_low', 'subscribers_baseline', 'subscribers_high'),
                     labels = c('Low', 'Baseline', 'High'))

emission_subscriber <- ggplot(df, aes(x = Constellation, 
  y = mean, fill = scenario)) + 
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean - sd/10, ymax = mean + sd/10),
    width = .2,
    position = position_dodge(.9),
    color = 'black',
    size = 0.2
  ) +
  scale_fill_brewer(palette = "Set1") + theme_minimal() +
  theme(legend.position = 'right') + labs(
    colour = NULL,
    title = "(B) Emission vs Users",
    subtitle = "By different subscriber scenarios.",
    x = NULL,
    y = "Emission \n(Tonnes/subscriber)",
    fill = 'Scenario'
  ) + scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) + theme_minimal() + theme(plot.title = element_text(face = "bold")) +
  theme(
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 6),
    axis.text.y = element_text(size = 6),
    axis.title.y = element_text(size = 6),
    axis.line = element_line(colour = "black")
  ) + theme(legend.position = c(0.8, 0.7), axis.title = element_text(size = 4)) + theme(
    legend.title = element_text(size = 4),
    legend.text = element_text(size = 4),
    axis.line.x  = element_line(size = 0.15),
    axis.line.y  = element_line(size = 0.15),
    plot.subtitle = element_text(size = 6),
    plot.title = element_text(size = 8)
  ) 

####################################
## Combine all the emission plots ##
####################################
pub_emission <-
  ggarrange(
    emission_totals,
    emission_subscriber,
    emission_capacity,
    emission_cost,
    nrow = 2,
    ncol = 2
  )

path = file.path(folder, 'figures', 'combined_emission.tiff')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
tiff(
  path,
  units = "in",
  width = 6,
  height = 6,
  res = 480
)
print(pub_emission)
dev.off()



















