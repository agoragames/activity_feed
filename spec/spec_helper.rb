require 'rubygems'
require 'rspec'
require 'redis'
require 'mongo_mapper'
require 'database_cleaner'
require 'fabrication'

$redis = Redis.new(:host => '127.0.0.1', :port => 6379)

# TODO: Move to spec/mongo_mapper
MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
MongoMapper.database = 'activity_feed_gem_test'

# TODO: Move to spec/active_record
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

DatabaseCleaner[:active_record].strategy = :transaction
DatabaseCleaner[:mongo_mapper].strategy = :truncation

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
    ActivityFeed.persistence = :memory
    DatabaseCleaner.start
    DatabaseCleaner.clean
  end

  config.after(:each) do
    DatabaseCleaner.clean
    $redis.flushdb
  end  
end