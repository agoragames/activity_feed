require 'rubygems'
require 'rspec'
require 'redis'
require 'mongo_mapper'
require 'database_cleaner'
require 'fabrication'

$redis = Redis.new(:host => '127.0.0.1', :port => 6379)
MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
MongoMapper.database = 'activity_feed_gem_test'

require File.join(File.dirname(__FILE__), %w{ .. lib activity_feed})

ActivityFeed.redis = $redis

RSpec.configure do |config|
  config.mock_with :rspec
  
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
    $redis.flushdb
  end

  config.before(:each) do
    ActivityFeed.persistence = :memory_item
    DatabaseCleaner.start
    DatabaseCleaner.clean
  end

  config.after(:each) do
    DatabaseCleaner.clean
    $redis.flushdb
  end  
end