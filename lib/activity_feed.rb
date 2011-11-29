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
    ActivityFeed.aggregate_item(item) if aggregate
    item    
  end
  
  def self.aggregate_item(item)
    case @@persistence_type
    when :active_record, :mongo_mapper, :ohm
      ActivityFeed.redis.zadd("#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{ActivityFeed.aggregate_key}:#{item.user_id}", item.created_at.to_i, item.id)
    else
      ActivityFeed.redis.zadd("#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{ActivityFeed.aggregate_key}:#{item.user_id}", DateTime.now.to_i, item.attributes.to_json)
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
  
  self.namespace = 'activity'
  self.key = 'feed'
  self.aggregate_key = 'aggregate'
  self.aggregate = true
  self.persistence = :memory
end
