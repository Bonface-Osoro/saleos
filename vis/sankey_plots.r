library(networkD3)
library(ggplot2)
library(ggpubr)
library(patchwork)
library(gridExtra)
library(png)
library(grid)
library(ggpmisc)
library(plotly)
library(webr)
library(knitr)
library(kableExtra)
library(magrittr)
library(webshot)
library(htmlwidgets)

folder <- dirname(rstudioapi::getSourceEditorContext()$path)

#FALCON HEAVY
nodes = data.frame("name" = c("FALCON-HEAVY","Kerosene (1397 t)",
                              "Carbon IV Oxide (491.74 t)", 
                              "Aluminium IV Oxide (69.85 t)", 
                              "Sulphur IV Oxide (0.978 t)", 
                              "Chlorofluorocarbons (19.56 t)", 
                              "Particulate Matter (70.56 t)", 
                              "Photochemical Oxidation (34.94 t)"))
links = as.data.frame(matrix(c(0, 1, 240.1, 1, 2, 171.9, 1, 2, 24.4,
                               1, 3, 0.3, 1, 4, 6.8, 1, 5, 24.5,
                               1, 6, 12.2), byrow = TRUE, ncol = 3))
names(links) = c("source", "target", "value")
fal_heav <- sankeyNetwork(Links = links, Nodes = nodes,
                   Source = "source", Target = "target",
                   Value = "value", NodeID = "name",
                   fontSize= 20, fontFamily = 'Helvetica')
path = file.path(folder,'sankey','sankey.html')
saveNetwork(fal_heav, path)
pathsave = file.path(folder, "sankey", "falcon_heavy_sankey.png")
webshot(path, pathsave, 
        vwidth = 900, vheight = 500)

# Starlink FALCON HEAVY
nodes = data.frame("name" = c("FALCON HEAVY (74 Missions)", "Kerosene (103.4 kt)",
                              "Carbon IV Oxide (36.39 kt)", 
                              "Aluminium IV Oxide (5.169 kt)", 
                              "Sulphur IV Oxide (72.37 t)", 
                              "Chlorofluorocarbons (1.447 kt)", 
                              "Particulate Matter (5.192 kt)", 
                              "Photochemical Oxidation (2.585 kt)"))
links = as.data.frame(matrix(c(0, 1, 240.1, 1, 2, 171.9, 1, 2, 24.4,
                               1, 3, 0.3, 1, 4, 6.8, 1, 5, 24.5,
                               1, 6, 12.2), byrow = TRUE, ncol = 3))
names(links) = c("source", "target", "value")
starlink_heav <- sankeyNetwork(Links = links, Nodes = nodes,
                          Source = "source", Target = "target",
                          Value = "value", NodeID = "name",
                          fontSize= 20, fontFamily = 'Helvetica')
path = file.path(folder,'sankey','sankey.html')
saveNetwork(starlink_heav, path)
pathsave = file.path(folder, "sankey", "starlink_heavy_sankey.png")
webshot(path, pathsave, 
        vwidth = 900, vheight = 500)

#FALCON 9
nodes = data.frame("name" = c("FALCON-9", "Kerosene (488.4 t)",
                              "Carbon IV Oxide (171.2 t)", 
                              "Aluminium IV Oxide (24.4 t)", 
                              "Sulphur IV Oxide (0.3 t)", 
                              "Chlorofluorocarbons (6.8 t)", 
                              "Particulate Matter (24.5 t)", 
                              "Photochemical Oxidation (12.2 t)"))
links = as.data.frame(matrix(c(0, 1, 240.1, 1, 2, 171.9, 1, 2, 24.4,
                               1, 3, 0.3, 1, 4, 6.8, 1, 5, 24.5,
                               1, 6, 12.2), byrow = TRUE, ncol = 3))
names(links) = c("source", "target", "value")
a <- sankeyNetwork(Links = links, Nodes = nodes,
                   Source = "source", Target = "target",
                   Value = "value", NodeID = "name",
                   fontSize= 20, fontFamily = 'Helvetica')
