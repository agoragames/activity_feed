# ActivityFeed

Activity feeds in Redis

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
ActivityFeed.persistence = :memory (or :active_record or _:mongo_mapper)
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
 => #<ActivityFeed::Memory::Item:0x00000100ceaaa8 @attributes={:user_id=>1, :nickname=>"David Czarnecki", :type=>"activity-type", :text=>"Text"}, @user_id=1, @nickname="David Czarnecki", @type="activity-type", @text="Text"> 
ruby-1.9.2-p290 :006 > ActivityFeed.create_item(:user_id => 1, :nickname => 'David Czarnecki', :type => 'activity-type', :text => 'More text')
 => #<ActivityFeed::Memory::Item:0x000001022b0c48 @attributes={:user_id=>1, :nickname=>"David Czarnecki", :type=>"activity-type", :text=>"More text"}, @user_id=1, @nickname="David Czarnecki", @type="activity-type", @text="More text"> 
ruby-1.9.2-p290 :007 > feed = ActivityFeed::Feed.new(1)
 => #<ActivityFeed::Feed:0x00000103023b78 @feederboard=#<Leaderboard:0x00000103023a88 @leaderboard_name="activity:feed:1", @page_size=25, @redis_connection=#<Redis client v2.2.2 connected to redis://localhost:6379/0 (Redis v2.2.12)>>> 
ruby-1.9.2-p290 :008 > feed.page(1)
 => [{"user_id"=>1, "nickname"=>"David Czarnecki", "type"=>"activity-type", "text"=>"More text"}, {"user_id"=>1, "nickname"=>"David Czarnecki", "type"=>"activity-type", "text"=>"Text"}] 
ruby-1.9.2-p290 :009 > 
```

### ActiveRecord persistence

ActivityFeed can also use ActiveRecord to persist the items to more durable storage while 
keeping the IDs for the activity feed items in Redis. You can set this using:

```ruby
ActivityFeed.persistence = :active_record
```

Example:

```ruby
ruby-1.9.2-p290 :001 > require 'active_record'
 => true 
ruby-1.9.2-p290 :002 > 
ruby-1.9.2-p290 :003 >   ActiveRecord::Base.establish_connection(
ruby-1.9.2-p290 :004 >       :adapter => "sqlite3",
ruby-1.9.2-p290 :005 >       :database => ":memory:"
ruby-1.9.2-p290 :006?>   )
 => #<ActiveRecord::ConnectionAdapters::ConnectionPool:0x00000101329cc0 @spec=#<ActiveRecord::Base::ConnectionSpecification:0x00000101329d38 @config={:adapter=>"sqlite3", :database=>":memory:"}, @adapter_method="sqlite3_connection">, @reserved_connections={}, @connection_mutex=#<Monitor:0x00000101329bd0 @mon_owner=nil, @mon_count=0, @mon_mutex=#<Mutex:0x00000101329b80>>, @queue=#<MonitorMixin::ConditionVariable:0x00000101329b30 @monitor=#<Monitor:0x00000101329bd0 @mon_owner=nil, @mon_count=0, @mon_mutex=#<Mutex:0x00000101329b80>>, @cond=#<ConditionVariable:0x00000101329b08 @waiters=[], @waiters_mutex=#<Mutex:0x00000101329978>>>, @timeout=5, @size=5, @connections=[], @checked_out=[], @automatic_reconnect=true, @tables={}, @visitor=nil, @columns={}, @columns_hash={}, @column_defaults={}, @primary_keys={}> 
ruby-1.9.2-p290 :007 > 
ruby-1.9.2-p290 :008 >   ActiveRecord::Migration.verbose = false
 => false 
ruby-1.9.2-p290 :009 > 
ruby-1.9.2-p290 :010 >   ActiveRecord::Schema.define do
ruby-1.9.2-p290 :011 >       create_table :activity_feed_items, :force => true do |t|
ruby-1.9.2-p290 :012 >           t.integer :user_id
ruby-1.9.2-p290 :013?>         t.string :nickname
ruby-1.9.2-p290 :014?>         t.string :type
ruby-1.9.2-p290 :015?>         t.string :title
ruby-1.9.2-p290 :016?>         t.text :text
ruby-1.9.2-p290 :017?>         t.string :url
ruby-1.9.2-p290 :018?>         t.string :icon
ruby-1.9.2-p290 :019?>         t.boolean :sticky
ruby-1.9.2-p290 :020?>         
ruby-1.9.2-p290 :021 >           t.timestamps
ruby-1.9.2-p290 :022?>       end
ruby-1.9.2-p290 :023?>   
ruby-1.9.2-p290 :024 >       add_index :activity_feed_items, :user_id
ruby-1.9.2-p290 :025?>   end
 => nil 
ruby-1.9.2-p290 :026 > 
ruby-1.9.2-p290 :027 >   require 'redis'
 => true 
ruby-1.9.2-p290 :028 > $redis = Redis.new(:host => 'localhost', :port => 6379)
 => #<Redis client v2.2.2 connected to redis://localhost:6379/0 (Redis v2.2.12)> 
