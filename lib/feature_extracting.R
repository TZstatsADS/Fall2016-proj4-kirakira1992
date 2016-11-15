### ads proj 4
library(data.table)
library(dplyr)
# source("http://bioconductor.org/biocLite.R")
# biocLite("rhdf5")
library(rhdf5)
library(pbapply)
library("recommenderlab")
dir="G:/Columbia/study/3rd semester/5243/project4/Project4_data"
dir2=paste0(dir,"/data/data")
setwd(dir)

load("lyr.RData") # lyric count of 2350 songs
sound<-h5read("G:/Columbia/study/3rd semester/5243/project4/Project4_data/data/data/A/A/A/TRAAABD128F429CF47.h5","/analysis")

dir.h5 <- 'G:/Columbia/study/3rd semester/5243/project4/Project4_data/data/data/'
files.list <- as.matrix(list.files(dir.h5, recursive = TRUE))
song.features.df <- get.features(files.list, dir.h5)

get.features <- function(files.list, directory){
  
  # counters to see progress
  num <- 0  
  total <- length(files.list)
  
  # Loop through all the data files, collect results as a list.
  features <- pblapply(files.list, function(x, dir){
    
    file <- paste0(dir,x)
    h5f <- h5dump(file, load = TRUE)
    analysis <- h5f$analysis
    tempo <- select(analysis,c(8,9,11,))
    song <- substr(x, start = 7, stop = nchar(x)-3)
    H5close()
    return(c(song,tempo))
  },
  dir = directory
  )
  # Transform list into a data frame
  song.features.df <- unlist(features) %>% 
    matrix(byrow = TRUE, ncol = 2) %>%
    data.frame()
  names(song.features.df) <- c('song', 'tempo')
  song.features.df$tempo <- as.double(song.features.df$tempo)
  song.features.df$song <- as.character(song.features.df$song)
  return(song.features.df)
}

### cluster to lyrics
lyr=lyr[,-c(2,3,6:30)]
cluster_lyr=kmeans(lyr[1:100,-1],centers=10)