path = file.path(folder,'sankey','sankey.html')
saveNetwork(a, path)
pathsave = file.path(folder, "sankey", "falcon9_sankey.png")
webshot(path, pathsave, 
        vwidth = 800, vheight = 500)

# STARLINK
nodes = data.frame("name" = c("FALCON-9(74 Missions)","Kerosene (36.1 kt)",
                              "Carbon IV Oxide (12.7 kt)", 
                              "Aluminium IV Oxide (1.8 kt)", 
                              "Sulphur IV Oxide (22.2 t)", 
                              "Chlorofluorocarbons (6.8 t)", 
                              "Particulate Matter (24.5 t)", 
                              "Photochemical Oxidation (12.2 t)"))
links = as.data.frame(matrix(c(0, 1, 240.1, 1, 2, 171.9, 1, 2, 24.4,
                               1, 3, 0.3, 1, 4, 6.8, 1, 5, 24.5,
                               1, 6, 12.2), byrow = TRUE, ncol = 3))
names(links) = c("source", "target", "value")
s <- sankeyNetwork(Links = links, Nodes = nodes,
              Source = "source", Target = "target",
              Value = "value", NodeID = "name",
              fontSize= 20, fontFamily = 'Helvetica')

path = file.path(folder, 'sankey', 'sankey.html')
saveNetwork(s, path)
pathsave = file.path(folder, "sankey", "starlink_sankey.png")
webshot(path,pathsave,  vwidth = 900, vheight = 500)


#SOYUZ FG
nodes = data.frame("name" = c("SOYUZ-FG","Kerosene (218 t)", 
                              "Hypergolic (7.4 t)", 
                              "Aluminium IV Oxide (10.9 t)", 
                              "Carbon IV Oxide (78.6 t)",
                              "Sulphur IV Oxide (0.2 t)", 
                              "Chlorofluorocarbons (3.1 t)",
                              "Particulate Matter (11 t)", 
                              "Photochemical Oxidation (5.6 t)"))
links = as.data.frame(matrix(c(0, 1, 283.8, 0, 2, 294.9,
                             1, 3, 263.8, 1, 4, 0.2, 1, 5, 3.2,
                             1, 6, 11, 1, 7, 5.6, 2, 3, 10.9,
                             2, 4, 263.8, 2, 5, 0.2, 2, 6, 3.2, 2, 7, 11,
                             2, 8, 5.6), byrow = TRUE, ncol = 3))
names(links) = c("source", "target", "value")
b <- sankeyNetwork(Links = links, Nodes = nodes,
              Source = "source", Target = "target",
              Value = "value", NodeID = "name",
              fontSize= 35, fontFamily = 'Helvetica')
path = file.path(folder, 'sankey', 'sankey.html')
saveNetwork(b, path)
pathsave = file.path(folder, "sankey", "soyuzfg_sankey.png")
webshot(path, pathsave, vwidth = 1600, vheight = 1000)

#ONEWEB
nodes = data.frame("name" = c("SOYUZ-FG(20 Missions)","Kerosene (4.4 kt)", 
                              "Hypergolic (0.1 kt)", 
                              "Aluminium IV Oxide (0.2 kt)", 
                              "Carbon IV Oxide (1.6 kt)",
                              "Sulphur IV Oxide (4 t)", 
                              "Chlorofluorocarbons (62 t)",
                              "Particulate Matter (0.2 kt)", 
                              "Photochemical Oxidation (0.1 kt)"))
links = as.data.frame(matrix(c(0, 1, 283.8, 0, 2, 294.9,
                               1, 3, 263.8, 1, 4, 0.2, 1, 5, 3.2,
                               1, 6, 11, 1, 7, 5.6, 2, 3, 10.9,
                               2, 4, 263.8, 2, 5, 0.2, 2, 6, 3.2, 2, 7, 11,
                               2, 8, 5.6), byrow = TRUE, ncol = 3))
