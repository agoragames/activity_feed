# Activity Feed

Activity feeds backed by MongoDB and Redis

## Compatibility

The gem has been built and tested under Ruby 1.9.2-p290

## Installation

`gem install activity_feed`

or:

`gem 'activity_feed'`

Make sure your redis server is running! Redis configuration is outside the scope of this README, but 
check out the Redis documentation, http://redis.io/documentation.

## Usage

Make sure MongoMapper is configured correctly before `require 'activity_feed'`. 
If using Activity Feed outside of Rails, you can do: 

```ruby
MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
MongoMapper.database = 'activity_feeds_production'
```

Make sure to set the Redis connection for use by the ActivityFeed classes.

```ruby
$redis = Redis.new(:host => '127.0.0.1', :port => 6379)
ActivityFeed.redis = $redis
```

```ruby
dczarnecki-agora:activity_feed dczarnecki$ bundle exec irb
ruby-1.9.2-p290 :001 > require 'mongo_mapper'
 => true 
ruby-1.9.2-p290 :002 > require 'redis'
 => true 
ruby-1.9.2-p290 :003 > MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
 => #<Mongo::Connection:0x000001008a8d00 @host_to_try=["localhost", 27017], @port=nil, @host=nil, @slave_ok=nil, @auths=[], @id_lock=#<Mutex:0x000001008a8a08>, @pool_size=1, @timeout=5.0, @op_timeout=nil, @connection_mutex=#<Mutex:0x000001008a89e0>, @safe=false, @safe_mutexes={#<TCPSocket:(closed)>=>#<Mutex:0x000001008a1b90>, #<TCPSocket:fd 5>=>#<Mutex:0x0000010087ca98>}, @queue=#<ConditionVariable:0x000001008a88a0 @waiters=[], @waiters_mutex=#<Mutex:0x000001008a8828>>, @primary=["localhost", 27017], @primary_pool=#<Mongo::Pool:0x0000010089fca0 @connection=#<Mongo::Connection:0x000001008a8d00 ...>, @port=27017, @host="localhost", @size=1, @timeout=5.0, @connection_mutex=#<Mutex:0x0000010089fb88>, @queue=#<ConditionVariable:0x0000010089fb60 @waiters=[], @waiters_mutex=#<Mutex:0x0000010089fa48>>, @socket_ops={#<TCPSocket:fd 5>=>[]}, @sockets=[#<TCPSocket:fd 5>], @pids={#<TCPSocket:fd 5>=>56865}, @checked_out=[]>, @logger=nil, @read_primary=true> 
ruby-1.9.2-p290 :004 > MongoMapper.database = 'activity_feed_gem_test'
 => "activity_feed_gem_test" 
ruby-1.9.2-p290 :005 > $redis = Redis.new(:host => '127.0.0.1', :port => 6379)
 => #<Redis client v2.2.2 connected to redis://127.0.0.1:6379/0 (Redis v2.2.12)> 
ruby-1.9.2-p290 :006 > require 'activity_feed'
 => true 
ruby-1.9.2-p290 :007 > ActivityFeed.redis = $redis
 => #<Redis client v2.2.2 connected to redis://127.0.0.1:6379/0 (Redis v2.2.12)> 
ruby-1.9.2-p290 :008 > item = ActivityFeed::Item.new(:user_id => 1, :nickname => 'David Czarnecki', :type => 'activity-type', :text => 'Text')
 => #<ActivityFeed::Item _id: BSON::ObjectId('4e6fa45c12dac1de21000001'), user_id: 1, nickname: "David Czarnecki", text: "Text", type: "activity-type"> 
ruby-1.9.2-p290 :009 > item.save
 => true 
ruby-1.9.2-p290 :010 > feed = ActivityFeed::Feed.new(1)
 => #<ActivityFeed::Feed:0x000001030f22c0 @feederboard=#<Leaderboard:0x000001030f20b8 @leaderboard_name="mlg:feed_1", @page_size=25, @redis_connection=#<Redis client v2.2.2 connected to redis://127.0.0.1:6379/0 (Redis v2.2.12)>>> 
ruby-1.9.2-p290 :011 > feed.page(1)
 => [#<ActivityFeed::Item _id: BSON::ObjectId('4e6fa45c12dac1de21000001'), created_at: 2011-09-13 18:43:42 UTC, user_id: 1, nickname: "David Czarnecki", text: "Text", type: "activity-type", updated_at: 2011-09-13 18:43:42 UTC>] 
ruby-1.9.2-p290 :012 > 
```

## Contributing to Activity Feed

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2011 David Czarnecki. See LICENSE.txt for further details.
