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

## Configuration

```ruby
ActivityFeed.redis = Redis.new(:host => '127.0.0.1', :port => 6379)
ActivityFeed.namespace = 'activity'
ActivityFeed.key = 'feed'
ActivityFeed.persistence = :memory_item (or :mongo_mapper_item)
```

## Usage

Make sure to set the Redis connection for use by the ActivityFeed classes.

```ruby
$redis = Redis.new(:host => '127.0.0.1', :port => 6379)
ActivityFeed.redis = $redis
```

### Memory-backed persistence

ActivityFeed defaults to using memory-backed persistence, storing the full item as JSON in Redis.

```ruby
ruby-1.9.2-p290 :001 > require 'redis'
 => true 
ruby-1.9.2-p290 :002 > $redis = Redis.new(:host => 'localhost', :port => 6379)
 => #<Redis client v2.2.2 connected to redis://localhost:6379/0 (Redis v2.2.12)> 
ruby-1.9.2-p290 :003 > require 'activity_feed'
 => true 
ruby-1.9.2-p290 :004 > ActivityFeed.redis = $redis
 => #<Redis client v2.2.2 connected to redis://localhost:6379/0 (Redis v2.2.12)> 
ruby-1.9.2-p290 :005 > ActivityFeed.create_item(:user_id => 1, :nickname => 'David Czarnecki', :type => 'activity-type', :text => 'Text')
 => #<ActivityFeed::MemoryItem:0x00000100ceaaa8 @attributes={:user_id=>1, :nickname=>"David Czarnecki", :type=>"activity-type", :text=>"Text"}, @user_id=1, @nickname="David Czarnecki", @type="activity-type", @text="Text"> 
ruby-1.9.2-p290 :006 > ActivityFeed.create_item(:user_id => 1, :nickname => 'David Czarnecki', :type => 'activity-type', :text => 'More text')
 => #<ActivityFeed::MemoryItem:0x000001022b0c48 @attributes={:user_id=>1, :nickname=>"David Czarnecki", :type=>"activity-type", :text=>"More text"}, @user_id=1, @nickname="David Czarnecki", @type="activity-type", @text="More text"> 
ruby-1.9.2-p290 :007 > feed = ActivityFeed::Feed.new(1)
 => #<ActivityFeed::Feed:0x00000103023b78 @feederboard=#<Leaderboard:0x00000103023a88 @leaderboard_name="activity:feed:1", @page_size=25, @redis_connection=#<Redis client v2.2.2 connected to redis://localhost:6379/0 (Redis v2.2.12)>>> 
ruby-1.9.2-p290 :008 > feed.page(1)
 => [{"user_id"=>1, "nickname"=>"David Czarnecki", "type"=>"activity-type", "text"=>"More text"}, {"user_id"=>1, "nickname"=>"David Czarnecki", "type"=>"activity-type", "text"=>"Text"}] 
ruby-1.9.2-p290 :009 > 
```

### MongoMapper persistence

ActivityFeed can also use MongoMapper to persist the items to more durable storage while 
keeping the IDs for the activity feed items in Redis. You can set this using:

```ruby
ActivityFeed.persistence = :mongo_mapper_item
```

Make sure MongoMapper is configured correctly before setting this option. 
If using Activity Feed outside of Rails, you can do: 

```ruby
MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
MongoMapper.database = 'activity_feeds_production'
```