names(links) = c("source", "target", "value")
w <- sankeyNetwork(Links = links, Nodes = nodes,
              Source = "source", Target = "target",
              Value = "value", NodeID = "name",
              fontSize= 20, fontFamily = 'Helvetica')
path = file.path(folder, 'sankey', 'sankey.html')
saveNetwork(w, path)
pathsave = file.path(folder, "sankey", "oneweb_sankey.png")
webshot(path, pathsave, vwidth = 900, vheight = 500)

#ARIANE
nodes = data.frame("name" = c("ARIANE-5", "Solid (480 t)", 
                              "Cryogenic (184.9 t)","Hypergolic (10 t)", 
                              "Carbon IV Oxide (54.4 t)", 
                              "Aluminium IV Oxide (158.4 t)", 
                              "Sulphur IV Oxide (65.2 t)", 
                              "Chlorofluorocarbons (86.7 t)", 
                              "Particulate Matter (159 t)", 
                              "Photochemical Oxidation (6.3 t)"))
links = as.data.frame(matrix(c(0, 1, 530, 0, 2, 530, 0, 3, 530, 
                               1, 4, 54.4,
                               1, 5, 158.4, 1, 6, 65.2, 1, 7, 86.7,
                               1, 8, 159, 1, 9, 6.3, 2, 4, 54.4,
                               2, 5, 158.4, 2, 6, 65.2, 2, 7, 86.7,
                               2, 8, 159, 2, 9, 6.3, 3, 4, 54.4,
                               3, 5, 158.4, 3, 6, 65.2, 3, 7, 86.7, 
                               3, 8, 159, 3, 9, 6.3), byrow = TRUE, ncol = 3))
names(links) = c("source", "target", "value")
c <- sankeyNetwork(Links = links, Nodes = nodes, nodePadding = 10,
              Source = "source", Target = "target",
              Value = "value", NodeID = "name",
              fontSize= 35, fontFamily = 'Helvetica')
path = file.path(folder, 'sankey', 'sankey.html')
saveNetwork(c, path)
pathsave = file.path(folder, "sankey", "ariane5_sankey.png")
webshot(path, pathsave, vwidth = 1600, vheight = 1000)

#KUIPER
nodes = data.frame("name" = c("ARIANE-5 (54 Missions)", "Solid (26 kt)", 
                              "Cryogenic (10 kt)","Hypergolic (0.5 kt)", 
                              "Carbon IV Oxide (3 kt)", 
                              "Aluminium IV Oxide (8.6 kt)", 
                              "Sulphur IV Oxide (3.5 kt)", 
                              "Chlorofluorocarbons (4.7 kt)", 
                              "Particulate Matter (8.6 kt)", 
                              "Photochemical Oxidation (0.3 kt)"))
links = as.data.frame(matrix(c(0, 1, 530, 0, 2, 530, 0, 3, 530, 
                               1, 4, 54.4,
                               1, 5, 158.4, 1, 6, 65.2, 1, 7, 86.7,
                               1, 8, 159, 1, 9, 6.3, 2, 4, 54.4,
                               2, 5, 158.4, 2, 6, 65.2, 2, 7, 86.7,
                               2, 8, 159, 2, 9, 6.3, 3, 4, 54.4,
                               3, 5, 158.4, 3, 6, 65.2, 3, 7, 86.7, 
                               3, 8, 159, 3, 9, 6.3), byrow = TRUE, ncol = 3))
names(links) = c("source", "target", "value")
k <- sankeyNetwork(Links = links, Nodes = nodes, nodePadding = 10,
              Source = "source", Target = "target",
              Value = "value", NodeID = "name",
              fontSize= 35, fontFamily = 'Helvetica')
path = file.path(folder, 'sankey', 'sankey.html')
saveNetwork(k, path)
pathsave = file.path(folder, "sankey", "kuiper_sankey.png")
webshot(path, pathsave, vwidth = 1600, vheight = 1000)


