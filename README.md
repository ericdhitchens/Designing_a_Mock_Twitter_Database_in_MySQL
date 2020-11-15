# Designing a Mock Twitter Database in MySQL

## The Challenge

How would you design a mock database in MySQL that stores Twitter data? And how could you generate random data to populate that database? These are the questions I explore in this portfolio project.


## Basic Database Features

Twitter is a social media platform that allows users to post their thoughts as tweets of 280 or fewer characters and interact with each other tweets via likes, follows, comments, hashtags, and retweets. Therefore, we need to have tables in MySQL that store this data:

* users
* followers
* tweets
* likes
* comments
* hashtags

For reasons explained in the following sections, I expand these six entities into nine relational tables. The enhanced entity relationship (EER) diagram in this repository presents the relational schemas. I will generate the random data using Python.


## The Relational Schemas
The following sections explain the general concepts, clarifications, assumptions, and limitations of each of the tables included in this MySQL database design.


### The users table
* User Login/Security: Storing user login information would not usually occur in such a table. Encryption of login and other personally identifiable information is outside the scope of this exercise.
* user_handle: This is the Twitter handle associated with each account.
* phone_numberr: I assume that the users are from the United States with a standard 10 digit phone number. I used the CHAR(10) data type to validate the data.
* NOT NULL Constraints: I assume that users will sign up with an email address, with the phone number and sex remaining optional.
* birthday: I assume that the data will be entered into the database in the form YYYY-MM-DD.


### The followers table
We read the first two columns as “user with users.user_id equal to followers.follower_id is following the user with users.user_id equal to followers.following_id.” 

The follower_id and following_id are primary keys for the table and are foreign keys pointing to the users table. This ensures that a user can only follow another user once, i.e. there must be unique entries in this table.


### The tweets table

The table assumes that the number of likes, comments, and retweets on each tweet will be updated either through database triggers or from other automation on the client or back end software. They are merely listed here for the convenience of anyone accessing the database and could be omitted and derived with SELECT statements instead if desired. A discussion of the database triggers is included in its own section below.

The clear limitation of this table is that it does not allow for retweets. This is because when a user retweets a tweet on Twitter, the tweet appears on the user’s profile with the same appearance and engagement statistics as the original poster’s (OP). 

We could include retweets with a self-referencing op_tweet_id feature in this table, but that can be normalized by creating a separate retweets table. This way, the retweets will not be easily confused with the OP tweets and are more reflective of the actual Twitter user experience. For reasons listed below, the next table that must be created prior to the retweets table is the comments table.


### The comments table

Let us define a level 1 (L1) comment to be a comment directly on the original poster’s tweet (op_tweet_id). Then all level 1 comments will have NULL as their parent_comment_id. 

A level 2 (L2) comment is then a comment of an L1 comment. An L2 comment would be entered into the database with a parent_comment_id equal to the comment_id of the L1 comment to which it belongs. 

Continuing this, an L3 comment’s parent_comment_id is equal to the comment_id of the L2 comment to which it belongs, and so on and so forth. However, all comments on the same tweet, regardless of their level, will list the same op_tweet_id.

Since a comment can be both commented on and retweeted infinitely many times, we could have infinitely many branches of sub-comments that could result in their own schemas. For the sake of simplicity in the scope of this exercise, I have chosen to log all of the comments into this single table. 


### The retweets table

We do not have the infinite sub-comments problem with retweets. This is because retweeted tweets simply appear as the OP’s tweet. The challenge does arise, however, when a user retweets a comment or provides a comment on a retweet. This is why the op_tweet_id and comment_id foreign keys are included in this table. 

In the database, the retweet is be saved as an instance of a retweet, with the actual text of the comment saved as a comment under op_tweet_id. There is also the possibility that the user is retweeting a comment or sub-comment of an original post. If the “retweet with comment” option is selected for a retweet of a sub-comment, the parent_comment_id will be shown in the comments table.


### The hashtags_list and hashtag_instances Tables

There are multiple ways of creating a hashtag system. We could run code on the tweet text that splits the text of the tweets on the hashtag symbol, but that would assume that anything with the pound symbol is a hashtag. Another option could involve running a function in a separate language that analyzes the text of the tweet through string methods or natural language processing techniques.

