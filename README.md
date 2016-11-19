# Project: Words 4 Music

### [Project Description](doc/Project4_desc.md)

![image](http://cdn.newsapi.com.au/image/v1/f7131c018870330120dbe4b73bb7695c?width=650)

Term: Fall 2016

+ [Data link](https://courseworks2.columbia.edu/courses/11849/files/folder/Project_Files?preview=763391)-(**courseworks login required**)
+ [Data description](doc/readme.html)
+ Contributor's name: Yiwei Sun
+ Projec title: Lorem ipsum dolor sit amet
+ Project summary: The project is about recommending lyrics to new songs using song features. There are several steps I did.
*  extract features: I used loudness_max, loudness_max_time, pitches and timbre from the original data set. I first rep the segments to 2000, then did systematic sampling to extract 200 ones from 2000 for every feature. Then I added the mean, min, max, standard deviation to the feature. The R file feature_extracting2.0.R is used to extract feature from training data, while read_test_data.R is used for testing data.
* topic modling: Used Topic Modeling to divide the words into 20 topics. Find the topics that each song contains.Calculate the distribution of words in each topic.
*  define distance: I define cos distance. Then calculate the distance between the feature of test songs and feature of train songs. Pick the 10 most similar ones, add the distribution of each topic to a new distribution(may not sum to 1 not that's fine), then rank the words according to the possibilities of words.
* write a csv file with the ranks.

I also tried several ways like randomforest, svm, and decide that the method I use now would best predict.
Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── lib/
├── data/
├── doc/
├── figs/
└── output/
```

Please see each subfolder for a README file.
