## http://www.cookbook-r.com/Manipulating_data/Summarizing_data/
## Summarizes data.
## Gives count, mean, standard deviation, standard error of the mean, and confidence interval (default 95%).
##   data: a data frame.
##   measurevar: the name of a column that contains the variable to be summariezed
##   groupvars: a vector containing names of columns that contain grouping variables
##   na.rm: a boolean that indicates whether to ignore NA's
##   conf.interval: the percent range of the confidence interval (default is 95%)
summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=FALSE,
                      conf.interval=.95, .drop=TRUE) {
    library(plyr)

    # New version of length which can handle NA's: if na.rm==T, don't count them
    length2 <- function (x, na.rm=FALSE) {
        if (na.rm) sum(!is.na(x))
        else       length(x)
    }

    # This does the summary. For each group's data frame, return a vector with
    # N, mean, and sd
    datac <- ddply(data, groupvars, .drop=.drop,
      .fun = function(xx, col) {
        c(N    = length2(xx[[col]], na.rm=na.rm),
          mean = mean   (xx[[col]], na.rm=na.rm),
          sd   = sd     (xx[[col]], na.rm=na.rm)
        )
      },
      measurevar
    )

    # Rename the "mean" column
    datac <- rename(datac, c("mean" = measurevar))

    datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean

    # Confidence interval multiplier for standard error
    # Calculate t-statistic for confidence interval:
    # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
    ciMult <- qt(conf.interval/2 + .5, datac$N-1)
    datac$ci <- datac$se * ciMult

    return(datac)
}

data <- read.csv("data.csv")
data <- data[c("Benchmark","Language","Input","Time")]
data <- data[data$Time != "timeout" & data$Time != "err",]

data$Benchmark <- as.character(data$Benchmark)
data$Language <- as.character(data$Language)
data$Input <- as.character(data$Input)
data$Time <- as.numeric(levels(data$Time))[as.integer(data$Time)]

fib <- data[data$Benchmark == "fibonacci",]
pidigits <- data[data$Benchmark == "pidigits",]
nbody <- data[data$Benchmark == "nbody",]
matrixmult <- data[data$Benchmark == "matrixmult",]
shortestpaths <- data[data$Benchmark == "shortestpaths",]
strongupdate <- data[data$Benchmark == "strongupdate",]

summary <- summarySE(data, measurevar="Time", groupvars=c("Benchmark","Language","Input"), na.rm=TRUE)
write.csv(summary, "summary.csv", row.names=FALSE)

sink("summary.txt")
summary2 <- summary
summary2$Time <- round(summary2$Time,2)
print(summary2[c("Benchmark","Language","Input","Time")])
sink()
