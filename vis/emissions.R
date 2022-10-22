library(ggpubr)
library(ggplot2)
library(dplyr)
library(tidyverse)

# Set default folder
folder <- dirname(rstudioapi::getSourceEditorContext()$path)

#Load the data
data <- read.csv(file.path(folder, "mission_emission_results.csv"))

# INDIVIDUAL EMISSION PLOTS
# Rocket Fuels
fuel <- c("Kerosene",
          "Kerosene",
          "Hypergolic",
          "Solid",
          "Cryogenic",
          "Hypergolic")
rockets <-
  c("Falcon-9",
    "Soyuz-FG",
    "Soyuz-FG",
    "Ariane-5",
    "Ariane-5",
    "Ariane-5")
amount <- c(488370, 218150, 7360, 10000, 480000, 184900)
fuels_df <- data.frame(rockets, fuel, amount)

totals <- fuels_df %>%
  group_by(rockets) %>%
  summarize(value = signif(sum(amount / 1e3), 2))

fuel_types = ggplot(fuels_df, aes(x = rockets, y = amount / 1e3)) +
  geom_bar(stat = "identity", aes(fill = fuel)) +
  geom_text(
    aes(x = rockets, y = value, label = value),
    size = 2,
    data = totals,
    vjust = -1,
    hjust = 0.5,
    position = position_stack()
  ) +
  scale_fill_brewer(palette = "Paired") + labs(
    colour = NULL,
    title = "Rocket Fuel Compositions",
    subtitle = "Fuel amounts for single launch event.",
    x = NULL,
    y = "Fuel Amounts \n(t)",
    fill = "Fuel"
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y,
             scientific = FALSE),
    expand = c(0, 0),
    limits = c(0, 750)
  ) +
  theme_minimal() + theme(
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black"),
    axis.title = element_text(size = 5),
    axis.text.x = element_text(size = 7),
    axis.title.y = element_text(size = 7)
  ) +
  theme(legend.direction = "vertical",
    legend.position = c(0.85, 0.7),
    legend.title = element_text(size = 6),
    legend.text = element_text(size =5),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10),
  ) #+ guides(fill = guide_legend(ncol = 5, nrow = 2))

# Variables to Consider
data <-
  select(
    data,
    constellation,
    constellation_capacity,
    mission_total_emissions,
    subscriber_scenario,
    mission_emission_per_capacity,
    mission_emission_per_sqkm,
    mission_emission_for_every_cost,
    emission_per_subscriber
  )


########################################
##plot2 = Emission Composition Factors
########################################

fuels <- c("Solid", "Solid", "Solid", "Solid", "Solid", "Solid",
          "Cryogenic", "Cryogenic", "Cryogenic", "Cryogenic", "Cryogenic", "Cryogenic",
          "Kerosene", "Kerosene", "Kerosene", "Kerosene", "Kerosene", "Kerosene",
          "Hypergolic", "Hypergolic", "Hypergolic", "Hypergolic", "Hypergolic", "Hypergolic")
compositions <- c("Aluminium \nOxides", "Sulphur \nOxides", "Carbon \nOxides", 
                  "Chlorofluoro \ncarbons", "Particulate \nMatter", 
                  "Photochemical \nOxidation", "Aluminium \nOxides", 
                  "Sulphur \nOxides", "Carbon \nOxides", 
                  "Chlorofluoro \ncarbons", "Particulate \nMatter", 
                  "Photochemical \nOxidation", "Aluminium \nOxides", 
                  "Sulphur \nOxides", "Carbon \nOxides", 
                  "Chlorofluoro \ncarbons", "Particulate \nMatter", 
                  "Photochemical \nOxidation", "Aluminium \nOxides", 
                  "Sulphur \nOxides", "Carbon \nOxides", 
                  "Chlorofluoro \ncarbons", "Particulate \nMatter", 
                  "Photochemical \nOxidation")
factors <- c(0.33, 0.22, 0.27, 0.16, 0.335, 0.167, 0, 0.01, 0, 0.02, 0.001, 0.001, 
            0.05, 0.001, 0.88, 0.02, 0.051, 0.529, 0.001, 0.001, 0.63, 0.02, 0.002, 
            0.379)
compositions_df <- data.frame(fuels, compositions, factors)

totals <- compositions_df %>%
  group_by(fuels) %>%
  summarize(value = signif(sum(factors), 3))

fuel_factors <- ggplot(compositions_df, aes(x = fuels, y = factors)) +
  geom_bar(stat = "identity", aes(fill = compositions)) + geom_text(
    aes(x = fuels, y = value, label = value),
    size = 2,
    data = totals,
    vjust = -1,
    hjust = 0.5,
    position = position_stack()
  ) + scale_fill_brewer(palette = "Paired") + labs(
    colour = NULL,
    title = "Fuel Mass Fractions",
    subtitle = "Mass fractions of the fuel compositions.",
    x = NULL,
    y = "Fuel Mass \nFractions",
    fill = "Compositions"
  ) + scale_y_continuous(
    labels = function(y)
      format(y,
             scientific = FALSE),
    expand = c(0, 0),
    limits = c(0, 2.5)
  ) + 
  theme_minimal() + theme(
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black"),
    axis.title = element_text(size = 5),
    axis.text.x = element_text(size = 7),
    axis.title.y = element_text(size = 7)
  ) +
  theme(legend.direction = "vertical",
        legend.position = c(0.55, 0.85),
        legend.title = element_text(size = 6),
        legend.text = element_text(size =5),
        plot.subtitle = element_text(size = 8),
        plot.title = element_text(size = 10),
  ) + guides(fill = guide_legend(ncol = 4, nrow = 2))

