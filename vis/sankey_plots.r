library(networkD3)
library(ggplot2)
library(ggpubr)
library(patchwork)
library(gridExtra)
library(webshot)
library(png)
library(grid)
library(ggpmisc)
library(plotly)

folder <- dirname(rstudioapi::getSourceEditorContext()$path)

#FALCON 9
nodes = data.frame("name" = c("Kerosene (488.4 t)",
                              "Carbon IV Oxide (171.2 t)", 
                              "Aluminium IV Oxide (24.4 t)", 
                              "Sulphur IV Oxide (0.3 t)", 
                              "Chlorofluorocarbons (6.8 t)", 
                              "Particulate Matter (24.5 t)", 
                              "Photochemical Oxidation (12.2 t)"))
links = as.data.frame(matrix(c(0, 1, 171.9, 0, 2, 24.4,
                               0, 3, 0.3, 0, 4, 6.8, 0, 5, 24.5,
                               0, 6, 12.2), byrow = TRUE, ncol = 3))
names(links) = c("source", "target", "value")
a <- sankeyNetwork(Links = links, Nodes = nodes,
                   Source = "source", Target = "target",
                   Value = "value", NodeID = "name",
                   fontSize= 20, fontFamily = 'Helvetica')
path = file.path(folder, 'sankey', 'sankey.html')
saveNetwork(a, path)
webshot("/Users/osoro/GitHub/saleos/vis/sankey/sankey.html","/Users/osoro/GitHub/saleos/vis/sankey/falcon9_sankey.png", 
        vwidth = 1000, vheight = 900)

# STARLINK
nodes = data.frame("name" = c("Kerosene (36.1 kt)",
                              "Carbon IV Oxide (12.7 kt)", 
                              "Aluminium IV Oxide (1.8 kt)", 
                              "Sulphur IV Oxide (22.2 t)", 
                              "Chlorofluorocarbons (6.8 t)", 
                              "Particulate Matter (24.5 t)", 
                              "Photochemical Oxidation (12.2 t)"))
links = as.data.frame(matrix(c(0, 1, 171.9, 0, 2, 24.4,
                               0, 3, 0.3, 0, 4, 6.8, 0, 5, 24.5,
                               0, 6, 12.2), byrow = TRUE, ncol = 3))
names(links) = c("source", "target", "value")
s <- sankeyNetwork(Links = links, Nodes = nodes,
              Source = "source", Target = "target",
              Value = "value", NodeID = "name",
              fontSize= 30, fontFamily = 'Helvetica')

path = file.path(folder, 'sankey', 'sankey.html')
saveNetwork(s, path)
webshot("/Users/osoro/GitHub/saleos/vis/sankey/sankey.html","/Users/osoro/GitHub/saleos/vis/sankey/starlink_sankey.png", 
        vwidth = 1000, vheight = 900)


#SOYUZ FG
nodes = data.frame("name" = c("Kerosene (218 t)", 
                              "Hypergolic (7.4 t)", 
                              "Aluminium IV Oxide (10.9 t)", 
                              "Carbon IV Oxide (78.6 t)",
                              "Sulphur IV Oxide (0.2 t)", 
                              "Chlorofluorocarbons (3.1 t)",
                              "Particulate Matter (11 t)", 
                              "Photochemical Oxidation (5.6 t)"))
links = as.data.frame(matrix(c(0, 2, 10.9,
                               0, 3, 263.8, 0, 4, 0.2, 0, 5, 3.2,
                               0, 6, 11, 0, 7, 5.6, 1, 2, 10.9,
                               1, 3, 263.8, 1, 4, 0.2, 1, 6, 3.2, 1, 6, 11,
                               1, 7, 5.6), byrow = TRUE, ncol = 3))
names(links) = c("source", "target", "value")
b <- sankeyNetwork(Links = links, Nodes = nodes,
              Source = "source", Target = "target",
              Value = "value", NodeID = "name",
              fontSize= 20, fontFamily = 'Helvetica')
