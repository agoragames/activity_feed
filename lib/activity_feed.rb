require 'activity_feed/version'
require 'activity_feed/feed'
require 'active_support/core_ext/module/attribute_accessors'

module ActivityFeed
  mattr_accessor :redis
  mattr_accessor :namespace
  mattr_accessor :key
  mattr_accessor :persistence
    
  def self.persistence=(type = :memory_item)
    @@persistence_type = type
    
    case type
    when :memory_item
      require 'activity_feed/memory_item'
      klazz = ActivityFeed::MemoryItem      
    when :mongo_mapper_item
      require 'activity_feed/mongo_mapper_item'
      klazz = ActivityFeed::MongoMapperItem
    else
      require 'activity_feed/memory_item'
      klazz = ActivityFeed::MemoryItem
      @@persistence_type = :memory_item
    end
    
    @@persistence = klazz
  end
  
  def self.create_item(attributes)
    item = @@persistence.new(attributes)
    item.save
    item
  end
  
  def self.load_item(item)
    case @@persistence_type
    when :memory_item
      JSON.parse(item)
    when :mongo_mapper_item
      ActivityFeed::MongoMapperItem.find(item)
    else
      item
    end
  end
  
  self.namespace = 'activity'
  self.key = 'feed'
  self.persistence = :memory_item
end
