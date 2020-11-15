-- -- Top 10 users with most tweets
SELECT users.user_id, users.user_handle, users.first_name, users.last_name, COUNT(*) AS num_of_tweets
FROM users
JOIN tweets
	ON users.user_id = tweets.user_id
GROUP BY users.user_id
ORDER BY COUNT(*) DESC
LIMIT 10;

-- -- Top 10 tweets with most likes, with user first and last name
SELECT tweets.tweet_id, tweets.num_likes, users.first_name, users.last_name
FROM tweets
JOIN users
	ON tweets.user_id = users.user_id
ORDER BY tweets.num_likes DESC
LIMIT 10;

-- -- Tweets with the most comments, with user first and last name
SELECT tweets.tweet_id, tweets.num_comments, users.first_name, users.last_name
FROM tweets
JOIN users
	ON tweets.user_id = users.user_id
ORDER BY tweets.num_comments DESC
LIMIT 10;

-- Top 10 users with the most followers
SELECT users.user_id, users.user_handle, users.first_name, users.last_name, COUNT(*) AS num_of_followers
FROM users
JOIN followers
	ON users.user_id = followers.following_id
GROUP BY users.user_id
ORDER BY COUNT(*) DESC
LIMIT 10;

-- Top 10 most retweeted tweets
SELECT tweets.tweet_id, tweets.num_retweets, users.first_name, users.last_name
FROM tweets
JOIN users
	ON tweets.user_id = users.user_id
ORDER BY tweets.num_retweets DESC
LIMIT 10;