# Predicting Useful Restaurant Reviews by Subtopics Using Yelp Data
# A Big Data Analytics Project
# Regression and Textual Prediction
# by Jingchi Wang and Yu-Hua Cheng
# Loading packages
library(rjson)
# 2 Prediction
library(topicmodels)
library(tm)
library(slam)

yelp = read.csv("yelp.csv")

train_id = as.character(read.table("/Users/Tony/Documents/bigdata/training_id.txt")$V1)
test_id = as.character(read.table("/Users/Tony/Documents/bigdata/test_id.txt")$V1)

yelp$review_length = sapply(gregexpr("\\W+", yelp$review_text), length) + 1
yelp$user_seni = (2014-as.numeric(substring(yelp$user_since,1,4)))*12 + (12-as.numeric(substring(yelp$user_since,6,7)))
yelp$rest_categories = as.factor(yelp$rest_categories)
yelp$biuseful = yelp$review_useful!=0
names(yelp)[10] = "review_stars"
names(yelp)[16] = "rest_stars"

y1 = yelp[yelp$review_id %in% train_id,]
y2 = yelp[yelp$review_id %in% test_id,]
yp = rbind(y1,y2)


# 2.1 Non-text Prediction
# 2.1.1 Classic Regression (OLS)
ols.fit = lm(review_useful~review_stars+rest_reviewcount+rest_stars+user_usefulvotes+user_reviewcount+user_fans+user_avgstars+review_length+user_seni,
             data = yp,subset=(1:62647))
summary(ols.fit)

# OLS Evaluation
ols.votes = predict(ols.fit,yp[62648:80000,])
ols.pred = rep(0,17353)
ols.pred[ols.votes>=1]=1

ols.precision <- sum(ols.pred & yp$biuseful[62648:80000]) / sum(ols.pred)
ols.recall <- sum(ols.pred & yp$biuseful[62648:80000]) / sum(yp$biuseful[62648:80000])
ols.Fmeasure <- 2 * ols.precision * ols.recall / (ols.precision + ols.recall)

# 2.1.2 Logit Regression
glm.fit = glm(biuseful~review_stars+rest_reviewcount+rest_stars+user_usefulvotes+user_reviewcount+user_fans+user_avgstars+review_length+user_seni,
              data = yp,family=binomial,subset=(1:62647))
summary(glm.fit)

# Logit Evaluation
glm.probs = predict(glm.fit,yp[62648:80000,],type="response")
glm.pred = rep(0,17353)
glm.pred[glm.probs>.5]=1

glm.precision <- sum(glm.pred & yp$biuseful[62648:80000]) / sum(glm.pred)
glm.recall <- sum(glm.pred & yp$biuseful[62648:80000]) / sum(yp$biuseful[62648:80000])
glm.Fmeasure <- 2 * glm.precision * glm.recall / (glm.precision + glm.recall)


# 2.2 Textual Classification
library(RTextTools)
# 2.2.1 Building Document Term Matrix
doc_matrix <- create_matrix(yp$review_text, language="english", maxWordLength=20,
                            removeNumbers=TRUE,removeSparseTerms=0.6)
container <- create_container(doc_matrix, yp$biuseful, trainSize=1:62647, testSize=62648:80000, virgin=FALSE)

# 2.2.2 Training Model
SVM <- train_model(container,"SVM")
MAXENT <- train_model(container,"MAXENT")
GLMNET <- train_model(container,"GLMNET")
SLDA <- train_model(container,"SLDA")
BOOSTING <- train_model(container,"BOOSTING")
BAGGING <- train_model(container,"BAGGING")
RF <- train_model(container,"RF")
TREE <- train_model(container,"TREE")

# 2.2.3 Classifying
SVM_CLASSIFY <- classify_model(container, SVM)
MAXENT_CLASSIFY <- classify_model(container, MAXENT)
GLMNET_CLASSIFY <- classify_model(container, GLMNET)
SLDA_CLASSIFY <- classify_model(container, SLDA)
BOOSTING_CLASSIFY <- classify_model(container, BOOSTING)
BAGGING_CLASSIFY <- classify_model(container, BAGGING)
RF_CLASSIFY <- classify_model(container, RF)
TREE_CLASSIFY <- classify_model(container, TREE)

