library(ggpubr)
library(ggplot2)
library(tidyverse)
library(ggtext)
library(gridExtra)
library("readxl")

folder <- dirname(rstudioapi::getSourceEditorContext()$path)

filename = "constellation_information.csv"
data = read.csv(file.path(folder, '..', 'data', 'raw', filename))

data = data[(data$Properties != 'Launch Vehicle'),]

create_table <- function(starting_name, constellation) {
  df = data[(data$Constellation == constellation),]
  df$Constellation = NULL
  rownames(df) = df$Properties
  df$Properties = NULL
  filename = paste(starting_name, tolower(constellation), '_table.png')
  folder_tables = file.path(folder, 'figures', 'tables')
  if (!dir.exists(folder_tables)) {dir.create(folder_tables)}
  path = file.path(folder_tables, filename)
  dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
  png(
    path,
    units = "in",
    width = 5,
    height = 4,
    res = 480
  )
  print(grid.table(df))
  dev.off()
}

create_table('aa_','Starlink')
create_table('bb_','OneWeb')
create_table('cc_','Kuiper')

rct = read.csv(file.path(folder, '..', 'data', 'raw', "rockets_table.csv"),
               row.names = 1)
new_names <- c('Falcon-9', 'Falcon-Heavy', 'Soyuz-FG', 'Ariane-5')
colnames(rct) <- new_names

filename = 'dd_rockets_table.png'
folder_tables = file.path(folder, 'figures', 'tables')
path = file.path(folder_tables, filename)
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
png(
  path,
  units = "in",
  width = 12.5,
  height = 3,
  res = 480
)
print(grid.table(rct))
dev.off()