######################################
##plot1 = Emission per Subscriber
######################################

df = data %>%
  group_by(constellation, subscriber_scenario) %>%
  summarize(
    mean = mean(emission_per_subscriber),
    sd = sd(emission_per_subscriber))

df$subscriber_scenario = as.factor(df$subscriber_scenario)
df$Constellation = factor(df$constellation)
df$scenario = factor(df$subscriber_scenario, levels = c('Low', 'Baseline', 'High'),
  labels = c('Low', 'Baseline', 'High'))

emission_subscriber <-
  ggplot(df, aes(x = Constellation, y = mean, fill = scenario)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean - sd, ymax = mean + sd),
    width = .2,
    position = position_dodge(.9),
    color = 'black',
    size = 0.3
  ) +
  scale_fill_brewer(palette = "Paired") + theme_minimal() +
  theme(legend.position = 'right') + labs(
    colour = NULL,
    title = "Emission vs Users",
    subtitle = "By different subscriber scenarios.",
    x = NULL,
    y = "Emission \n(kg/subscriber)",
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
    axis.text.x = element_text(size = 7),
    axis.title.y = element_text(size = 7),
    axis.line = element_line(colour = "black")
  ) + theme(legend.position = c(0.8, 0.7), axis.title = element_text(size = 8)) + theme(
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10)
  ) 

######################################
##plot2 = Mission Total Emissions
######################################

df = data %>%
  group_by(constellation) %>%
  summarize(
    mean = mean(mission_total_emissions),
    sd = sd(mission_total_emissions)
  )

df$Constellation = factor(df$constellation)
emission_totals <-
  ggplot(df, aes(x = Constellation, y = mean / 1e6, fill = Constellation)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean / 1e6 - sd / 1e6, ymax = mean / 1e6 + sd / 1e6),
    width = .2,
    position = position_dodge(.9),
    color = 'black',
    size = 0.3
  ) + geom_text(
    aes(label = round(after_stat(y), 2), group = Constellation),
    stat = "summary",
    fun = sum,
    vjust = -.3,
    hjust = -0.6,
    size = 2.5
  ) + 
  scale_fill_brewer(palette = "Paired") + theme_minimal() +
  theme(legend.position = 'right') + labs(
    colour = NULL,
    title = "Total Constellation Emissions",
    subtitle = "Error bars: 1 Standard Deviation (SD).",
    x = NULL,
    y = "Total Emissions \n(kt)"
  ) + scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0), limits = c(0, 30),
  ) + theme_minimal() +
  theme(
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 7),
    axis.title.y = element_text(size = 7),
    axis.line = element_line(colour = "black")
  ) + theme(legend.position = 'none', axis.title = element_text(size = 8)) + theme(
    legend.text = element_text(size = 8),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10)
  ) 


##########################################
##plot3 = Emissions Vs Capacity Provided##
##########################################

df = data %>%
  group_by(constellation) %>%
  summarize(
    mean = mean(mission_emission_per_capacity * 1e3),
    sd = sd(mission_emission_per_capacity * 1e3)
  )

df$Constellation = factor(df$constellation)
emission_capacity <-
  ggplot(df, aes(x = Constellation, y = mean, fill = Constellation)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean - sd, ymax = mean + sd),
    width = .2,
    position = position_dodge(.9),
    color = "black",
    size = 0.3
  ) + geom_text(
    aes(label = round(after_stat(y), 1), group = Constellation),
    stat = "summary",
    fun = sum,
    vjust = -.5,
    hjust = -0.4,
    size = 2.5
  ) +
  scale_fill_brewer(palette = "Paired") + theme_minimal() +
  theme(legend.position = 'right') + labs(
    colour = NULL,
    title = "Emissions vs Provided Capacity",
    subtitle = "Error bars: 1 SD.",
    x = NULL,
    y = "Emissions \n(t/GBps)",
    fill = "Constellations"
  ) + scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0),
    limits = c(0, 1300)
  ) +
  theme_minimal() + theme(
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 7),
    axis.title.y = element_text(size = 7),
    axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = "none", axis.title = element_text(size = 8)) +
  theme(
    legend.text = element_text(size = 8),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10)
  )


##############################
##plot4 = Emissions Vs Cost###
##############################

df = data %>%
  group_by(constellation) %>%
  summarize(
    mean = mean(mission_emission_for_every_cost * 1e3),
    sd = sd(mission_emission_for_every_cost * 1e3)
  )

