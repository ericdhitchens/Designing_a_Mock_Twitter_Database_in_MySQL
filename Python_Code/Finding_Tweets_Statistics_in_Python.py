# ## Statistical Analysis in Python

# ### Import the relevant libraries

import numpy as np
import pandas as pd


# ### Import the data file

tweets = pd.read_csv('tweets.csv')

tweets.drop('tweet_id', axis=1,inplace=True)


# Get statistics:
tweets.describe()