For a simple case, I have chosen to separate the hashtags into a hashtag_list table and instances of the hashtags being used in the hashtag_instances table. This allows for the flexibility of being able to use hashtags both in tweets and comments, as well.


### The tweet_likes and comment_likes tables

There are multiple ways to tackle the challenge of adding a “like” feature. One could store this data directly into the num_likes columns of the respective tweets and comments, but this would not allow for tracking the instances of the likes and storing them somewhere for later analysis. That is ultimately why I chose this form.


### Database Triggers

There are multiple ways we could track the number of likes, comments, and retweets for a given tweet, retweet, or comment. For this design, I have chosen to define triggers that perform the following:

* Adds 1 to the num_likes column of the tweets table whenever there is a new entry on the tweet_likes table, where the tweet IDs match.
* Adds 1 to the num_likes column of the comments table whenever there is a new entry on the comment_likes table, where the comment IDs match.
* Adds 1 to the num_comments column of the tweets table whenever there is a new entry on the comments table, where the tweet IDs match.
* Adds 1 to the num_retweets column of the tweets table whenever there is a new entry on the retweets table, where the original tweet IDs match.

Unfortunately, MySQL does not allow for triggers to self-update tables; that is, you cannot create a trigger for each entry on the comments table to update the comments table. Therefore, to track the number of comments on a comment would require a subcomments table, etc. These issues can be resolved by manually inputting the number of comments or somehow automating this information via other code/software.


## Generating Fake Data with Python

The general approach to generating the random data is to define classes that represent each table in the database, then instantiate lists of objects of those classes that are initialized with random parameters meeting the data criteria established in the SQL code. The random data rely on the Faker and Numpy libraries. 

I then format all of the lists using tuples and convert them into strings so that they can be in the correcct format for INSERT INTO statements in MySQL. All of the files are downloaded as .txt files for future reference, since each time the .py file is run, it will generat new, random data. If you don't care about storing the data in text files, you could directly connect to your MySQL database using pymysql and not save the txt files at all. For more detailed explanations of all steps involved in the Python code, please see the comments in the Python files.


## Exploratory Data Analysis & Visualization

The general approach to generating the random data is to define classes that represent each table in the database, then instantiate lists of objects of those classes that are initialized with random parameters meeting the data criteria established in the SQL code. The random data rely on the Faker and Numpy libraries. 

I then format all of the lists using tuples and convert them into strings so that they can be in the correcct format for INSERT INTO statements in MySQL. All of the files are downloaded as .txt files for future reference, since each time the .py file is run, it will generat new, random data. If you don't care about storing the data in text files, you could directly connect to your MySQL database using pymysql and not save the txt files at all. For more detailed explanations of all steps involved in the Python code, please see the comments in the Python files.


## Database Design, Analysis, & Conclusions

While the design presented in this repository provides a solid basic foundation, its clear limitation is scalability. The major flaw is the self-referencing design of the comments and retweets tables. If left in this state, there could potentially be tens of thousands of tweets, comments, likes, etc. from a single user in a single year. Conversations in the comments of a single tweet could run into thousands of levels of sub-comments. This design also does not take into account the storage of multimedia files (music, audio, images, video, etc.).

Twitter’s storage architecture used to be almost entirely based on MySQL. However, as they discovered, a better solution for handling data of this size at scale is to use a different technology specifically geared for big data. This is exactly the technology that Twitter helped to pioneer with the launch of Gizzard, FlockDB, and Snowflake in 2010, and Manhattan in 2014 (1).  By 2017, over 70% of its storage systems were based on distributed networks like Hadoop and Manhattan (2), and in recent years, Twitter has been increasing its use of Google’s cloud computing and storage services for these purposes (3).

In conclusion, while this design in MySQL is a good educational exercise, its implementation at scale would be better handled by distributed, cloud-based systems like Hadoop and Manhattan.

### References:
1. https://blog.twitter.com/engineering/en_us/topics/infrastructure/2017/the-infrastructure-behind-twitter-scale.html
2. https://blog.twitter.com/engineering/en_us/topics/infrastructure/2017/the-infrastructure-behind-twitter-scale.html
3. https://blog.twitter.com/engineering/en_us/topics/infrastructure/2019/expand-the-edge.html

