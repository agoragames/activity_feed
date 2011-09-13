require 'rubygems'
require 'rspec'
require 'active_support/cache'
require 'active_support/core_ext/module/aliasing'
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
    DatabaseCleaner.start
    DatabaseCleaner.clean
    $redis.flushdb
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end  
end