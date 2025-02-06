-- string
SET mykey "Hello"
GET mykey

-- hash
-- key field
keys *
keys user:*

hget movie:719 title

exists movie:3

HSET myhash field1 "value1"

HDEL myhash field1

-- list
LPUSH mylist "item1"
RPUSH mylist "item2"
LRANGE mylist 0 -1

-- set
SADD myset "element1"
SADD myset "element2"
SMEMBERS myset

-- sorted set
ZADD leaderboard 100 "player1"
ZADD leaderboard 150 "player2"
ZRANGE leaderboard 0 -1 WITHSCORES

-- bitmaps
SETBIT user:1234:login 0 1
GETBIT user:1234:login 0







