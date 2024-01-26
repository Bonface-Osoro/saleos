library(ggpubr)
library(ggplot2)
library(tidyverse)
library(ggtext)
library(gridExtra)
library("readxl")

folder <- dirname(rstudioapi::getSourceEditorContext()$path)

# Read rocket data from csv files.
stl = read.csv(file.path(folder, '..', 'data', 'raw', "starlink.csv"),
               row.names = 1)
ow = read.csv(file.path(folder, '..', 'data', 'raw', "oneweb.csv"),
              row.names = 1)
kp = read.csv(file.path(folder, '..', 'data', 'raw', "kuiper.csv"),
              row.names = 1)
rct = read.csv(file.path(folder, '..', 'data', 'raw', "rockets_table.csv"),
               row.names = 1)

# Create Tables
path = file.path(folder, 'figures', 'aa_starlink_table.png')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
png(
  path,
  units = "in",
  width = 5,
  height = 4,
  res = 480
)
print(grid.table(stl))
dev.off()


path = file.path(folder, 'figures', 'bb_oneweb_table.png')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
png(
  path,
  units = "in",
  width = 5,
  height = 4,
  res = 480
)
print(grid.table(ow))
dev.off()

path = file.path(folder, 'figures', 'cc_kuiper_table.png')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
png(
  path,
  units = "in",
  width = 5,
  height = 4,
  res = 480
)
print(grid.table(kp))
dev.off()

path = file.path(folder, 'figures', 'dd_rockets_table.png')
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
