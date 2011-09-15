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
    
  def self.persistence=(type = :memory)
    @@persistence_type = type
    
    case type
    when :memory
      require 'activity_feed/memory/item'
      klazz = ActivityFeed::Memory::Item      
    when :mongo_mapper
      require 'activity_feed/mongo_mapper/item'
      klazz = ActivityFeed::MongoMapper::Item
    when :active_record
      require 'activity_feed/active_record/item'
      klazz = ActivityFeed::ActiveRecord::Item
    else
      klazz = "ActivityFeed::#{type.to_s.classify}::Item".constantize
    end
    
    @@persistence = klazz
  end
  
  def self.create_item(attributes)
    item = @@persistence.new(attributes)
    item.save
    item
  end
  
  def self.load_item(item_or_item_id)
    case @@persistence_type
    when :memory
      JSON.parse(item_or_item_id)
    when :mongo_mapper
      ActivityFeed::MongoMapper::Item.find(item_or_item_id)
    when :active_record
      ActivityFeed::ActiveRecord::Item.find(item_or_item_id)
    else
      @@persistence.find(item_or_item_id)    
    end
  end
  
  self.namespace = 'activity'
  self.key = 'feed'
  self.persistence = :memory
end