# READ SANKEY PNG IMAGES
# 1. Combined Images
img1 <- readPNG(file.path(folder, 'pics', "ariane_resized.png"))
img5 <- readPNG(file.path(folder, 'pics', "soyuz_resized.png"))
img1a <- readPNG(file.path(folder, 'pics', "falcon_resized.png"))
img2a <- readPNG(file.path(folder, 'pics', "falcon_heavy.png"))
img2a

#2. Rockets
img2 <- readPNG(file.path(folder, 'sankey', "falcon9_sankey.png"))
img2b <- readPNG(file.path(folder, 'sankey', "falcon_heavy_sankey.png"))
img3 <- readPNG(file.path(folder, 'sankey', "soyuzfg_sankey.png"))
img4 <- readPNG(file.path(folder, 'sankey', "ariane5_sankey.png"))

#3. Constellations 
img6 <- readPNG(file.path(folder, 'sankey', "starlink_sankey.png"))
img6b <- readPNG(file.path(folder, 'sankey', "starlink_heavy_sankey.png"))
img7 <- readPNG(file.path(folder, 'sankey', "oneweb_sankey.png"))
img8 <- readPNG(file.path(folder, 'sankey', "kuiper_sankey.png"))

img9 <- readPNG(file.path(folder, 'pics', "starnet.png"))

#READ IMAGES
# Falcon 9 rocket Diagrams
im_AA <- ggplot() + background_image(img1a) + 
  theme(plot.margin = margin(t=1, l=0, r=0, b=0, unit ="cm"))   
# Falcon Heavy rocket Diagram
im_aa <- ggplot() + background_image(img2a) + 
  theme(plot.margin = margin(t=1, l=0, r=0, b=0, unit ="cm"))  

# Soyuz FG rocket images
im_AB <- ggplot() + background_image(img5) + 
  theme(text=element_text(size=10), 
        plot.margin = margin(t=1, l=0, r=0, b=0, unit ="cm"))

# Ariane5 rocket images
im_AC <- ggplot() + background_image(img1) + 
  theme(text=element_text(size=10), 
        plot.margin = margin(t=1, l=0, r=0, b=0, unit ="cm"))

# Falcon 9 sankey image
im_B <- ggplot() + background_image(img2) + 
  theme(plot.margin = margin(t=0, l=0, r=0, b=0, unit ="cm"))
im_B

# Falcon Heavy Sankey Image
im_bb <- ggplot() + background_image(img2b) + 
  theme(plot.margin = margin(t=0, l=0, r=0, b=0, unit ="cm"))
im_bb

# Soyuz FG sankey image
im_C <- ggplot() + background_image(img3) + 
  theme(plot.margin = margin(t=0, l=1, r=0, b=0, unit ="cm")) +
  labs(title = "Soyuz-FG", subtitle = " ")

# ariane sankey image
im_D <- ggplot() + background_image(img4) + 
  theme(plot.margin = margin(t=0, l=0, r=0, b=0, unit ="cm")) + 
  labs(title = "Ariane-5", subtitle = " ")

# Starlink sankey image
im_G <- ggplot() + background_image(img6) + 
  theme(plot.margin = margin(t=1, l=0, r=0, b=0, unit ="cm"))
im_G

# Starlink falcon heavy sankey image
im_gg <- ggplot() + background_image(img6b) + 
  theme(plot.margin = margin(t=1, l=0, r=0, b=0, unit ="cm"))
im_gg

# OneWeb sankey image
im_H <- ggplot() + background_image(img7) + 
  theme(plot.margin = margin(t=0, l=0, r=0, b=0, unit ="cm"))
im_H

# Kuiper sankey image
im_J <- ggplot() + background_image(img8) + 
  theme(plot.margin = margin(t=0, l=0, r=0, b=0, unit ="cm"))
im_J


# ROCKET TABLE