path = file.path(folder, 'sankey', 'sankey.html')
saveNetwork(b, path)
webshot("/Users/osoro/GitHub/saleos/vis/sankey/sankey.html","/Users/osoro/GitHub/saleos/vis/sankey/soyuzfg_sankey.png", 
        vwidth = 1000, vheight = 900)
#ONEWEB
nodes = data.frame("name" = c("Kerosene (4.4 kt)", 
                              "Hypergolic (0.1 kt)", 
                              "Aluminium IV Oxide (0.2 kt)", 
                              "Carbon IV Oxide (1.6 kt)",
                              "Sulphur IV Oxide (4 t)", 
                              "Chlorofluorocarbons (62 t)",
                              "Particulate Matter (0.2 kt)", 
                              "Photochemical Oxidation (0.1 kt)"))
links = as.data.frame(matrix(c(0, 2, 10.9,
                               0, 3, 263.8, 0, 4, 0.2, 0, 5, 3.2,
                               0, 6, 11, 0, 7, 5.6, 1, 2, 10.9,
                               1, 3, 263.8, 1, 4, 0.2, 1, 6, 3.2, 1, 6, 11,
                               1, 7, 5.6), byrow = TRUE, ncol = 3))
names(links) = c("source", "target", "value")
w <- sankeyNetwork(Links = links, Nodes = nodes,
              Source = "source", Target = "target",
              Value = "value", NodeID = "name",
              fontSize= 20, fontFamily = 'Helvetica')
path = file.path(folder, 'sankey', 'sankey.html')
saveNetwork(w, path)
webshot("/Users/osoro/GitHub/saleos/vis/sankey/sankey.html","/Users/osoro/GitHub/saleos/vis/sankey/oneweb_sankey.png", 
        vwidth = 1000, vheight = 900)

#ARIANE
nodes = data.frame("name" = c("Solid (480 t)", 
                              "Cryogenic (184.9 t)","Hypergolic (10 t)", 
                              "Carbon IV Oxide (54.4 t)", 
                              "Aluminium IV Oxide (158.4 t)", 
                              "Sulphur IV Oxide (65.2 t)", 
                              "Chlorofluorocarbons (86.7 t)", 
                              "Particulate Matter (159 t)", 
                              "Photochemical Oxidation (6.3 t)"))
links = as.data.frame(matrix(c(0, 3, 54.4,
                               0, 4, 158.4, 0, 5, 65.2, 0, 6, 86.7,
                               0, 7, 159, 0, 8, 6.3, 1, 3, 54.4,
                               1, 4, 158.4, 1, 5, 65.2, 1, 6, 86.7,
                               1, 7, 159, 1, 8, 6.3, 2, 3, 54.4,
                               2, 4, 158.4, 2, 5, 65.2, 2, 6, 86.7, 
                               2, 7, 159, 2, 8, 6.3), byrow = TRUE, ncol = 3))
names(links) = c("source", "target", "value")
c <- sankeyNetwork(Links = links, Nodes = nodes, nodePadding = 10,
              Source = "source", Target = "target",
              Value = "value", NodeID = "name",
              fontSize= 20, fontFamily = 'Helvetica')
path = file.path(folder, 'sankey', 'sankey.html')
saveNetwork(c, path)
webshot("/Users/osoro/GitHub/saleos/vis/sankey/sankey.html","/Users/osoro/GitHub/saleos/vis/sankey/ariane5_sankey.png", 
        vwidth = 1000, vheight = 900)

#KUIPER
nodes = data.frame("name" = c("Solid (26 kt)", 
                              "Cryogenic (10 kt)","Hypergolic (0.5 kt)", 
                              "Carbon IV Oxide (3 kt)", 
                              "Aluminium IV Oxide (8.6 kt)", 
                              "Sulphur IV Oxide (3.5 kt)", 
                              "Chlorofluorocarbons (4.7 kt)", 
                              "Particulate Matter (8.6 kt)", 
                              "Photochemical Oxidation (0.3 kt)"))
