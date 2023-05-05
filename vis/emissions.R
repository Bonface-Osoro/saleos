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

climate_change_wc <- c(595012795.9, 87278232.09, 258836443.9, 
      485150868.1, 596332.0885, 305994064.1, 5856534706,
      893608259.6, 32325271.14, 19378203.99, 64466609.67,
      86572.07616, 113331134.8, 239684676, 290566364.3,
      119603503.2, 122743338.5, 414029327.8, 1274333.643,
      419325198.9, 1971041785)

ozone_depletion <- c(40.26969277, 8.455065994, 12.05780847,
      40.71209018, 0.102211235, 42.00500185, 4683344.4, 
      62.23635459, 3.131505924, 2.19997646, 5.756972014,
      0.026791027, 15.55740809, 63142.8, 21.74603442,
      11.58657192, 14.14725189, 36.95730308, 0.264053,
      57.56240995, 505951.32)

ozone_depletion_wc <- c(40.26969277, 8.455065994, 12.05780847,
      40.71209018, 0.102211235, 42.00500185, 11398514.4, 62.23635459, 
      3.131505924, 2.19997646, 5.756972014, 0.026791027, 
      15.55740809, 277445, 21.74603442, 11.58657192, 
      14.14725189, 36.95730308, 0.264053, 57.56240995, 2276780.94)

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
      climate_change, climate_change_wc, ozone_depletion, 
      ozone_depletion_wc, resource_depletion, 
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
  c("launcher", "propellant", "campaign", 
    "transportation", "ait", 
    "scheduling", "launching"),
  labels = c("Launcher Production", "Launcher Propellant Production", 
    "Launch Campaign", "Transportation of Launcher", 
    "Launcher AIT", "SCHD of Propellant", "Launch Event"))
