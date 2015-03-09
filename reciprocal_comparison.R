library(ggplot2)
library(gridExtra)

recipcomparison <- function(DF, blast1, blast2, variable) {

    scatt<-ggplot(DF, aes(x=V2, y=V3, colour=as.factor(V4)) ) + 
               geom_point(alpha = 0.3) + 
               xlab(paste(variable, blast1, sep=" ")) +
               ylab(paste(variable, blast2, sep=" ")) +
               theme_bw()  + 
               theme(legend.position = "none")
    
    cp<-ggplot(DF, aes(x=V2)) + 
            geom_density() + 
            xlab(paste(variable, blast1, sep=" ")) +
            theme_bw() 
    
    pc<-ggplot(DF, aes(x=V3) ) + 
            geom_density() + 
            xlab(paste(variable, blast2, sep=" ")) +
            theme_bw() + 
            coord_flip() 

    junk<-ggplot(mtcars, aes(x = wt, y = mpg)) + 
            ggtitle("Best hits\nreciprocal Blasts") + 
            geom_blank() + 
            theme_bw() + 
            theme(panel.border     = element_blank(), 
                  panel.grid.major = element_blank(), 
                  panel.grid.minor = element_blank(), 
                  line             = element_blank(), 
                  axis.text.x      = element_blank(), 
                  axis.text.y      = element_blank(), 
                  plot.title       = element_text(face       = "bold", 
                                                  lineheight = 2, 
                                                  vjust      = 1, 
                                                  hjust      =.5, 
                                                  size       = 18, 
                                                  family     = "Ubuntu Mono"
                                                  ), 
                  plot.margin = unit(c(5, 1, 0.5, 0.5), "lines")
                  ) + 
            xlab("") + 
            ylab("")
    grid.arrange(cp, junk, scatt, pc, ncol=2)
    gplots <- arrangeGrob(cp, junk, scatt, pc, ncol=2)
    return(gplots)
}


