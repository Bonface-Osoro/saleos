
library(ggplot2)
library(ggpubr)
# library(patchwork)
# library(gridExtra)
# library(webshot)
# library(png)
# library(grid)
# library(ggpmisc)
# library(plotly)
# library(webr)

folder <- dirname(rstudioapi::getSourceEditorContext()$path)



img1 <- readPNG(file.path(folder, 'pics', "ariane_resized.png"))
img5 <- readPNG(file.path(folder, 'pics', "soyuz_resized.png"))
img1a <- readPNG(file.path(folder, 'pics', "falcon_resized.png"))


#READ IMAGES
# Falcon 9 rocket Diagrams
im_AA <- ggplot() + background_image(img1a) + 
  theme(plot.margin = margin(t=0, l=0, r=0, b=0, unit ="cm"))   

# Soyuz FG rocket images
im_AB <- ggplot() + background_image(img5) + 
  theme(text=element_text(size=10), 
        plot.margin = margin(t=0, l=0, r=0, b=0, unit ="cm"))

# Ariane5 rocket images
im_AC <- ggplot() + background_image(img1) + 
  theme(text=element_text(size=10), 
        plot.margin = margin(t=0, l=0, r=0, b=0, unit ="cm"))


p1 <- ggarrange(im_AA, im_AB, im_AC,
                ncol = 1, nrow = 3,
            widths = c(0.2, 0.2, 0.2))

#export to folder
path = file.path(folder, 'figures', 'test.png')
ggsave(path,  units="in", width=1, height=9, dpi=300)
print(p1)
dev.off()

# p2 <- ggarrange(AD , AF, AG + font("x.text", size = 9),
#                 ncol = 1, nrow = 3)
# p3 <- ggarrange(im_G, im_H, im_J + font("x.text", size = 9),
#                 ncol = 1, nrow = 3)

# rocket_sankey <- ggarrange(p1, p2, p3,  nrow = 1, ncol = 3, 
#                            labels = c("(A) Rocket Vehicles", 
#                                       "(B) Rocket Details", 
#                                       "(C) Rocket Sankey Plots"),
#                            widths = c(0.2, 0.2, 0.2))
# rocket_sankey