# 2.2.4 Evaluation Textual Predictions
svm.retrieved <- sum(as.logical(SVM_CLASSIFY[,1]))
svm.precision <- sum(as.logical(SVM_CLASSIFY[,1]) & yp$biuseful[62648:80000]) / svm.retrieved
svm.recall <- sum(as.logical(SVM_CLASSIFY$SVM_LABEL) & yp$biuseful[62648:80000]) / sum(yp$biuseful[62648:80000])
svm.Fmeasure <- 2 * svm.precision * svm.recall / (svm.precision + svm.recall)

bag.retrieved <- sum(as.logical(BAGGING_CLASSIFY[,1]))
bag.precision <- sum(as.logical(BAGGING_CLASSIFY[,1]) & yp$biuseful[62648:80000]) / bag.retrieved
bag.recall <- sum(as.logical(BAGGING_CLASSIFY[,1]) & yp$biuseful[62648:80000]) / sum(yp$biuseful[62648:80000])
bag.Fmeasure <- 2 * bag.precision * bag.recall / (bag.precision + bag.recall)

boost.retrieved <- sum(as.logical(BOOSTING_CLASSIFY[,1]))
boost.precision <- sum(as.logical(BOOSTING_CLASSIFY[,1]) & yp$biuseful[62648:80000]) / boost.retrieved
boost.recall <- sum(as.logical(BOOSTING_CLASSIFY[,1]) & yp$biuseful[62648:80000]) / sum(yp$biuseful[62648:80000])
boost.Fmeasure <- 2 * boost.precision * boost.recall / (boost.precision + boost.recall)

glmnet.retrieved <- sum(as.logical(GLMNET_CLASSIFY[,1]))
glmnet.precision <- sum(as.logical(GLMNET_CLASSIFY[,1]) & yp$biuseful[62648:80000]) / glmnet.retrieved
glmnet.recall <- sum(as.logical(GLMNET_CLASSIFY[,1]) & yp$biuseful[62648:80000]) / sum(yp$biuseful[62648:80000])
glmnet.Fmeasure <- 2 * glmnet.precision * glmnet.recall / (glmnet.precision + glmnet.recall)

maxent.retrieved <- sum(as.logical(MAXENT_CLASSIFY[,1]))
maxent.precision <- sum(as.logical(MAXENT_CLASSIFY[,1]) & yp$biuseful[62648:80000]) / maxent.retrieved
maxent.recall <- sum(as.logical(MAXENT_CLASSIFY[,1]) & yp$biuseful[62648:80000]) / sum(yp$biuseful[62648:80000])
maxent.Fmeasure <- 2 * maxent.precision * maxent.recall / (maxent.precision + maxent.recall)

rf.retrieved <- sum(as.logical(RF_CLASSIFY[,1]))
rf.precision <- sum(as.logical(RF_CLASSIFY[,1]) & yp$biuseful[62648:80000]) / rf.retrieved
rf.recall <- sum(as.logical(RF_CLASSIFY[,1]) & yp$biuseful[62648:80000]) / sum(yp$biuseful[62648:80000])
rf.Fmeasure <- 2 * rf.precision * rf.recall / (rf.precision + rf.recall)

slda.retrieved <- sum(as.logical(SLDA_CLASSIFY[,1]))
slda.precision <- sum(as.logical(SLDA_CLASSIFY[,1]) & yp$biuseful[62648:80000]) / slda.retrieved
slda.recall <- sum(as.logical(SLDA_CLASSIFY[,1]) & yp$biuseful[62648:80000]) / sum(yp$biuseful[62648:80000])
slda.Fmeasure <- 2 * slda.precision * slda.recall / (slda.precision + slda.recall)

tree.retrieved <- sum(as.logical(TREE_CLASSIFY[,1]))
tree.precision <- sum(as.logical(TREE_CLASSIFY[,1]) & yp$biuseful[62648:80000]) / tree.retrieved
tree.recall <- sum(as.logical(TREE_CLASSIFY[,1]) & yp$biuseful[62648:80000]) / sum(yp$biuseful[62648:80000])