```ruby
ruby-1.9.2-p290 :001 > require 'mongo_mapper'
 => true 
ruby-1.9.2-p290 :002 > MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
 => #<Mongo::Connection:0x00000100c7d520 @host_to_try=["localhost", 27017], @port=nil, @host=nil, @slave_ok=nil, @auths=[], @id_lock=#<Mutex:0x00000100c7d480>, @pool_size=1, @timeout=5.0, @op_timeout=nil, @connection_mutex=#<Mutex:0x00000100c7d458>, @safe=false, @safe_mutexes={#<TCPSocket:(closed)>=>#<Mutex:0x00000100c6f8a8>, #<TCPSocket:fd 5>=>#<Mutex:0x00000100c6db70>}, @queue=#<ConditionVariable:0x00000100c7d390 @waiters=[], @waiters_mutex=#<Mutex:0x00000100c7d340>>, @primary=["localhost", 27017], @primary_pool=#<Mongo::Pool:0x00000100c6f128 @connection=#<Mongo::Connection:0x00000100c7d520 ...>, @port=27017, @host="localhost", @size=1, @timeout=5.0, @connection_mutex=#<Mutex:0x00000100c6f100>, @queue=#<ConditionVariable:0x00000100c6f0b0 @waiters=[], @waiters_mutex=#<Mutex:0x00000100c6f060>>, @socket_ops={#<TCPSocket:fd 5>=>[]}, @sockets=[#<TCPSocket:fd 5>], @pids={#<TCPSocket:fd 5>=>61344}, @checked_out=[]>, @logger=nil, @read_primary=true> 
ruby-1.9.2-p290 :003 > MongoMapper.database = 'activity_feed_gem_test'
 => "activity_feed_gem_test" 
ruby-1.9.2-p290 :004 > require 'redis'
 => true 
ruby-1.9.2-p290 :005 > $redis = Redis.new(:host => 'localhost', :port => 6379)
 => #<Redis client v2.2.2 connected to redis://localhost:6379/0 (Redis v2.2.12)> 
ruby-1.9.2-p290 :006 > require 'activity_feed'
 => true 
ruby-1.9.2-p290 :007 > ActivityFeed.redis = $redis
 => #<Redis client v2.2.2 connected to redis://localhost:6379/0 (Redis v2.2.12)> 
ruby-1.9.2-p290 :008 > ActivityFeed.persistence = :mongo_mapper_item
 => :mongo_mapper_item 
ruby-1.9.2-p290 :009 > ActivityFeed.create_item(:user_id => 1, :nickname => 'David Czarnecki', :type => 'activity-type', :text => 'Text')
 => #<ActivityFeed::MongoMapperItem _id: BSON::ObjectId('4e70dcc512dac1efa0000001'), created_at: 2011-09-14 16:56:37 UTC, nickname: "David Czarnecki", text: "Text", type: "activity-type", updated_at: 2011-09-14 16:56:37 UTC, user_id: 1> 
ruby-1.9.2-p290 :010 > ActivityFeed.create_item(:user_id => 1, :nickname => 'David Czarnecki', :type => 'activity-type', :text => 'More text')
 => #<ActivityFeed::MongoMapperItem _id: BSON::ObjectId('4e70dcc512dac1efa0000003'), created_at: 2011-09-14 16:56:37 UTC, nickname: "David Czarnecki", text: "More text", type: "activity-type", updated_at: 2011-09-14 16:56:37 UTC, user_id: 1> 
ruby-1.9.2-p290 :011 > feed = ActivityFeed::Feed.new(1)
 => #<ActivityFeed::Feed:0x00000100c583d8 @feederboard=#<Leaderboard:0x00000100c58298 @leaderboard_name="activity:feed:1", @page_size=25, @redis_connection=#<Redis client v2.2.2 connected to redis://localhost:6379/0 (Redis v2.2.12)>>> 
ruby-1.9.2-p290 :012 > feed.page(1)
 => [#<ActivityFeed::MongoMapperItem _id: BSON::ObjectId('4e70dcc512dac1efa0000003'), created_at: 2011-09-14 16:56:37 UTC, nickname: "David Czarnecki", text: "More text", type: "activity-type", updated_at: 2011-09-14 16:56:37 UTC, user_id: 1>, #<ActivityFeed::MongoMapperItem _id: BSON::ObjectId('4e70dcc512dac1efa0000001'), created_at: 2011-09-14 16:56:37 UTC, nickname: "David Czarnecki", text: "Text", type: "activity-type", updated_at: 2011-09-14 16:56:37 UTC, user_id: 1>] 
ruby-1.9.2-p290 :013 > 
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