climate_change <- ggplot(df, aes(x = Constellation, y = mean/1e6)) +
  geom_bar(stat = "identity", aes(fill = category)) + 
  geom_text(
    aes(x = constellation, y = value/1e6, label = round(value/1e6, 0)),
    size = 1.2,
    data = totals,
    vjust = -1,
    hjust = 0.5,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") + theme_minimal() + 
  theme(legend.position = "right") + labs(
    colour = NULL,
    title = "a",
    subtitle = " ",
    x = NULL,
    y = "Kt Carbon dioxides Eqv.",
    fill = "Satellite Mission Stage"
  ) + scale_y_continuous(limits = c(0, 8500),
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) +   theme(plot.title = element_text(face = "bold")) + 
  theme(legend.position = "none", axis.title = element_text(size = 6)) + 
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


#####################################
##plot1 = Global warming worst case##
#####################################
df = individual_emissions %>%
  group_by(constellation, category) %>%
  summarize(
    mean = mean(climate_change_wc),
    sd = sd(climate_change_wc)
  )

totals <- individual_emissions %>%
  group_by(constellation) %>%
  summarize(value = signif(sum(climate_change_wc)))

df$Constellation = factor(df$constellation)
df$category = factor(df$category, levels = 
   c("launcher", "propellant", "campaign", 
   "transportation", "ait", 
   "scheduling", "launching"),
   labels = c("Launcher Production", "Launcher Propellant Production", 
   "Launch Campaign", "Transportation of Launcher", 
   "Launcher AIT", "SCHD of Propellant", "Launch Event"))
climate_change_wc <- ggplot(df, aes(x = Constellation, y = mean/1e6)) +
  geom_bar(stat = "identity", aes(fill = category)) + 
  geom_text(
    aes(x = constellation, y = value/1e6, label = round(value/1e6, 0)),
    size = 1.2,
    data = totals,
    vjust = -1,
    hjust = 0.5,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") + theme_minimal() + 
  theme(legend.position = "right") + labs(
    colour = NULL,
    title = "b",
    subtitle = " ",
    x = NULL,
    y = "Kt Carbon dioxides Eqv.",
    fill = "Satellite Mission Stage"
  ) + scale_y_continuous(limits = c(0, 8500),
                         labels = function(y)
                           format(y, scientific = FALSE),
                         expand = c(0, 0)
  ) +   theme(plot.title = element_text(face = "bold")) + 
  theme(legend.position = "none", axis.title = element_text(size = 6)) + 
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
                       c("launcher", "propellant", "campaign", 
                         "transportation", "ait", 
                         "scheduling", "launching"),
                     labels = c("Launcher Production", "Launcher Propellant Production", 
                                "Launch Campaign", "Transportation of Launcher", 
                                "Launcher AIT", "SCHD of Propellant", "Launch Event"))
ozone_depletion <- ggplot(df, aes(x = Constellation, y = mean/1e6)) +
  geom_bar(stat = "identity", aes(fill = category)) + 
  geom_text(
    aes(x = constellation, y = value/1e6, label = round(value/1e6, 1)),
    size = 1.2,
    data = totals,
    vjust = -1,
    hjust = 0.5,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") + theme_minimal() + 
  theme(legend.position = "right") + labs(
    colour = NULL,
    title = "c",
    subtitle = " ",
    x = NULL,
    y = "Kt CFC-11 \nEqv.",
    fill = "Satellite Mission Stage"
  ) + scale_y_continuous(limits = c(0, 30),
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) +  theme(plot.title = element_text(face = "bold")) + 
  theme(legend.position = "none", axis.title = element_text(size = 6)) + 
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
##plot2 = Ozone Depletion worst scenario##
##########################################
df = individual_emissions %>%
  group_by(constellation, category) %>%
  summarize(
    mean = mean(ozone_depletion_wc),
    sd = sd(ozone_depletion_wc)
  )

totals <- individual_emissions %>%
  group_by(constellation) %>%
  summarize(value = signif(sum(ozone_depletion_wc)))

df$Constellation = factor(df$constellation)
df$category = factor(df$category, levels = 
                       c("launcher", "propellant", "campaign", 
                         "transportation", "ait", 
                         "scheduling", "launching"),
                     labels = c("Launcher Production", "Launcher Propellant Production", 
                                "Launch Campaign", "Transportation of Launcher", 
                                "Launcher AIT", "SCHD of Propellant", "Launch Event"))
ozone_depletion_wc <- ggplot(df, aes(x = Constellation, y = mean/1e6)) +
  geom_bar(stat = "identity", aes(fill = category)) + 
  geom_text(
    aes(x = constellation, y = value/1e6, label = round(value/1e6, 1)),
    size = 1.2,
    data = totals,
    vjust = -1,
    hjust = 0.5,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") + theme_minimal() + 
  theme(legend.position = "right") + labs(
    colour = NULL,
    title = "d",
    subtitle = " ",
    x = NULL,
    y = "Kt CFC-11 \nEqv.",
    fill = "Satellite Mission Stage"
  ) + scale_y_continuous(limits = c(0, 30),
                         labels = function(y)
                           format(y, scientific = FALSE),
                         expand = c(0, 0)
  ) +  theme(plot.title = element_text(face = "bold")) + 
  theme(legend.position = "none", axis.title = element_text(size = 6)) + 
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
                       c("launcher", "propellant", "campaign", 
                         "transportation", "ait", 
                         "scheduling", "launching"),
                     labels = c("Launcher Production", "Launcher Propellant Production", 
                                "Launch Campaign", "Transportation of Launcher", 
                                "Launcher AIT", "SCHD of Propellant", "Launch Event"))
resource_depletion <- ggplot(df, aes(x = Constellation, y = mean/1e3)) +
  geom_bar(stat = "identity", aes(fill = category)) + 
  geom_text(
    aes(x = constellation, y = value/1e3, label = round(value/1e3, 0)),
    size = 1.2,
    data = totals,
    vjust = -1,
    hjust = 0.5,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") + theme_minimal() + 
  theme(legend.position = "right") + labs(
    colour = NULL,
    title = "e",
    subtitle = " ",
    x = NULL,
    y = "Tonnes Sb. Eqv.",
    fill = "Satellite Mission Stage"
  ) + scale_y_continuous(limits = c(0, 500),
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) +   theme(plot.title = element_text(face = "bold")) + 
  theme(legend.position = "none", axis.title = element_text(size = 6)) + 
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
                       c("launcher", "propellant", "campaign", 
                         "transportation", "ait", 
                         "scheduling", "launching"),
                     labels = c("Launcher Production", "Launcher Propellant Production", 
                                "Launch Campaign", "Transportation of Launcher", 
                                "Launcher AIT", "SCHD of Propellant", "Launch Event"))
freshwater_ecotixicity <- ggplot(df, aes(x = Constellation, y = mean/1e8)) +
  geom_bar(stat = "identity", aes(fill = category)) + 
  geom_text(
    aes(x = constellation, y = value/1e8, label = round(value/1e8, 0)),
    size = 1.2,
    data = totals,
    vjust = -1,
    hjust = 0.5,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") + theme_minimal() + 
  theme(legend.position = "right") + labs(
    colour = NULL,
    title = "f",
    subtitle = " ",
    x = NULL,
    y = "PAF.M3.DAY (bquote(~10^7))",
    fill = "Satellite Mission Stage"
  ) + scale_y_continuous(limits = c(0, 300),
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) + ylab(bquote('PAF.M3.DAY ('*~10^8*')')) +
  theme(plot.title = element_text(face = "bold")) + 
  theme(legend.position = "none", axis.title = element_text(size = 6)) + 
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
                       c("launcher", "propellant", "campaign", 
                         "transportation", "ait", 
                         "scheduling", "launching"),
                     labels = c("Launcher Production", "Launcher Propellant Production", 
                                "Launch Campaign", "Transportation of Launcher", 
                                "Launcher AIT", "SCHD of Propellant", "Launch Event"))
human_toxicity <- ggplot(df, aes(x = Constellation, y = mean)) +
  geom_bar(stat = "identity", aes(fill = category)) + 
  geom_text(
    aes(x = constellation, y = value, label = round(value, 0)),
    size = 1,
    data = totals,
    vjust = -1,
    hjust = 0.5,
    position = position_stack()
  )  + scale_fill_brewer(palette = "Dark2") +
  theme(legend.position = "right") + labs(
    colour = NULL,
    title = "g",
    subtitle = " ",
    x = NULL,
    y = "CASES",
    fill = "Satellite Mission Stage"
  ) + scale_y_continuous(limits = c(0, 850),
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) + theme_minimal() +
  theme(plot.title = element_text(face = "bold")) + 
  theme(legend.position = "none", axis.title = element_text(size = 6)) + 
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

#################
## Legend plot ##
#################
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
df$Category = factor(df$category, levels = 
                       c("launcher", "propellant", "campaign", 
                         "transportation", "ait", 
                         "scheduling", "launching"),
                     labels = c("Launcher \nProduction", "Launcher \nPropellant \nProduction", 
                                "Launch \nCampaign", "Transportation \nof Launcher", 
                                "Launcher \nAssembling \nIntegration \n& Testing", "Scheduling \nof \nPropellant", "Launch \nEvent"))
legends <- ggplot(df, aes(x = mean, y = mean, color = Category))+
  geom_point(size=0.005) + 
  lims(x = c(0,0), y = c(0,0))+ labs(fill = "Satellite Mission Stage") +
  theme_void()+ scale_color_brewer(palette = "Dark2") +
  theme(legend.direction = "vertical",
        legend.position = c(0.67, 0.45),
        legend.key.size = unit(1, "cm"),
        legend.text = element_text(size =  5),
        legend.title = element_text(size = 7, face = "bold"))+
  guides(colour = guide_legend(override.aes = list(size=8),
                               ncol = 3, nrow = 4))

####################################
## Combine all the emission plots ##
####################################

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
  ncol = 2) 


path = file.path(folder, 'figures', 'pub_individual_emission.png')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
png(
  path,
  units = "in",
  width = 5.3,
  height = 7.1,
  res = 480
)
print(pub_emission)
dev.off()


######################################
##plot1 = Emission per Subscriber#####
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
    total_emissions,
    total_climate_emissions,
    total_climate_emissions_wc
  )

