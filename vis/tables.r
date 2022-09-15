library(knitr)
library(kableExtra)
library(magrittr)
folder <- dirname(rstudioapi::getSourceEditorContext()$path)
ft = read.csv(file.path(folder, "table", "falcon table.csv"), row.names = 1, TRUE)
st = read.csv(file.path(folder, "table", "soyuz table.csv"), row.names = 1, TRUE)
at = read.csv(file.path(folder, "table", "ariane table.csv"), row.names = 1, TRUE)

falcon <- kable(ft, "html", escape = F) %>%
  kable_classic("striped", full_width = F, html_font = "Helvetica")

path = file.path(folder, 'pics')
setwd(path)
kableExtra::save_kable(falcon, file='falcon_table.png', zoom = 1.5)

soyuz <- kable(st, "html", escape = F) %>%
  kable_classic("striped", full_width = F, html_font = "Helvetica")

path = file.path(folder, 'pics')
setwd(path)
kableExtra::save_kable(soyuz, file='soyuz_table.png', zoom = 1.5)

ariane <- kable(at, "html", escape = F) %>%
  kable_classic("striped", full_width = F, html_font = "Helvetica")

path = file.path(folder, 'pics')
setwd(path)
kableExtra::save_kable(ariane, file='ariane_table.png', zoom = 1.5)

# Reading the images
im1 <- readPNG(file.path(folder, 'pics', 'falcon_table.png'))
im2 <- readPNG(file.path(folder, 'pics', "soyuz_table.png"))
im3 <- readPNG(file.path(folder, 'pics', "ariane_table.png"))

AD <- ggplot() + background_image(im1) + 
  theme(plot.margin = margin(t=0, l=0, r=0, b=0, unit ="cm"))
AF <- ggplot() + background_image(im2) + 
  theme(plot.margin = margin(t=0, l=0, r=0, b=0, unit ="cm"))
AG <- ggplot() + background_image(im3) + 
  theme(plot.margin = margin(t=0, l=0, r=1, b=0, unit ="cm"))

tables <- ggarrange(AD , AF, AG + font("x.text", size = 9),
          ncol = 1, nrow = 3)

path = file.path(folder, 'figures','tables.png')
dir.create(file.path(folder, 'figures'), showWarnings = FALSE)
png(path, units="in", width=, height=11, res=720)
print(tables)
dev.off()










