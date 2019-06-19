library(hexSticker)
library(UCSCXenaTools)
library(dplyr)
library(ggpubr)

df =  XenaData %>%
    dplyr::group_by(XenaHostNames) %>%
    dplyr::summarise(count = n())

# reference https://rpkgs.datanovia.com/ggpubr/
ggdotchart(df, x = "XenaHostNames", y = "count",
           color = "XenaHostNames",
           palette = "jco",
           sorting = "descending",                       # Sort value in descending order
           add = "segments",                             # Add segments from y = 0 to dots
           rotate = TRUE,                                # Rotate vertically
           dot.size = 2,                                 # Large dot size
           label = round(df$count),                        # Add mpg values as dot labels
           font.label = list(color = "white", size = 2,
                             vjust = 0.5),               # Adjust label parameters
           ggtheme = theme_void()) +                       # ggplot2 theme
    theme_transparent() + theme(legend.position = "none") -> p

sticker(p, package="UCSCXenaTools", p_size=4.5, s_x=0.9, s_y=1, s_width=1.7, s_height=1.3,
        p_x = 1.1, p_y = 0.9,
        url = "https://cran.r-project.org/package=UCSCXenaTools", u_color = "white", u_size = 1,
        h_fill="black", h_color="grey",
        filename="man/figures/logo.png")
