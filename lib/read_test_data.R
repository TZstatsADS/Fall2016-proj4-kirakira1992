###read test data
dir.h5 <- 'G:/Columbia/study/3rd semester/5243/project4/Project4_data/TestSongFile100/TestSongFile100/'
files.list <- as.matrix(list.files(dir.h5, recursive = TRUE))
file_name=apply(files.list,1,function(x){return(substr(unlist(strsplit(x,"h"))[1], 1, nchar(unlist(strsplit(x,"h"))[1])-1))})
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

feature_test=feature_per_photo(1)
for(i in 2:length(files.list))
{
  feature_test=rbind(feature_test,feature_per_photo(i))
}
save(feature_test,file="feature_test.RData")
load("feature_test.RData")