###################
##Rocket Fuels#####
###################
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
amount <- c(500000*74, 218150*20, 7360*20, 10000*54, 480000*54, 184900*54)
fuels_df <- data.frame(rockets, fuel, amount)

totals <- fuels_df %>%
  group_by(rockets) %>%
  summarize(value = signif(sum(amount / 1e6), 2))

fuel_types = ggplot(fuels_df, aes(x = rockets, y = amount / 1e6)) +
  geom_bar(stat = "identity", aes(fill = fuel)) +
  geom_text(
    aes(x = rockets, y = value, label = round(after_stat(y), 2)),
    size = 1.5,
    data = totals,
    vjust = -1,
    hjust = 0.5,
    position = position_stack()
  ) +
  scale_fill_brewer(palette = "Dark2") + labs(
    colour = NULL,
    title = "a",
    subtitle = " ",
    x = NULL,
    y = "Fuel \nAmounts (Mt)",
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
    axis.line = element_line(colour = "black")
  ) + theme(plot.title = element_text(face = "bold")) +
  theme(legend.direction = "vertical",
        legend.position = c(0.80, 0.65),
        axis.title = element_text(size = 4)) + 
  guides(fill = guide_legend(ncol = 1, nrow = 4)) +
  theme(
    legend.title = element_text(size = 4),
    legend.text = element_text(size = 4),
    plot.subtitle = element_text(size = 6),
    plot.title = element_text(size = 8)
  )


###########################
##plot1 = Total Emissions##
###########################
df = data %>%
  group_by(constellation) %>%
  summarize(
    mean = mean(total_climate_emissions),
    sd = sd(total_climate_emissions)
  )

totals <- data %>%
  group_by(constellation) %>%
  summarize(value = signif(sum(total_climate_emissions)))


df$Constellation = factor(df$constellation)

