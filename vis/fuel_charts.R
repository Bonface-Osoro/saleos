library(ggplot2)
library(webr)

Falcon_9 <- c("Kerosene")
amount <- c(488370)
df <- data.frame(Falcon_9, amount)
f <- PieDonut(df, aes(Falcon_9, count=amount),
              explodeDonut=TRUE, maxx=1.3, r0=0.5)

Soyuz_FG <- c("Kerosene", "Hypergolic")
amount <- c(218150, 7360) 
df <- data.frame(Soyuz_FG, amount)
s <- PieDonut(df, aes(Soyuz_FG, count=amount),
         explodeDonut=TRUE, maxx=1.3, r0=0.5)

Ariane_5 <- c("Solid","Cryogenic", "Hypergolic")
amount <- c(10000, 480000, 184900) 
df <- data.frame(Ariane_5, amount)
a <- PieDonut(df, aes(Ariane_5, count=amount),use.labels = TRUE,
         start=3*pi/2,explodeDonut=TRUE,maxx=1.3, r0=0.5)












