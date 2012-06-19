# ActivityFeed

Activity feeds backed by Redis

## Compatibility

The gem has been built and tested under Ruby 1.9.3.

## Installation

`gem install activity_feed`

or:

`gem 'activity_feed'`

Make sure your redis server is running! Redis configuration is outside the scope of this README, but 
check out the [Redis documentation](http://redis.io/documentation).

## Configuration

Basic configuration options:

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

ActivityFeed supports loading items from your ORM (e.g. ActiveRecord) or your ODM (e.g. Mongoid) 
with the `item_loader` configuration option when a page for a user's activity feed is requested. 
For example:

Assume you have defined a class for your items in Mongoid as follows:

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

      after_save :update_activity_feed    

      private

      def update_activity_feed
        ActivityFeed.update_item(self.user_id, self.id, self.updated_at.to_i)
      end
    end
  end
end
```

You would add the following option whereever you are configuring ActivityFeed as follows:

```ruby
ActivityFeed.item_loader = Proc.new { |id| ActivityFeed::Mongoid::Item.find(id) }
```

## Usage

Attached is a complete example using Mongoid as our persistent storage for activity feed items.
The example uses callbacks to update and remove items from the activity feed. As this example 
uses the `updated_at` time of the item, updated items will "bubble up" to the top of the 
activity feed.

```ruby
require 'mongoid'

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db("activity_feed_gem_test")
end

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

      after_save :update_activity_feed
      after_destroy :remove_item_from_activity_feed

      private

      def update_activity_feed
        ActivityFeed.update_item(self.user_id, self.id, self.updated_at.to_i)
      end

      def remove_item_from_activity_feed
        ActivityFeed.remove_item(self.user_id, self.id)
      end
    end
  end
end

require 'activity_feed'

ActivityFeed.configure do |configuration|
  configuration.redis = Redis.new(:host => '127.0.0.1', :port => 6379)
  configuration.namespace = 'activity_feed'
  configuration.aggregate = true
  configuration.aggregate_key = 'aggregate'
  configuration.page_size = 25
  configuration.item_loader = Proc.new { |id| ActivityFeed::Mongoid::Item.find(id) }
end

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

feed = ActivityFeed.feed('david', 1)
 => [#<ActivityFeed::Mongoid::Item _id: 4fe0ce26421aa91fc2000004, _type: nil, created_at: 2012-06-19 19:08:22 UTC, updated_at: 2012-06-19 19:08:22 UTC, user_id: "david", nickname: "David Czarnecki", type: "some_activity", title: "Another great activity", text: "This is some other text for the activity feed item", url: "http://url.com", icon: nil, sticky: nil>, #<ActivityFeed::Mongoid::Item _id: 4fe0ce26421aa91fc2000003, _type: nil, created_at: 2012-06-19 19:08:22 UTC, updated_at: 2012-06-19 19:08:22 UTC, user_id: "david", nickname: "David Czarnecki", type: "some_activity", title: "Great activity", text: "This is text for the activity feed item", url: "http://url.com", icon: nil, sticky: nil>] 

activity_item_1.text = 'Updated some text for the activity feed item'

feed = ActivityFeed.feed('david', 1)
 => [#<ActivityFeed::Mongoid::Item _id: 4fe0ce26421aa91fc2000003, _type: nil, created_at: 2012-06-19 19:08:22 UTC, updated_at: 2012-06-19 19:11:27 UTC, user_id: "david", nickname: "David Czarnecki", type: "some_activity", title: "Great activity", text: "Updated some text for the activity feed item", url: "http://url.com", icon: nil, sticky: nil>, #<ActivityFeed::Mongoid::Item _id: 4fe0ce26421aa91fc2000004, _type: nil, created_at: 2012-06-19 19:08:22 UTC, updated_at: 2012-06-19 19:08:22 UTC, user_id: "david", nickname: "David Czarnecki", type: "some_activity", title: "Another great activity", text: "This is some other text for the activity feed item", url: "http://url.com", icon: nil, sticky: nil>] 
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