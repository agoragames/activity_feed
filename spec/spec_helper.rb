require 'activity_feed'

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
end