# Read rocket data from csv files.
ft = read.csv(file.path(folder, "table", "falcon table.csv"), row.names = 1, TRUE)
fh = read.csv(file.path(folder, "table", "falcon_heavy_table.csv"), row.names = 1, TRUE)
st = read.csv(file.path(folder, "table", "soyuz table.csv"), row.names = 1)
at = read.csv(file.path(folder, "table", "ariane table.csv"), row.names = 1)
stl = read.csv(file.path(folder, "table", "starlink.csv"), row.names = 1)
ow = read.csv(file.path(folder, "table", "oneweb.csv"), row.names = 1)
kp = read.csv(file.path(folder, "table", "kuiper.csv"), row.names = 1)
rct = read.csv(file.path(folder, "table", "rockets_table.csv"), row.names = 1)
ct = read.csv(file.path(folder, "table", "constellationns_table.csv"), row.names = 1)
names(rct)[names(rct) == "Falcon_9"] <- "Falcon-9"
names(rct)[names(rct) == "Falcon.Heavy"] <- "Falcon Heavy"
names(rct)[names(rct) == "Soyuz_FG"] <- "Soyuz-FG"
names(rct)[names(rct) == "Ariane_5"] <- "Ariane-5"

# Create Tables
falcon <- kable(ft, "html", escape = F) %>%
  kable_classic("striped", full_width = F, html_font = "Helvetica", font_size = 9)

falcon_heavy <- kable(fh, "html", escape = F) %>%
  kable_classic("striped", full_width = F, html_font = "Helvetica", font_size = 9)

soyuz <- kable(st, "html", escape = F) %>%
  kable_classic("striped", full_width = F, html_font = "Helvetica", font_size = 9)

ariane <- kable(at, "html", escape = F) %>%
  kable_classic("striped", full_width = F, html_font = "Helvetica", font_size = 9)

starlink <- kable(stl, "html", escape = F) %>%
  kable_classic("striped", full_width = F, html_font = "Helvetica", font_size = 9)

oneweb <- kable(ow, "html", escape = F) %>%
  kable_classic("striped", full_width = F, html_font = "Helvetica", font_size = 9)

kuiper <- kable(kp, "html", escape = F) %>%
  kable_classic("striped", full_width = F, html_font = "Helvetica", font_size = 9)

#
# Save the images
path = file.path(folder, 'pics')
setwd(path)
kableExtra::save_kable(falcon, file='falcon_table.png', zoom = 1.5)

path = file.path(folder, 'pics')
setwd(path)
kableExtra::save_kable(falcon_heavy, file='falcon_heavy_table.png', zoom = 1.5)

path = file.path(folder, 'pics')
setwd(path)
kableExtra::save_kable(soyuz, file='soyuz_table.png', zoom = 1.5)

path = file.path(folder, 'pics')
setwd(path)
kableExtra::save_kable(ariane, file='ariane_table.png', zoom = 1.5)

path = file.path(folder, 'pics','falcon_table.tiff')
dir.create(file.path(folder, 'pics'),showWarnings = FALSE)
tiff(path, units="in", width=4.5, height=3, res=480)
print(grid.table(ft))
dev.off()

path = file.path(folder, 'pics','falcon_heavy_table.tiff')
dir.create(file.path(folder, 'pics'),showWarnings = FALSE)
tiff(path, units="in", width=4.5, height=3, res=480)
print(grid.table(fh))
dev.off()

path = file.path(folder, 'pics','soyuz_table.tiff')
dir.create(file.path(folder, 'pics'),showWarnings = FALSE)
tiff(path, units="in", width=4.5, height=3, res=480)
print(grid.table(st))
dev.off()

path = file.path(folder, 'pics','ariane_table.tiff')
dir.create(file.path(folder, 'pics'),showWarnings = FALSE)
tiff(path, units="in", width=4.5, height=3, res=480)
print(grid.table(at))
dev.off()

path = file.path(folder, 'pics','starlink_table.tiff')
dir.create(file.path(folder, 'pics'),showWarnings = FALSE)
tiff(path, units="in", width=4, height=2, res=480)
print(grid.table(stl))
dev.off()

