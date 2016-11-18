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

### define similarity
# train=sub_feature[1:2000,]
# test=sub_feature[2001:2350,]
train=feature_final
test=feature_test

words=colnames(lyr)
train_lyr=lyr
#train_lyr=lyr[1:2000,]
#test_lyr=lyr[2001:2350,]
del <- names(lyr) %in% stop_words
words_table <- words[!del]

getCosine <- function(x,y) 
{
  this.cosine <- sum(x*y) / (sqrt(sum(x*x)) * sqrt(sum(y*y)))
  return(this.cosine)
}

data.similarity=matrix(NA,nrow=dim(train)[1],ncol=dim(test)[1])
# Lets fill in those empty spaces with cosine similarities between train ith and test jth
for(i in 1:nrow(train)) {
  for(j in 1:nrow(test)) {
    data.similarity[i,j]= getCosine(train[i,],test[j,])
  }
}

neighbor_index=t(apply(data.similarity, 2, function(x){return(order(x,decreasing = T)[1:10])}))

### find the topics in the neighbor indexes
for(test_song in 1:ncol(test)) # iterate through songs
{
  for(rank in neighbor_index[test_song,]) # iterate through nearest neighbors
  {
    index10=neighbor_index[song,] # the 10 nearest songs in the training set,10
    neighbor10_lyr=train_lyr[index10,] # the word count of 10 nearest songs,10*4974
    similarity10=data.similarity[index10,song] # the similarity between song and 10 nearest neigobors,10
    weighted_lyr=t(as.matrix(neighbor10_lyr))%*%as.matrix(similarity10)
    recommend=words[order(weighted_lyr,decreasing = T)]
  }
}

j=1
most_frequent2=rep(0,length(fit2$assignment))
topic_test=list()
for(i in 1:length(neighbor_index)) #
{
  topic_test[[i]]=unlist(topic_list[neighbor_index[i,]])
}

topic_test_unique=lapply(topic_test,unique)
save(topic_test_unique,file="topic_test_unique.RData")
load("topic_test_unique.RData")
### in word_topic,the row is topic, column is word, value is the distribution of that topic
prob=matrix(0,nrow=nrow(feature_test),ncol(word_topic))
for(i in 1:length(topic_test_unique))
{
  #print(i)
  prob[i,]=prob[i,]+colSums(word_topic[unlist(topic_test_unique[i]),])
}
prob_order=t(apply(prob,1,function(x){return(order(x,decreasing=T))}))
prob_order=data.frame(prob_order)
colnames(prob_order)=colnames(word_topic)
load("lyr.RData") # lyric count of 2350 songs
lyr[,2:ncol(lyr)]=NA
final=lyr[1:100,]
final[,match(colnames(prob_order),colnames(lyr))]=prob_order
write.csv(file="final_result.csv",final)
