require 'activity_feed/version'
require 'activity_feed/feed'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/inflector'

require 'redis'

module ActivityFeed
  mattr_accessor :redis
  mattr_accessor :namespace
  mattr_accessor :key
  mattr_accessor :persistence
  mattr_accessor :aggregate_key
  mattr_accessor :aggregate  
    
  def self.persistence=(type = :memory)
    @@persistence_type = type
    
    case type
    when :active_record
      require 'activity_feed/active_record/item'
      klazz = ActivityFeed::ActiveRecord::Item
    when :memory
      require 'activity_feed/memory/item'
      klazz = ActivityFeed::Memory::Item      
    when :mongo_mapper
      require 'activity_feed/mongo_mapper/item'
      klazz = ActivityFeed::MongoMapper::Item
    when :ohm
      require 'activity_feed/ohm/item'
      klazz = ActivityFeed::Ohm::Item
    else
      klazz = "ActivityFeed::#{type.to_s.classify}::Item".constantize
    end
    
    @@persistence = klazz
  end
  
  def self.create_item(attributes, aggregate = ActivityFeed.aggregate)
    item = @@persistence.new(attributes)
    item.save
    if aggregate
      ([item.user_id] | Array(aggregate)).each do |aggregation_id|
        ActivityFeed.aggregate_item(item, aggregation_id)
      end
    end
    item    
  end
  
  def self.aggregate_item(item, user_id = nil)
    user_id_for_aggregate = user_id.nil? ? item.user_id : user_id
    case @@persistence_type
    when :active_record, :mongo_mapper
      ActivityFeed.redis.zadd(ActivityFeed.feed_key(user_id_for_aggregate, true), item.created_at.to_i, item.id)
    when :ohm
      ActivityFeed.redis.zadd(ActivityFeed.feed_key(user_id_for_aggregate, true), DateTime.parse(item.created_at).to_i, item.id)
    else
      ActivityFeed.redis.zadd(ActivityFeed.feed_key(user_id_for_aggregate, true), DateTime.now.to_i, item.attributes.to_json)
    end
  end  
  
  def self.load_item(item_or_item_id)
    case @@persistence_type
    when :active_record
      ActivityFeed::ActiveRecord::Item.find(item_or_item_id)
    when :memory
      JSON.parse(item_or_item_id)
    when :mongo_mapper
      ActivityFeed::MongoMapper::Item.find(item_or_item_id)
    when :ohm
      ActivityFeed::Ohm::Item[item_or_item_id]
    else
      @@persistence.find(item_or_item_id)    
    end
  end
  
  def self.feed_key(user_id, aggregate = false)
    if aggregate
      "#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{ActivityFeed.aggregate_key}:#{user_id}"
    else
      "#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{user_id}"
    end
  end
  
  def self.feed(user_id)
    ActivityFeed::Feed.new(user_id)
  end
  
  self.namespace = 'activity'
  self.key = 'feed'
  self.aggregate_key = 'aggregate'
  self.aggregate = []
  self.persistence = :memory
end