path = file.path(folder, 'pics','oneweb_table.tiff')
dir.create(file.path(folder, 'pics'),showWarnings = FALSE)
tiff(path, units="in", width=4, height=2, res=480)
print(grid.table(ow))
dev.off()

path = file.path(folder, 'pics','kuiper_table.tiff')
dir.create(file.path(folder, 'pics'),showWarnings = FALSE)
tiff(path, units="in", width=4, height=2, res=480)
print(grid.table(kp))
dev.off()

path = file.path(folder, 'pics','rockets_table.tiff')
dir.create(file.path(folder, 'pics'),showWarnings = FALSE)
tiff(path, units="in", width=12.5, height=3, res=480)
print(grid.table(rct))
dev.off()

path = file.path(folder, 'pics','constellations_table.tiff')
dir.create(file.path(folder, 'pics'),showWarnings = FALSE)
tiff(path, units="in", width=6, height=1.5, res=480)
print(grid.table(ct))
dev.off()

path = file.path(folder, 'pics','constellations_table.png')
dir.create(file.path(folder, 'pics'),showWarnings = FALSE)
png(path, units="in", width=6, height=1.5, res=480)
print(grid.table(ct))
dev.off()

# Reading the images
im1 <- readPNG(file.path(folder, 'pics', 'falcon_table.png'))
im2 <- readPNG(file.path(folder, 'pics', "soyuz_table.png"))
im3 <- readPNG(file.path(folder, 'pics', "ariane_table.png"))
im4 <- readPNG(file.path(folder, 'pics', "starlink_table.png"))
im5 <- readPNG(file.path(folder, 'pics', "oneweb_table.png"))
im6 <- readPNG(file.path(folder, 'pics', "kuiper_table.png"))
im7 <- readPNG(file.path(folder, 'pics', "starlink_orbit.png"))
im8 <- readPNG(file.path(folder, 'pics', "oneweb_orbit.png"))
im9 <- readPNG(file.path(folder, 'pics', "kuiper_orbit.png"))
im10 <- readPNG(file.path(folder, 'pics', "rockets_table.png"))
im11 <- readPNG(file.path(folder, 'pics', "constellations_table.png"))

AD <- ggplot() + background_image(im1) + 
  theme(plot.margin = margin(t=1, l=0, r=0, b=0, unit ="cm"))
AF <- ggplot() + background_image(im2) + 
  theme(plot.margin = margin(t=0, l=0, r=0, b=0, unit ="cm"))
AG <- ggplot() + background_image(im3) + 
  theme(plot.margin = margin(t=0, l=0, r=0, b=0, unit ="cm"))
AH <- ggplot() + background_image(im4) + 
  theme(plot.margin = margin(t=0, l=0, r=1, b=0, unit ="cm"))
AI <- ggplot() + background_image(im5) + 
  theme(plot.margin = margin(t=0, l=0, r=1, b=0, unit ="cm"))
AJ <- ggplot() + background_image(im6) + 
  theme(plot.margin = margin(t=0, l=0, r=1, b=0, unit ="cm"))
AK <- ggplot() + background_image(im7) + 
  theme(plot.margin = margin(t=1, l=1, r=1, b=0, unit ="cm"))
AL <- ggplot() + background_image(im8) + 
  theme(plot.margin = margin(t=1, l=1, r=1, b=0, unit ="cm"))
AM <- ggplot() + background_image(im9) + 
  theme(plot.margin = margin(t=1, l=1, r=1, b=0, unit ="cm"))
AN <- ggplot() + background_image(im10) + 
  theme(plot.margin = margin(t=0, l=0, r=0, b=0, unit ="cm"))
AO <- ggplot() + background_image(im11) + 
  theme(plot.margin = margin(t=0, l=0, r=0, b=0, unit ="cm"))

# FUEL COMPOSITION BY ROCKETS

# Falcon-9
Rocket <- c("Falcon-9")
Fuel <- c("Kerosene")
amount <- c(488370)
dfalcon <- data.frame(Rocket, Fuel, amount)

