### ads proj 4
library(data.table)
library(dplyr)
# source("http://bioconductor.org/biocLite.R")
# biocLite("rhdf5")
library(rhdf5)
library(pbapply)
library("recommenderlab")
library("TeachingSampling")
library(randomForest)
library(NLP)
library(tm)
library(lda)
library(LDAvis)
dir="G:/Columbia/study/3rd semester/5243/project4/Project4_data"
setwd(dir)

load("lyr.RData") # lyric count of 2350 songs
lyr=lyr[,-c(2,3,6:30)]
lyr=lyr[,-1]
stop_words <- stopwords(kind="en")

load("feature_final.RData")

## read the training data
dir.h5 <- 'G:/Columbia/study/3rd semester/5243/project4/Project4_data/data/data/'

files.list <- as.matrix(list.files(dir.h5, recursive = TRUE))
feature_per_photo=function(i){
  x=paste0(dir.h5,files.list[i])
  sound<-h5read(x,"/analysis")
  loudness_max=rep_len(sound$segments_loudness_max,length.out=2000)
  loudness_max_time=rep_len(sound$segments_loudness_max_time,length.out=2000)
  pitches=sound$segments_pitches
  timbre=rep_len(sound$segments_timbre,length.out=2000)
  
  # systematic sampling
  sample=S.SY(length(loudness_max),10)
  sample_loudness=loudness_max[sample]
  sample_loudness_time=loudness_max_time[sample]
  sample_timbre=timbre[sample]
  # Every 200 long data is a variable
  feature_sample=c(sample_loudness,sample_loudness_time,sample_timbre)
  for(j in 1:12)
  {
    test=pitches[j,]
    test2=rep_len(test,length.out=2000)[sample]
    feature_sample=c(feature_sample,test2)
  }
  ## descriptive data
  descriptive=function(x)
  {
    min=min(x)
    max=max(x)
    mean=mean(x)
    sd=sd(x)
    return(c(min,max,mean,sd))
  }
  pitches_summary=apply(pitches,1,descriptive)
  feature_sample_final=c(feature_sample,descriptive(loudness_max),descriptive(loudness_max_time),
                   descriptive(timbre),as.vector(pitches_summary))
  return(feature_sample_final)
  }


feature_final=feature_per_photo(1)
for(i in 2:length(files.list))
{
  feature_final=rbind(feature_final,feature_per_photo(i))
}

#setwd(dir)
#save(feature_final,file="feature_final.RData")


# ###PCA on features
# pca1=prcomp(feature_final)
# var_pca1 <- (pca1$sdev)^2
# prop_varex <- var_pca1/sum(var_pca1)
# 
# plot(cumsum(prop_varex), xlab = "Principal Component",
#      ylab = "Cumulative Proportion of Variance Explained",
#      type = "b")
# sub_feature=pca1$x[,1:200]