links = as.data.frame(matrix(c(0, 3, 54.4,
                               0, 4, 158.4, 0, 5, 65.2, 0, 6, 86.7,
                               0, 7, 159, 0, 8, 6.3, 1, 3, 54.4,
                               1, 4, 158.4, 1, 5, 65.2, 1, 6, 86.7,
                               1, 7, 159, 1, 8, 6.3, 2, 3, 54.4,
                               2, 4, 158.4, 2, 5, 65.2, 2, 6, 86.7, 
                               2, 7, 159, 2, 8, 6.3), byrow = TRUE, ncol = 3))
names(links) = c("source", "target", "value")
k <- sankeyNetwork(Links = links, Nodes = nodes, nodePadding = 10,
              Source = "source", Target = "target",
              Value = "value", NodeID = "name",
              fontSize= 20, fontFamily = 'Helvetica')
path = file.path(folder, 'sankey', 'sankey.html')
saveNetwork(k, path)
webshot("/Users/osoro/GitHub/saleos/vis/sankey/sankey.html","/Users/osoro/GitHub/saleos/vis/sankey/kuiper_sankey.png", 
        vwidth = 1000, vheight = 900)


# READ SANKEY PNG IMAGES
# 1. Combined Images
img1 <- readPNG(file.path(folder, 'pics', "ariane5_rocket.png"))
img5 <- readPNG(file.path(folder, 'pics', "soyuzfg_rocket.png"))
img1a <- readPNG(file.path(folder, 'pics', "falcon9_rocket.png"))

#2. Rockets
img2 <- readPNG(file.path(folder, 'sankey', "falcon9_sankey.png"))
img3 <- readPNG(file.path(folder, 'sankey', "soyuzfg_sankey.png"))
img4 <- readPNG(file.path(folder, 'sankey', "ariane5_sankey.png"))

#3. Constellations 
img6 <- readPNG(file.path(folder, 'sankey', "starlink_sankey.png"))
img7 <- readPNG(file.path(folder, 'sankey', "oneweb_sankey.png"))
img8 <- readPNG(file.path(folder, 'sankey', "kuiper_sankey.png"))

img9 <- readPNG(file.path(folder, 'pics', "starnet.png"))

#READ IMAGES
# Falcon 9 rocket Diagrams
im_AA <- ggplot() + background_image(img1a) + 
  theme(plot.margin = margin(t=1, l=0, r=0, b=0, unit ="cm"))   

# Soyuz FG rocket images
im_AB <- ggplot() + background_image(img5) + 
  theme(text=element_text(size=10), 
        plot.margin = margin(t=1.5, l=1, r=0, b=0, unit ="cm"))

# Ariane5 rocket images
im_AC <- ggplot() + background_image(img1) + 
  theme(text=element_text(size=10), 
        plot.margin = margin(t=1.5, l=1, r=0, b=0, unit ="cm"))

# Falcon 9 sankey image
im_B <- ggplot() + background_image(img2) + 
  theme(plot.margin = margin(t=1, l=0, r=0, b=0, unit ="cm"))
im_B
# Soyuz FG sankey image
im_C <- ggplot() + background_image(img3) + 
  theme(plot.margin = margin(t=0, l=0, r=0, b=0, unit ="cm")) +
  labs(title = "Soyuz-FG", subtitle = " ")

# ariane sankey image
im_D <- ggplot() + background_image(img4) + 
  theme(plot.margin = margin(t=0, l=0, r=0, b=0, unit ="cm")) + 
  labs(title = "Ariane-5", subtitle = " ")

# Starlink sankey image
im_G <- ggplot() + background_image(img6) + 
  theme(plot.margin = margin(t=1, l=0, r=1, b=0, unit ="cm"))
im_G

# OneWeb sankey image
im_H <- ggplot() + background_image(img7) + 
  theme(plot.margin = margin(t=0, l=0, r=1, b=0, unit ="cm"))
im_H

# Kuiper sankey image
im_J <- ggplot() + background_image(img8) + 
  theme(plot.margin = margin(t=0, l=0, r=1, b=0, unit ="cm"))
im_J


# ROCKET TABLE