# Falcon-heavy
Rocket <- c("Falcon-Heavy")
Fuel <- c("Kerosene")
amount <- c(1397000)
dheavy <- data.frame(Rocket, Fuel, amount)

# Soyuz-FG
Rocket <- c("Soyuz-FG")
Fuel <- c("Kerosene", "Hypergolic")
amount <- c(218150, 7360) 
dsoyuz <- data.frame(Rocket, Fuel, amount)

# Ariane-5
Rocket <- c("Ariane-5")
Fuel <- c("Solid","Cryogenic", "Hypergolic")
amount <- c(10000, 480000, 184900) 
dariane <- data.frame(Rocket, Fuel, amount)

#Merge the dataframes
drockets <- rbind(dfalcon, dheavy, dsoyuz, dariane)

fuels <- ggplot(drockets, aes(x=Rocket, y=amount/1e3, fill=Fuel)) + 
  geom_bar(stat="identity", position=position_dodge()) +
  scale_fill_brewer(palette="Paired") + 
  labs(colour=NULL, 
       title = "Rocket Fuel Compositions", 
       x = "Rocket Names", y = "Fuel Amounts (t)") +
  scale_y_continuous(labels = function(y) format(y, 
  scientific = FALSE), expand = c(0, 0)) +
  facet_wrap(~Rocket, scales = "free", ncol = 4) + theme_minimal() +
  theme(strip.text.x = element_blank(),
        panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.line = element_line(colour = "black")) +
  theme(legend.position = 'bottom')
fuels

path = file.path(folder, 'figures','fuel_composition.png')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
png(path, units="in", width=10, height=3, res=480)
print(fuels)
dev.off()

# These codes only labels the sankey diagrams for easy editing in pptx



p1 <- ggarrange(im_AA, im_AB, im_AC + font("x.text", size = 9),
                ncol = 1, nrow = 3)
p2 <- ggarrange(AD , AF, AG + font("x.text", size = 5),
                ncol = 1, nrow = 3)
p3 <- ggarrange(im_G, im_H, im_J + font("x.text", size = 9),
                ncol = 1, nrow = 3)

rocket_sankey <- ggarrange(p1, p2, p3,  nrow = 1, ncol = 3, 
          labels = c("(A) Rockets", 
          "(B) Rocket Details", 
          "(C) Rocket Sankey Plots"), widths = c(0.5, 0.5, 0.7))
rocket_sankey

path = file.path(folder, 'figures','rocket_sankey.png')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
png(path, units="in", width=10, height=8, res=720)
print(rocket_sankey)
dev.off()

orbits <- ggarrange(AK, AL, AM, nrow = 1, ncol = 3, 
                    labels = c("(A) Starlink Network", 
                               "(B) OneWeb Network", 
                               "(C) Kuiper Network"),
                    heights = c(1, 1, 1), align = c("hv"))

path = file.path(folder, 'sankey','orbits.png')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
png(path, units="in", width=12, height=3.5, res=300)
print(orbits )
dev.off()

path = file.path(folder, 'sankey','orbits.tiff')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
tiff(path, units="in", width=12, height=3.5, res=300)
print(orbits )
dev.off()

q1 <- ggarrange(AK, AM, AL + font("x.text", size = 9),
                ncol = 1, nrow = 3)
q2 <- ggarrange(AH, AI, AJ + font("x.text", size = 9),
                ncol = 1, nrow = 3)
q3 <- ggarrange(im_G, im_H, im_J + font("x.text", size = 9),
                ncol = 1, nrow = 3)
const_sankey <- ggarrange(q1, q2, q3, nrow = 1, ncol = 3, 
          labels = c("(A) LEO Orbit Designs", 
          "(B) Constellation Details", 
          "(C) Constellation Sankeys"),
          heights = c(1, 1, 1), align = c("hv"))
const_sankey
path = file.path(folder, 'figures','constellation_sankey.png')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
png(path, units="in", width=12, height=9, res=300)
print(const_sankey)
dev.off()