df$Constellation = factor(df$constellation)
emission_cost <-
  ggplot(df, aes(x = Constellation, y = mean, fill = Constellation)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean - sd, ymax = mean + sd),
    width = .2,
    position = position_dodge(.9),
    color = "black",
    size = 0.3
  ) + geom_text(
    aes(label = round(after_stat(y), 2), group = Constellation),
    stat = "summary",
    fun = sum,
    vjust = -.5,
    hjust = -0.6,
    size = 2.5
  ) + 
  scale_fill_brewer(palette = "Paired") + theme_minimal() +
  theme(legend.position = 'right') + labs(
    colour = NULL,
    title = "Emissions vs Investment Cost",
    subtitle = "Error bars: 1 SD.",
    x = NULL,
    y = "Emissions \n(kt/US$ 1 Billion)",
    fill = "Constellations"
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0), limits = c(0, 16),
  ) + theme_minimal() + theme(
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 7),
    axis.title.y = element_text(size = 7),
    axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = "none", axis.title = element_text(size = 8)) +
  theme(
    legend.text = element_text(size = 8),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10)
  )


##############################
##plot5 = Emissions Vs Area###
##############################

df = data %>%
  group_by(constellation) %>%
  summarize(
    mean = mean(mission_emission_per_sqkm),
    sd = sd(mission_emission_per_sqkm)
  )

df$Constellation = factor(df$constellation)
emission_sqkm <-
  ggplot(df, aes(x = Constellation, y = mean, fill = Constellation)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean - sd, ymax = mean + sd),
    width = .2,
    position = position_dodge(.9),
    color = "black",
    size = 0.3
  ) +
  geom_text(
    aes(label = round(after_stat(y), 2), group = Constellation),
    stat = "summary",
    fun = sum,
    vjust = -.5,
    hjust = -0.6,
    size = 2.5
  ) +
  scale_fill_brewer(palette = "Paired") + theme_minimal() +
  theme(legend.position = 'right') + labs(
    colour = NULL,
    title = "Emissions vs Coverage Area",
    subtitle = "Error bars: 1 SD.",
    x = NULL,
    y = "Emissions \n(Kilograms per km^2)",
    fill = "Constellations"
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0),
    limits = c(0, 200)
  ) + theme_minimal() + theme(
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 7),
    axis.title.y = element_text(size = 7),
    axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = "none", axis.title = element_text(size = 8)) +
  theme(
    legend.text = element_text(size = 8),
    plot.subtitle = element_text(size = 8),
    plot.title = element_text(size = 10)
  )

# EMISSION VALIDATION WITH COLUMBIA DATA
constellation <- c("Kuiper", "OneWeb", "Starlink", "Terrestrial")
subscribers_high <- c(500000, 100000, 800000, 61000000)
total_emissions_full <- c(29, 0.04, 18, 187)
emission_sub <-
  c(29 * 1e6 / 1000000,
    0.04 * 1e6 / 300000,
    18 * 1e6 / 1500000,
    187 * 1e6 / 61800000)

sat_terres <-
  data.frame(constellation, subscribers_high, emission_sub)
emission_validation <-
  ggplot(sat_terres,
         aes(x = constellation, y = emission_sub,
             fill = constellation)) + geom_text(
               aes(label = round(after_stat(y), 2),
                   group = constellation),
               stat = "summary",
               fun = sum,
               vjust = -.5,
               size = 2.5
             ) +
  geom_bar(stat = "identity", size = 0.9) + scale_fill_brewer(palette = "Paired") +
  theme_minimal() + theme(legend.position = "right") +
  labs(
    colour = NULL,
    title = "Constellations vs Terrestrial",
    subtitle = "Comparison of emissions.",
    x = NULL,
    y = "Emission \n(kg/subscriber)",
    caption = "Terrestrial network is based on 2020 Columbian \nMobile Network Operators (América Móvil, \nTelefonica and Millicom) market data.",
    fill = 'Constellations'
  ) + scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0),
    limits = c(0, 32)
  ) +
  theme_minimal() + theme(
    strip.text.x = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 7),
    axis.title.y = element_text(size = 7),
    axis.line = element_line(colour = "black")
  ) +
  theme(legend.position = 'none', axis.title = element_text(size = 5)) +
  theme(
    plot.caption = element_text(size = 6, color = "black", face = "italic")
  ) + theme(legend.text = element_text(size = 5),
            plot.subtitle = element_text(size = 8),
            plot.title = element_text(size = 10))

# Save emission validation results
pub_emission <-
  ggarrange(
    fuel_types, fuel_factors,
    emission_totals,
    emission_subscriber,
    emission_capacity,
    emission_cost,
    nrow = 3,
    ncol = 2,
    labels = c("a", "b", "c", "d", "e", "f")
  )

path = file.path(folder, 'figures', 'pub_emission.tiff')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
tiff(
  path,
  units = "in",
  width = 6.3,
  height = 8,
  res = 480
)
print(pub_emission)
dev.off()

