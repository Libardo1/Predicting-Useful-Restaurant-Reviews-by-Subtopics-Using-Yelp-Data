# 1. Data Extraction and Prepocessing

# Loading packages
library(rjson)
library(topicmodels)
library(tm)
library(slam)

# 1.1 Business Dataset
jb = readLines("yelp_dataset_challenge_academic_dataset 2/yelp_academic_dataset_business.json")
bs = lapply(jb,fromJSON)
business_id=list()
categories=list()
city=list()
review_count=list()
name=list()
state=list()
stars=list()
for(i in 1:length(bs)){
  business_id[i] = bs[[i]]$business_id
  categories[i] = paste(c(bs[[i]]$categories),collapse=", ")
  city[i] = bs[[i]]$city
  review_count[i] = bs[[i]]$review_count
  name[i] = bs[[i]]$name
  state[i] = bs[[i]]$state
  stars[i] = bs[[i]]$stars
}
business = data.frame(business_id=unlist(business_id),name=unlist(name),categories=unlist(categories),
                      city=unlist(city),state=unlist(state),review_count=unlist(review_count),stars=unlist(stars),
                      stringsAsFactors=FALSE)
business = business[grepl("Restaurants",business$categories),]

# 1.2 Reviews Dataset
jr = readLines("yelp_dataset_challenge_academic_dataset 2/yelp_academic_dataset_review.json")
rv = lapply(jr,fromJSON)
funny=list()
useful=list()
cool=list()
user_id=list()
review_id=list()
stars=list()
date=list()
text=list()
type=list()
business_id=list()
for(i in 1120685:1125458){
  funny[i] = rv[[i]]$votes$funny
  useful[i] = rv[[i]]$votes$useful
  cool[i] = rv[[i]]$votes$cool
  user_id[i] = rv[[i]]$user_id
  review_id[i] = rv[[i]]$review_id
  stars[i] = rv[[i]]$stars 
  date[i] = rv[[i]]$date
  text[i] = rv[[i]]$text
  business_id[i] = rv[[i]]$business_id
}
review = data.frame(review_id=unlist(review_id),text=unlist(text),user_id=unlist(user_id),
                    date=unlist(date),funny=unlist(funny),useful=unlist(useful),
                    cool=unlist(cool),restars=unlist(stars),business_id=unlist(business_id),
                    stringsAsFactors=FALSE)
# Merging Business and Review
yelp = merge(review, business, by="business_id")
write.csv(yelp, "yelp.csv")

# 1.3 User Dataset
ju = readLines("yelp_dataset_challenge_academic_dataset 2/yelp_academic_dataset_user.json")
us = lapply(ju,fromJSON)
usersince=list()
userusefulvotes=list()
userreviewcount=list()
user_id=list()
userfans=list()
useravgstars=list()
usertype=list()
for(i in 1:length(us)){
  usersince[i] = us[[i]]$yelping_since
  userusefulvotes[i] = us[[i]]$votes$useful
  userreviewcount[i] = us[[i]]$review_count
  user_id[i] = us[[i]]$user_id
  userfans[i] = us[[i]]$fans
  useravgstars[i] = us[[i]]$average_stars
  usertype[i] = us[[i]]$type
}
user = data.frame(usersince=unlist(usersince),userusefulvotes=unlist(userusefulvotes),
                  userreviewcount=unlist(userreviewcount),user_id=unlist(user_id),
                  userfans=unlist(userfans),useravgstars=unlist(useravgstars),
                  stringsAsFactors=FALSE)

# Merging Business, Review and User
yelp = read.csv("/Users/Tony/Documents/bigdata/yelp.csv")
yelp = merge(yelp, user, by="user_id")
write.csv(yelp, "yelp.csv")