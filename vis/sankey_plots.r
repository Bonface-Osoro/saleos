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

# Falcon Heavy Sankey Image
im_bb <- ggplot() + background_image(img2b) + 
  theme(plot.margin = margin(t=0, l=0, r=0, b=0, unit ="cm"))

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

# Starlink falcon heavy sankey image
im_gg <- ggplot() + background_image(img6b) + 
  theme(plot.margin = margin(t=1, l=0, r=0, b=0, unit ="cm"))

# OneWeb sankey image
im_H <- ggplot() + background_image(img7) + 
  theme(plot.margin = margin(t=0, l=0, r=0, b=0, unit ="cm"))

# Kuiper sankey image
im_J <- ggplot() + background_image(img8) + 
  theme(plot.margin = margin(t=0, l=0, r=0, b=0, unit ="cm"))


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
tiff(path, units="in", width=3.2, height=2, res=480)
print(grid.table(stl))
dev.off()

path = file.path(folder, 'pics','oneweb_table.tiff')
dir.create(file.path(folder, 'pics'),showWarnings = FALSE)
tiff(path, units="in", width=3.2, height=2, res=480)
print(grid.table(ow))
dev.off()

path = file.path(folder, 'pics','kuiper_table.tiff')
dir.create(file.path(folder, 'pics'),showWarnings = FALSE)
tiff(path, units="in", width=3.2, height=2, res=480)
print(grid.table(kp))
dev.off()

path = file.path(folder, 'pics','rockets_table.tiff')
dir.create(file.path(folder, 'pics'),showWarnings = FALSE)
tiff(path, units="in", width=12.5, height=3, res=480)
print(grid.table(rct))
dev.off()

path = file.path(folder, 'pics','constellations_table.tiff')
dir.create(file.path(folder, 'pics'),showWarnings = FALSE)
tiff(path, units="in", width=8, height=3, res=480)
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

orbits <- ggarrange(AK, AL, AM, nrow = 1, ncol = 3, 
                    labels = c("a", 
                               "b", 
                               "c"),
                    heights = c(1, 1, 1), align = c("hv"))

path = file.path(folder, 'sankey','orbits.png')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
png(path, units="in", width=12, height=3.5, res=300)
print(orbits )
dev.off()

path = file.path(folder, 'pics','orbits.tiff')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
tiff(path, units="in", width = 15, height = 4, res = 480)
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

path = file.path(folder, 'figures','constellation_sankey.png')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
png(path, units="in", width=12, height=9, res=300)
print(const_sankey)
dev.off()
