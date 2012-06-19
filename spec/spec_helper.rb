require 'activity_feed'
require 'timecop'

RSpec.configure do |config|
  config.mock_with :rspec
  
  config.before(:all) do
    ActivityFeed.configure do |configuration|
      configuration.redis = Redis.new(:db => 15)
    end
  end

  config.before(:each) do
    ActivityFeed.redis.flushdb
  end

  config.after(:all) do
    ActivityFeed.redis.flushdb
    ActivityFeed.redis.quit
  end

  # Helper method to add items to a given feed.
  # 
  # @param items_to_add [int] Number of items to add to the feed.
  def add_items_to_feed(user_id, items_to_add = 5, aggregate = false)
    1.upto(items_to_add) do |index|
      ActivityFeed.update_item(user_id, index, DateTime.now.to_i, aggregate)
      Timecop.travel(DateTime.now + 10)
    end

    Timecop.return
  end
end