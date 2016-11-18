#####################
#####topic models####
#####################
library(NLP)
library(tm)
library(lda)
library(LDAvis)
library(e1071)
stop_words <- stopwords("en")
dir="G:/Columbia/study/3rd semester/5243/project4/Project4_data"
setwd(dir)
load("lyr.RData") # lyric count of 2350 songs
load("lda_model.RData")
load("documents.RData")
lyr<-lyr[,-c(2,3,6:30)]
del <- names(lyr) %in% stop_words
lyr <- lyr[!del]
lyr =lyr[,-1]
vocab <- names(lyr) 

#method1
get.terms <- function(x) {
  index <- match(x, vocab)
  c=x
  index=which(c!=0)
  c_not0=c[which(c!=0)]
  c_not0=as.matrix(rbind(as.integer(index-1),as.integer(c_not0)))
  return(c_not0)
}

documents<-list()
for(i in 1:nrow(lyr))
{
  documents[[i]]=get.terms(lyr[i,])
}

save(documents,file="documents.RData")
# Compute some statistics related to the data set:
D <- length(documents) # number of documents (2,000)
W <- dim(lyr)[2]  # number of terms in the vocab (14,568)
doc.length <- sapply(documents, function(x) sum(x[2, ]))  # number of tokens per document [312, 288, 170, 436, 291, ...]
#N <- sum(doc.length)  # total number of tokens in the data (546,827)
#term.frequency <- as.integer(term.table)  # frequencies of terms in the corpus [8939, 5544, 2411, 2410, 2143, 


# MCMC and model tuning parameters:
K <- 20
G <- 5000
alpha <- 0.02
eta <- 0.02

library(lda)
library(topicmodels)
set.seed(7)
t1 <- Sys.time()
fit2 <- lda.collapsed.gibbs.sampler(documents = documents, K = K, vocab = colnames(lyr), 
                                   num.iterations = G, alpha = alpha, 
                                   eta = eta, initial = NULL, burnin = 0,
                                   compute.log.likelihood = TRUE)
t2 <- Sys.time()
t2 - t1  # about 10 minutes on laptop

save(fit,file="lda_model.RData")
save(fit2,file="lda_model2.RData")

topic_list=lapply(fit$assignment,function(x){return(unique(x))})
### find the most frequent topic most_frequent
j=1
most_frequent2=rep(0,length(fit2$assignment))
for(i in fit2$assignment)
{
  most_frequent2[j]=names(which.max(table(i)))
  j=j+1
}
save(most_frequent2,file="most_frequent2.RData")
load("most_frequent2.RData")
# svm.model <- svm(x=feature_final,y = factor(most_frequent),cost = 100, gamma = 1)
# svm.pred <- predict(svm.model, newdata=feature_final[2001:2350,])
# save(svm.model,file="svm.model.RData")
# table(factor(most_frequent[1:2000]),svm.pred)
### rf is the randomforest model we fit from feature to topic
rf2=randomForest(x=feature_final,y = factor(most_frequent2))
save(rf2,file="rf2.RData")
pred=predict(rf2,feature_test)
theta <- t(apply(fit$document_sums + alpha, 2, function(x) x/sum(x)))# the probability of every word in every topic
# library(nnet)
load("theta.RData")
save(file="theta.RData",theta)
#multi_fit=lm(theta ~ feature_final)
#pred=predict(multi_fit,data.frame(feature_test))
word_topic=t(apply(t(fit$topics) + eta, 2, function(x) x/sum(x)))#[,-1]
