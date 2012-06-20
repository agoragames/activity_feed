# ActivityFeed

Activity feeds backed by Redis

## Compatibility

The gem has been built and tested under Ruby 1.8.7 and Ruby 1.9.3.

## Installation

`gem install activity_feed`

or:

`gem 'activity_feed'`

Make sure your redis server is running! Redis configuration is outside the scope of this README, but 
check out the [Redis documentation](http://redis.io/documentation).

## Configuration

### Basic configuration options

```ruby
require 'activity_feed'

ActivityFeed.configure do |configuration|
  configuration.redis = Redis.new(:host => '127.0.0.1', :port => 6379)
  configuration.namespace = 'activity_feed'
  configuration.aggregate = true
  configuration.aggregate_key = 'aggregate'
  configuration.page_size = 25
end
```

* `redis`: The Redis connection instance to be used.
* `namespace`: Namespace to isolate ActivityFeed data in Redis.
* `aggregate`: Determines whether or not, by default, various calls will pull from the aggregate activity feed for a user.
* `aggregate_key`: Further isolates the aggregate ActivityFeed data.
* `page_size`: Number of activity feed items to be retrieved per-page.

### Advanced configuration options

* `item_loader`: ActivityFeed supports loading items from your ORM (e.g. ActiveRecord) or your ODM (e.g. Mongoid) with the `item_loader` configuration option when a page for a user's activity feed is requested. This option should be set to a Proc that will be called passing the item ID as its only argument.

For example:

Assume you have defined a class for storing your activity feed items in Mongoid as follows:

```ruby
require 'mongoid'

module ActivityFeed
  module Mongoid
    class Item
      include ::Mongoid::Document    
      include ::Mongoid::Timestamps

      field :user_id, type: String
      validates_presence_of :user_id

      field :nickname, type: String
      field :type, type: String
      field :title, type: String
      field :text, type: String
      field :url, type: String
      field :icon, type: String
      field :sticky, type: Boolean

      index :user_id

      after_save :update_item_in_activity_feed    

      private

      def update_item_in_activity_feed
        ActivityFeed.update_item(self.user_id, self.id, self.updated_at.to_i)
      end
    end
  end
end
```

You would add the following option where you are configuring ActivityFeed as follows:

```ruby
ActivityFeed.item_loader = Proc.new { |id| ActivityFeed::Mongoid::Item.find(id) }
```

## Usage

Attached is a complete example using Mongoid as our persistent storage for activity feed items.
The example uses callbacks to update and remove items from the activity feed. As this example 
uses the `updated_at` time of the item, updated items will "bubble up" to the top of the 
activity feed.

```ruby
# Configure Mongoid
require 'mongoid'

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db("activity_feed_gem_test")
end

# Create a class for activity feed items
module ActivityFeed
  module Mongoid
    class Item
      include ::Mongoid::Document    
      include ::Mongoid::Timestamps

      field :user_id, type: String
      validates_presence_of :user_id

      field :nickname, type: String
      field :type, type: String
      field :title, type: String
      field :text, type: String
      field :url, type: String
      field :icon, type: String
      field :sticky, type: Boolean

      index :user_id

      after_save :update_item_in_activity_feed
      after_destroy :remove_item_from_activity_feed

      private

      def update_item_in_activity_feed
        ActivityFeed.update_item(self.user_id, self.id, self.updated_at.to_i)
      end

      def remove_item_from_activity_feed
        ActivityFeed.remove_item(self.user_id, self.id)
      end
    end
  end
end

# Configure ActivityFeed
require 'activity_feed'

ActivityFeed.configure do |configuration|
  configuration.redis = Redis.new(:host => '127.0.0.1', :port => 6379)
  configuration.namespace = 'activity_feed'
  configuration.aggregate = true
  configuration.aggregate_key = 'aggregate'
  configuration.page_size = 25
  configuration.item_loader = Proc.new { |id| ActivityFeed::Mongoid::Item.find(id) }
end

# Create a couple of activity feed items
activity_item_1 = ActivityFeed::Mongoid::Item.create(
  :user_id => 'david', 
  :nickname => 'David Czarnecki',
  :type => 'some_activity',
  :title => 'Great activity',
  :text => 'This is text for the activity feed item',
  :url => 'http://url.com'
)

activity_item_2 = ActivityFeed::Mongoid::Item.create(
  :user_id => 'david', 
  :nickname => 'David Czarnecki',
  :type => 'some_activity',
  :title => 'Another great activity',
  :text => 'This is some other text for the activity feed item',
  :url => 'http://url.com'
)

# Pull up the activity feed
feed = ActivityFeed.feed('david', 1)
 => [#<ActivityFeed::Mongoid::Item _id: 4fe0ce26421aa91fc2000004, _type: nil, created_at: 2012-06-19 19:08:22 UTC, updated_at: 2012-06-19 19:08:22 UTC, user_id: "david", nickname: "David Czarnecki", type: "some_activity", title: "Another great activity", text: "This is some other text for the activity feed item", url: "http://url.com", icon: nil, sticky: nil>, #<ActivityFeed::Mongoid::Item _id: 4fe0ce26421aa91fc2000003, _type: nil, created_at: 2012-06-19 19:08:22 UTC, updated_at: 2012-06-19 19:08:22 UTC, user_id: "david", nickname: "David Czarnecki", type: "some_activity", title: "Great activity", text: "This is text for the activity feed item", url: "http://url.com", icon: nil, sticky: nil>] 

# Update an actitivity feed item
activity_item_1.text = 'Updated some text for the activity feed item'
activity_item_1.save

# Pull up the activity feed item and notice that the item you updated has "bubbled up" to the top of the feed
feed = ActivityFeed.feed('david', 1)
 => [#<ActivityFeed::Mongoid::Item _id: 4fe0ce26421aa91fc2000003, _type: nil, created_at: 2012-06-19 19:08:22 UTC, updated_at: 2012-06-19 19:11:27 UTC, user_id: "david", nickname: "David Czarnecki", type: "some_activity", title: "Great activity", text: "Updated some text for the activity feed item", url: "http://url.com", icon: nil, sticky: nil>, #<ActivityFeed::Mongoid::Item _id: 4fe0ce26421aa91fc2000004, _type: nil, created_at: 2012-06-19 19:08:22 UTC, updated_at: 2012-06-19 19:08:22 UTC, user_id: "david", nickname: "David Czarnecki", type: "some_activity", title: "Another great activity", text: "This is some other text for the activity feed item", url: "http://url.com", icon: nil, sticky: nil>] 
```

## ActivityFeed method summary

```ruby
# Item-related

ActivityFeed.update_item(user_id, item_id, timestamp, aggregate = ActivityFeed.aggregate)
ActivityFeed.aggregate_item(user_id, item_id, timestamp)
ActivityFeed.remove_item(user_id, item_id)

# Feed-related

ActivityFeed.feed(user_id, page, aggregate = ActivityFeed.aggregate)
ActivityFeed.feed_between_timestamps(user_id, starting_timestamp, ending_timestamp, aggregate = ActivityFeed.aggregate)
ActivityFeed.total_pages_in_feed(user_id, aggregate = ActivityFeed.aggregate, page_size = ActivityFeed.page_size)
ActivityFeed.total_items_in_feed(user_id, aggregate = ActivityFeed.aggregate)
ActivityFeed.trim_feed(user_id, starting_timestamp, ending_timestamp, aggregate = ActivityFeed.aggregate)
ActivityFeed.remove_feeds(user_id)
```

## Contributing to ActivityFeed

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2011-2012 David Czarnecki. See LICENSE.txt for further details.