emission_totals <- ggplot(df, aes(x = Constellation, y = mean/1e6)) +
  geom_bar(stat = "identity") + 
  geom_errorbar(
    aes(ymin = mean/1e6 - sd/1e6, ymax = mean/1e6 + sd/1e6),
    width = .2,
    position = position_dodge(.9),
    color = "black",
    size = 0.2
  ) + 
  geom_text(
    aes(label = round(after_stat(y), 0), group = Constellation),
    stat = "summary",
    fun = sum,
    vjust = -.5,
    hjust = -0.8,
    size = 1.5
  ) +
  scale_fill_brewer(palette = "Dark2") +
  theme(legend.position = "right") + labs(
    colour = NULL,
    title = "(B) Total Emissions (Baseline Case)",
    subtitle = "Reported for climate change impacts",
    x = NULL,
    y = "Total Emissions (Mt)",
    fill = "Category"
  ) + scale_y_continuous(#limits = c(0, 55),
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) +   theme_minimal() + theme(
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


######################################
##plot1 = Total Emissions worst Case##
######################################
df = data %>%
  group_by(constellation) %>%
  summarize(
    mean = mean(total_climate_emissions_wc),
    sd = sd(total_climate_emissions_wc)
  )

totals <- data %>%
  group_by(constellation) %>%
  summarize(value = signif(sum(total_climate_emissions_wc)))


df$Constellation = factor(df$constellation)

emission_totals_wc <- ggplot(df, aes(x = Constellation, y = mean/1e6)) +
  geom_bar(stat = "identity") + 
  geom_errorbar(
    aes(ymin = mean/1e6 - sd/1e6, ymax = mean/1e6 + sd/1e6),
    width = .2,
    position = position_dodge(.9),
    color = "black",
    size = 0.2
  ) + 
  geom_text(
    aes(label = round(after_stat(y), 0), group = Constellation),
    stat = "summary",
    fun = sum,
    vjust = -.5,
    hjust = -0.8,
    size = 1.5
  ) +
  scale_fill_brewer(palette = "Dark2") +
  theme(legend.position = "right") + labs(
    colour = NULL,
    title = "(C) Total Emissions (Worst Case)",
    subtitle = "Black carbon, aluminium oxide and water vapour included",
    x = NULL,
    y = "Total Emissions (Mt)",
    fill = "Category"
  ) + scale_y_continuous(#limits = c(0, 55),
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0)
  ) +   theme_minimal() + theme(
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
  y = mean/1e3)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean/1e3 - sd/1e4, ymax = mean/1e3 + sd/1e4),
    width = .2,
    position = position_dodge(.9),
    color = "black",
    size = 0.2
  ) + geom_text(
    aes(label = round(after_stat(y), 0), group = Constellation),
    stat = "summary",
    fun = sum,
    vjust = -.5,
    hjust = -0.8,
    size = 1.5
  ) +
  scale_fill_brewer(palette = "Dark2") + theme_minimal() +
  theme(legend.position = 'right') + labs(
    colour = NULL,
    title = "(E) Emissions vs User Traffic",
    subtitle = "Average monthly traffic (Traffic error bars: 1 SD.)",
    x = NULL,
    y = "Emissions (t/GB)",
    fill = "Constellations"
  ) + scale_y_continuous(limits = c(0, 17000),
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
  y = mean)) +
  geom_bar(stat = "identity",
           position = position_dodge(),
           width = 0.98) +
  geom_errorbar(
    aes(ymin = mean - sd/1, ymax = mean + sd/1),
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
  scale_fill_brewer(palette = "Dark2") + theme_minimal() +
  theme(legend.position = 'right') + labs(
    colour = NULL,
    title = "(F) Emissions vs Investment Cost",
    subtitle = "Cost error bars: 1 SD.",
    x = NULL,
    y = "Emissions (kg/US$)",
    fill = "Constellations"
  ) +
  scale_y_continuous(
    labels = function(y)
      format(y, scientific = FALSE),
    expand = c(0, 0), limits = c(0, 1),
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
    aes(ymin = mean - sd, ymax = mean + sd),
    width = .2,
    position = position_dodge(.9),
    color = 'black',
    size = 0.2
  ) +
  scale_fill_brewer(palette = "Dark2") + theme_minimal() +
  theme(legend.position = 'right') + labs(
    colour = NULL,
    title = "b",
    subtitle = " ",
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
    fuel_types,
    emission_subscriber,
    nrow = 1,
    ncol = 2
  )

path = file.path(folder, 'figures', 'combined_emission.png')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
tiff(
  path,
  units = "in",
  width = 6,
  height = 3,
  res = 480
)
print(pub_emission)
dev.off()



