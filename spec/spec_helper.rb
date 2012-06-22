require 'activity_feed'
require 'timecop'
require 'database_cleaner'
require 'support/mongoid'
require 'support/active_record'

RSpec.configure do |config|
  config.mock_with :rspec
  
  config.before(:all) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
    DatabaseCleaner.clean

    ActivityFeed.configure do |configuration|
      configuration.item_loader = nil
      configuration.item_loader_exception_handler = nil
      configuration.redis = Redis.new(:db => 15)
    end

    ActivityFeed.redis.flushdb
  end

  config.after(:each) do
    DatabaseCleaner.clean    

    ActivityFeed.redis.quit
  end

  # Helper method to add items to a given feed.
  # 
  # @param items_to_add [int] Number of items to add to the feed.
  def add_items_to_feed(user_id, items_to_add = 5, aggregate = ActivityFeed.aggregate)
    1.upto(items_to_add) do |index|
      ActivityFeed.update_item(user_id, index, DateTime.now.to_i, aggregate)
      Timecop.travel(DateTime.now + 10)
    end

    Timecop.return
  end
end