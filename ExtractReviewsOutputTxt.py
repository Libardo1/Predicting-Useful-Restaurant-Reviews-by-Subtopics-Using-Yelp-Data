#This script is to output each review into a txt file with Nouns only, given the desired restaurant category.
#The nouns-only reviews in txt format are the inputs for running LDA in Mahout
#The output files will be in an automatically created folder named by its category

import pandas as pd
import os
import random
from itertools import chain
import cPickle as pickle

#set path to where the yelp.csv is located in
path = "C:\Users\yu\Documents\BigData"
os.chdir(path)

yelp = pd.read_csv("yelp.csv")
reviews = yelp["review_text"]

#Random sampling, to save time to find out the category collection
rows = random.sample(yelp.index, 70000)
yelp_rand = yelp.ix[rows]


#Checking the restaurant categories in Yelp dataset
'''
from collections import Counter
category_temp = [cate.split(",") for cate in yelp_rand["categories"].values]
category_collection = list(chain(*category_temp))
category_count = Counter(category_collection)
pickle.dump(category_count, open("category_count.p", "wb"))

category_count = pickle.load(open("category_count.p", "rb"))
category_count.most_common()[:30]
'''

#Set your desired category
cate = "Nightlife"

cate_idx = [cate in ele for ele in yelp_rand["rest_categories"]]
yelp_cate = yelp_rand[cate_idx]

#Covert the category Reviews into the ones only containing the nouns
from textblob import TextBlob
total_number_reviews = len(yelp_cate)
output_folder = "reviews_" + cate
os.mkdir(output_folder)

fail_idx = []
for idx, file in enumerate(yelp_cate["review_text"].values):
	try:
		file_textblob_tags = TextBlob(file).tags
		#Take nouns and also require the length of this noun is larger than 2, number of words > 5
		noun = [tag[0].encode() for tag in file_textblob_tags if ('NN' in tag[1]) & (len(tag[0])> 2 )]
		if len(noun) > 5:
			for word in noun:
				with open(os.path.join(path,output_folder) + "\\noun" + ("%0" + str(len(str(total_number_reviews))) + "d") % idx + ".txt" , "a") as f:
					f.write("%s\n" % word)
		else:
			pass
		if (idx%1000 == 0):#Check the progress
			print str(round(float(idx)/total_number_reviews,2)) + "%"
	except:
		#Pass the reviews which have undecodable words
		fail_idx.append(idx)
		pass