ruby-1.9.2-p290 :029 > require 'activity_feed'
 => true 
ruby-1.9.2-p290 :030 > ActivityFeed.redis = $redis
 => #<Redis client v2.2.2 connected to redis://localhost:6379/0 (Redis v2.2.12)> 
ruby-1.9.2-p290 :031 > ActivityFeed.persistence = :active_record
 => :active_record 
ruby-1.9.2-p290 :032 > ActivityFeed.create_item(:user_id => 1, :nickname => 'David Czarnecki', :type => 'activity-type', :text => 'Text')
 => #<ActivityFeed::ActiveRecord::Item id: 1, user_id: 1, nickname: "David Czarnecki", type: nil, title: nil, text: "Text", url: nil, icon: nil, sticky: nil, created_at: "2011-09-14 15:08:22", updated_at: "2011-09-14 15:08:22"> 
ruby-1.9.2-p290 :033 > ActivityFeed.create_item(:user_id => 1, :nickname => 'David Czarnecki', :type => 'activity-type', :text => 'More text')
 => #<ActivityFeed::ActiveRecord::Item id: 2, user_id: 1, nickname: "David Czarnecki", type: nil, title: nil, text: "More text", url: nil, icon: nil, sticky: nil, created_at: "2011-09-14 15:08:25", updated_at: "2011-09-14 15:08:25"> 
ruby-1.9.2-p290 :034 > feed = ActivityFeed::Feed.new(1)
 => #<ActivityFeed::Feed:0x000001030f1898 @feederboard=#<Leaderboard:0x000001030f1578 @leaderboard_name="activity:feed:1", @page_size=25, @redis_connection=#<Redis client v2.2.2 connected to redis://localhost:6379/0 (Redis v2.2.12)>>> 
ruby-1.9.2-p290 :035 > feed.page(1)
 => [#<ActivityFeed::ActiveRecord::Item id: 2, user_id: 1, nickname: "David Czarnecki", type: nil, title: nil, text: "More text", url: nil, icon: nil, sticky: nil, created_at: "2011-09-14 15:08:25", updated_at: "2011-09-14 15:08:25">, #<ActivityFeed::ActiveRecord::Item id: 1, user_id: 1, nickname: "David Czarnecki", type: nil, title: nil, text: "Text", url: nil, icon: nil, sticky: nil, created_at: "2011-09-14 15:08:22", updated_at: "2011-09-14 15:08:22">] 
ruby-1.9.2-p290 :036 > 
```

### MongoMapper persistence

ActivityFeed can also use MongoMapper to persist the items to more durable storage while 
keeping the IDs for the activity feed items in Redis. You can set this using:

```ruby
ActivityFeed.persistence = :mongo_mapper
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
ruby-1.9.2-p290 :008 > ActivityFeed.persistence = :mongo_mapper
 => :mongo_mapper 
ruby-1.9.2-p290 :009 > ActivityFeed.create_item(:user_id => 1, :nickname => 'David Czarnecki', :type => 'activity-type', :text => 'Text')
 => #<ActivityFeed::MongoMapper::Item _id: BSON::ObjectId('4e70dcc512dac1efa0000001'), created_at: 2011-09-14 16:56:37 UTC, nickname: "David Czarnecki", text: "Text", type: "activity-type", updated_at: 2011-09-14 16:56:37 UTC, user_id: 1> 
ruby-1.9.2-p290 :010 > ActivityFeed.create_item(:user_id => 1, :nickname => 'David Czarnecki', :type => 'activity-type', :text => 'More text')
 => #<ActivityFeed::MongoMapper::Item _id: BSON::ObjectId('4e70dcc512dac1efa0000003'), created_at: 2011-09-14 16:56:37 UTC, nickname: "David Czarnecki", text: "More text", type: "activity-type", updated_at: 2011-09-14 16:56:37 UTC, user_id: 1> 
ruby-1.9.2-p290 :011 > feed = ActivityFeed::Feed.new(1)
 => #<ActivityFeed::Feed:0x00000100c583d8 @feederboard=#<Leaderboard:0x00000100c58298 @leaderboard_name="activity:feed:1", @page_size=25, @redis_connection=#<Redis client v2.2.2 connected to redis://localhost:6379/0 (Redis v2.2.12)>>> 
ruby-1.9.2-p290 :012 > feed.page(1)
 => [#<ActivityFeed::MongoMapper::Item _id: BSON::ObjectId('4e70dcc512dac1efa0000003'), created_at: 2011-09-14 16:56:37 UTC, nickname: "David Czarnecki", text: "More text", type: "activity-type", updated_at: 2011-09-14 16:56:37 UTC, user_id: 1>, #<ActivityFeed::MongoMapper::Item _id: BSON::ObjectId('4e70dcc512dac1efa0000001'), created_at: 2011-09-14 16:56:37 UTC, nickname: "David Czarnecki", text: "Text", type: "activity-type", updated_at: 2011-09-14 16:56:37 UTC, user_id: 1>] 
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