# Read rocket data from csv files.
ft = read.csv(file.path(folder, "table", "falcon table.csv"), row.names = 1, TRUE)
st = read.csv(file.path(folder, "table", "soyuz table.csv"), row.names = 1)
at = read.csv(file.path(folder, "table", "ariane table.csv"), row.names = 1)
stl = read.csv(file.path(folder, "table", "starlink.csv"), row.names = 1)
ow = read.csv(file.path(folder, "table", "oneweb.csv"), row.names = 1)
kp = read.csv(file.path(folder, "table", "kuiper.csv"), row.names = 1)
rct = read.csv(file.path(folder, "table", "rockets_table.csv"), row.names = 1)
ct = read.csv(file.path(folder, "table", "constellationns_table.csv"), row.names = 1)

# Save the images
path = file.path(folder, 'pics','falcon_table.png')
dir.create(file.path(folder, 'pics'),showWarnings = FALSE)
png(path, units="in", width=4, height=3, res=480)
print(grid.table(ft))
dev.off()

path = file.path(folder, 'pics','soyuz_table.png')
dir.create(file.path(folder, 'pics'),showWarnings = FALSE)
png(path, units="in", width=4.1, height=3, res=480)
print(grid.table(st))
dev.off()

path = file.path(folder, 'pics','ariane_table.png')
dir.create(file.path(folder, 'pics'),showWarnings = FALSE)
png(path, units="in", width=4.1, height=3, res=480)
print(grid.table(at))
dev.off()

path = file.path(folder, 'pics','starlink_table.png')
dir.create(file.path(folder, 'pics'),showWarnings = FALSE)
png(path, units="in", width=4, height=3.5, res=480)
print(grid.table(stl))
dev.off()

path = file.path(folder, 'pics','oneweb_table.png')
dir.create(file.path(folder, 'pics'),showWarnings = FALSE)
png(path, units="in", width=4, height=3.5, res=480)
print(grid.table(ow))
dev.off()

path = file.path(folder, 'pics','kuiper_table.png')
dir.create(file.path(folder, 'pics'),showWarnings = FALSE)
png(path, units="in", width=4, height=3.5, res=480)
print(grid.table(kp))
dev.off()

path = file.path(folder, 'pics','rockets_table.png')
dir.create(file.path(folder, 'pics'),showWarnings = FALSE)
png(path, units="in", width=4, height=3, res=480)
print(grid.table(rct))
dev.off()

path = file.path(folder, 'pics','constellations_table.png')
dir.create(file.path(folder, 'pics'),showWarnings = FALSE)
png(path, units="in", width=4, height=3, res=480)
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
  theme(plot.margin = margin(t=0, l=0, r=0, b=0, unit ="cm"))
AF <- ggplot() + background_image(im2) + 
  theme(plot.margin = margin(t=0, l=0, r=0, b=0, unit ="cm"))
AG <- ggplot() + background_image(im3) + 
  theme(plot.margin = margin(t=0, l=0, r=1, b=0, unit ="cm"))
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

p1 <- ggarrange(im_AA, im_AB, im_AC + font("x.text", size = 9),
                ncol = 1, nrow = 3)
p2 <- ggarrange(AD, AF, AG + font("x.text", size = 9),
                ncol = 1, nrow = 3)
p3 <- ggarrange(im_G, im_H, im_J + font("x.text", size = 9),
                ncol = 1, nrow = 3)

rocket_sankey <- ggarrange(p1, p2, p3, nrow = 1, ncol = 3, 
          labels = c("(A) Rocket Vehicles", 
          "(B) Rocket Details", 
          "(C) Rocket Sankey Plots"),
          heights = c(0.7, 0.6, 1.1), align = c("hv"))
rocket_sankey

path = file.path(folder, 'figures','rocket_sankey.tiff')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
tiff(path, units="in", width=10, height=9, res=300)
print(rocket_sankey)
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
path = file.path(folder, 'figures','constellation_sankey.tiff')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
tiff(path, units="in", width=12, height=9, res=300)
print(const_sankey)
dev.off()
