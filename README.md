Predicting Useful Restaurant Reviews by Subtopics Using Yelp Data
=================================================================
Columbia University
===
Yu Hua Cheng (yc2911@columbia.edu)

Jingchi Wang (jingchiw@gmail.com)
===

Code Description:

1. DataPreprocessing.R -- Given the json-format input of the Yelp Challenge dataset downloaded from
   "http://www.yelp.com/dataset_challenge", it will generate the dataframe of the restaurant reviews,
   called "yelp.csv"

2. ExtractReviewsOutputTxt.py -- Given the input of "yelp.csv" and an assigned restaurant category 
   (American, Chinese, etc.), it will extract the nouns from each review and store it in a txt file;
   the whole txt files will be stored in an automatically created folder with a name of its category.

3. LDAmahout.txt -- Given the folder of nouns-only reviews in txt format that is generated from 2.,
   it will run LDA using Mahout in the command line.

4. Regression-and-Textual-Prediction.R -- Using "yelp.csv" generated from 1., it will implement several
   prediction models for reviews' usefulness.
   

   
  
