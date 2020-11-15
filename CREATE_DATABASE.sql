/*
DESIGNING A MOCK TWITTER DATABASE
Author: Eric Hitchens
Date of Original Creation: 11/02/2020
*/

/* STEP 1: CREATE & USE THE NEW DATABASE */

DROP DATABASE IF EXISTS mock_twitter_db;

CREATE DATABASE mock_twitter_db;

USE mock_twitter_db;


/* STEP 2: CREATE ALL TABLES PER THE EER DIAGRAM */

CREATE TABLE users (
	user_id INT NOT NULL AUTO_INCREMENT
	,user_handle VARCHAR(100) NOT NULL
	,first_name VARCHAR(50) NOT NULL
	,last_name VARCHAR(50) NOT NULL
	,email_address VARCHAR(45) NOT NULL
	,phone_number CHAR(10)
	,birthday DATE NOT NULL
	,created_at TIMESTAMP NOT NULL DEFAULT (NOW())
,PRIMARY KEY(user_id)
);

CREATE TABLE followers (
	follower_id INT NOT NULL
	,following_id INT NOT NULL
,FOREIGN KEY (follower_id) REFERENCES users(user_id)
,FOREIGN KEY (following_id) REFERENCES users(user_id)
,PRIMARY KEY (follower_id,following_id)
);

CREATE TABLE tweets(
	tweet_id INT NOT NULL AUTO_INCREMENT
	,user_id INT NOT NULL
	,tweet_text VARCHAR(280) NOT NULL
	,num_comments INT DEFAULT 0
	,num_likes INT DEFAULT 0
	,num_retweets INT DEFAULT 0
	,created_at TIMESTAMP NOT NULL DEFAULT (NOW())
,FOREIGN KEY (user_id) REFERENCES users(user_id)
,PRIMARY KEY (tweet_id)
);


CREATE TABLE comments(
	comment_id INT NOT NULL AUTO_INCREMENT
	,parent_comment_id INT -- applies only if the comment is a subcomment
	,op_tweet_id INT NOT NULL -- op stands for "original post"
	,commenter_id INT NOT NULL
	,comment_text VARCHAR(280) NOT NULL
	,num_likes INT DEFAULT 0
	,created_at TIMESTAMP NOT NULL DEFAULT (NOW())
,FOREIGN KEY (commenter_id) REFERENCES users(user_id)
,FOREIGN KEY (op_tweet_id) REFERENCES tweets(tweet_id)
,FOREIGN KEY (parent_comment_id) REFERENCES comments(comment_id)
,PRIMARY KEY (comment_id)
);


CREATE TABLE retweets(
	retweet_id INT NOT NULL AUTO_INCREMENT
	,op_tweet_id INT NOT NULL
	,comment_id INT
	,retweeter_id INT NOT NULL
	,created_at TIMESTAMP NOT NULL DEFAULT (NOW())
,FOREIGN KEY (op_tweet_id) REFERENCES tweets(tweet_id)
,FOREIGN KEY (comment_id) REFERENCES comments(comment_id)
,FOREIGN KEY (retweeter_id) REFERENCES users(user_id)
,PRIMARY KEY (retweet_id)
);


CREATE TABLE hashtag_list(
	hashtag_id INT NOT NULL AUTO_INCREMENT
	,hashtag_name VARCHAR(50) NOT NULL
	,created_at TIMESTAMP NOT NULL DEFAULT (NOW())
,PRIMARY KEY (hashtag_id)
,UNIQUE (hashtag_name)
);

CREATE TABLE hashtag_instances(
	hashtag_id INT NOT NULL
	,tweet_id INT NOT NULL
	,created_at TIMESTAMP NOT NULL DEFAULT (NOW())
,FOREIGN KEY (hashtag_id) REFERENCES hashtag_list(hashtag_id)
,FOREIGN KEY (tweet_id) REFERENCES tweets(tweet_id)
);

CREATE TABLE tweet_likes(
	user_id INT NOT NULL
	,tweet_id INT NOT NULL
	,created_at TIMESTAMP NOT NULL DEFAULT (NOW())
,FOREIGN KEY (user_id) REFERENCES users(user_id)
,FOREIGN KEY (tweet_id) REFERENCES tweets(tweet_id)
,PRIMARY KEY (user_id, tweet_id)
);

CREATE TABLE comment_likes(
	comment_id INT NOT NULL
	,commenter_id INT NOT NULL
	,created_at TIMESTAMP NOT NULL DEFAULT (NOW())
,FOREIGN KEY (comment_id) REFERENCES comments(comment_id)
,FOREIGN KEY (commenter_id) REFERENCES users(user_id)
,PRIMARY KEY (comment_id,commenter_id)
);



/* CREATE THE UPDATE TRIGGERS FOR THE tweets AND comments TABLE */

DROP TRIGGER IF EXISTS add_tweet_like;
DELIMITER $$
CREATE TRIGGER add_tweet_like
	AFTER INSERT ON tweet_likes 
	FOR EACH ROW
    BEGIN
		UPDATE tweets
        SET num_likes = num_likes + 1
        WHERE tweet_id = NEW.tweet_id;
	END $$
DELIMITER ;


DROP TRIGGER IF EXISTS add_comment_like;
DELIMITER $$
CREATE TRIGGER add_comment_like
	AFTER INSERT ON comment_likes FOR EACH ROW
    BEGIN
		UPDATE comments
        SET num_likes = num_likes + 1
        WHERE comment_id = NEW.comment_id;
	END $$
DELIMITER ;

DROP TRIGGER IF EXISTS add_comment_to_tweet;
DELIMITER $$
CREATE TRIGGER add_comment_counters
	AFTER INSERT ON comments FOR EACH ROW
    BEGIN
		UPDATE tweets SET num_comments = num_comments + 1 WHERE tweet_id = NEW.op_tweet_id;
	END $$
DELIMITER ;


DROP TRIGGER IF EXISTS add_retweet_count;
DELIMITER $$
CREATE TRIGGER add_retweet_count
	AFTER INSERT ON retweets FOR EACH ROW
    BEGIN
		UPDATE tweets SET num_retweets = num_retweets + 1 WHERE tweet_id = NEW.op_tweet_id;
	END $$
DELIMITER ;