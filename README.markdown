# ActivityFeed

Activity feeds backed by Redis

## Compatibility

The gem has been built and tested under Ruby 1.9.2-p290 and Ruby 1.9.3-p0

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
ActivityFeed.persistence = :memory # (or :active_record or :mongo_mapper or :ohm)
ActivityFeed.aggregate = true
ActivityFeed.aggregate_key = 'aggregate'
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
require 'redis'
$redis = Redis.new(:host => 'localhost', :port => 6379)
require 'activity_feed'
ActivityFeed.redis = $redis
ActivityFeed.create_item(:user_id => 1, :nickname => 'David Czarnecki', :type => 'activity-type', :text => 'Text')
ActivityFeed.create_item(:user_id => 1, :nickname => 'David Czarnecki', :type => 'activity-type', :text => 'More text')
feed = ActivityFeed::Feed.new(1)
feed.page(1)
```

### ActiveRecord persistence

ActivityFeed can also use ActiveRecord to persist the items to more durable storage while 
keeping the IDs for the activity feed items in Redis. You can set this using:

```ruby
ActivityFeed.persistence = :active_record
```

Example:

```ruby
require 'active_record'

ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database => ":memory:"
)

ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :activity_feed_items, :force => true do |t|
    t.integer :user_id
    t.string :nickname
    t.string :type
    t.string :title
    t.text :text
    t.string :url
    t.string :icon
    t.boolean :sticky
    
    t.timestamps
  end

  add_index :activity_feed_items, :user_id
end

require 'redis'
$redis = Redis.new(:host => 'localhost', :port => 6379)
require 'activity_feed'
ActivityFeed.redis = $redis
ActivityFeed.persistence = :active_record
ActivityFeed.create_item(:user_id => 1, :nickname => 'David Czarnecki', :type => 'activity-type', :text => 'Text')
ActivityFeed.create_item(:user_id => 1, :nickname => 'David Czarnecki', :type => 'activity-type', :text => 'More text')
feed = ActivityFeed::Feed.new(1)
feed.page(1)
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
require 'mongo_mapper'
MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
MongoMapper.database = 'activity_feed_gem_test'
require 'redis'
$redis = Redis.new(:host => 'localhost', :port => 6379)
require 'activity_feed'
ActivityFeed.redis = $redis
ActivityFeed.persistence = :mongo_mapper
ActivityFeed.create_item(:user_id => 1, :nickname => 'David Czarnecki', :type => 'activity-type', :text => 'Text')
ActivityFeed.create_item(:user_id => 1, :nickname => 'David Czarnecki', :type => 'activity-type', :text => 'More text')
feed = ActivityFeed::Feed.new(1)
feed.page(1)
```

### Mongoid persistence

ActivityFeed can also use Mongoid to persist the items to more durable storage while 
keeping the IDs for the activity feed items in Redis. You can set this using:

```ruby
ActivityFeed.persistence = :mongoid
```

Make sure Mongoid is configured correctly before setting this option. 
If using Activity Feed outside of Rails, you can do: 

```ruby
Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db("activity_feed_gem_test")
end
```

```ruby
require 'mongoid'
Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db("activity_feed_gem_test")
end
require 'redis'
$redis = Redis.new(:host => 'localhost', :port => 6379)
require 'activity_feed'
ActivityFeed.redis = $redis
ActivityFeed.persistence = :mongoid
ActivityFeed.create_item(:user_id => 1, :nickname => 'David Czarnecki', :type => 'activity-type', :text => 'Text')
ActivityFeed.create_item(:user_id => 1, :nickname => 'David Czarnecki', :type => 'activity-type', :text => 'More text')
feed = ActivityFeed::Feed.new(1)
feed.page(1)
```

### Ohm persistence

ActivityFeed can also use Ohm to persist the items in Redis. You can set this using:

```ruby
require 'redis'
$redis = Redis.new(:host => 'localhost', :port => 6379)
require 'activity_feed'
ActivityFeed.redis = $redis
ActivityFeed.persistence = :ohm
ActivityFeed.create_item(:user_id => 1, :nickname => 'David Czarnecki', :type => 'activity-type', :text => 'Text')
ActivityFeed.create_item(:user_id => 1, :nickname => 'David Czarnecki', :type => 'activity-type', :text => 'More text')
feed = ActivityFeed::Feed.new(1)
feed.page(1)
```

### Custom persistence

ActivityFeed can also use a custom class to do more customization. You can set this using:

```ruby
ActivityFeed.persistence = :custom
```

This will try to load the following class:

```ruby
ActivityFeed::Custom::Item
```

If you set persistence to be `:foo`, it would try to load the following class:

```ruby
ActivityFeed::Foo::Item
```

The custom class should implement a find(item_or_item_id) method that does "the right thing". 
Consult the specs to see this working if you have questions.

### Feeds and Aggregation Feeds

You can access an activity feed in a couple of ways.

```ruby
ActivityFeed.feed(user_id) # return an instance of ActivityFeed::Feed
```

or

```ruby
ActivityFeed::Feed.new(user_id)
```

activity_feed uses the following key in adding the item to Redis: `ActivityFeed.namespace:ActivityFeed.key:self.user_id`. By default, activity_feed in the `create_item` call will 
also add the item in Redis to an aggregate feed using the key: `ActivityFeed.namespace:ActivityFeed.key:ActivityFeed.aggregate_key:self.user_id`.

You can control aggregation globally by setting the ActivityFeed.aggregate property to either `true` or `false`. You can override the global aggregation setting on the 
`create_item` call by passing either `true` or `false` as the 2nd argument.

Below is an example of an aggregate feed:

```ruby
require 'activity_feed'
require 'pp'
$redis = Redis.new(:host => '127.0.0.1', :port => 6379)
ActivityFeed.redis = $redis
ActivityFeed.persistence = :ohm

1.upto(5) do |index|
  item = ActivityFeed.create_item(:user_id => 1, :nickname => 'nickname_1', :text => "text_#{index}")
  sleep(1)
  another_item = ActivityFeed.create_item(:user_id => 2, :nickname => 'nickname_2', :text => "test_nickname2_#{index}")
  sleep(1)
  ActivityFeed.aggregate_item(another_item, 1)
end

feed = ActivityFeed::Feed.new(1)
pp feed.page(1, true)
```

### Updating and Removing Activity Feed Items

You can use the following methods to update and removing activity feed items, respectively:

```ruby
ActivityFeed.update_item(user_id, item_id, timestamp, aggregate = false)
ActivityFeed.delete_item(user_id, item_id, aggregate = false)
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

Copyright (c) 2011-2012 David Czarnecki. See LICENSE.txt for further details.

