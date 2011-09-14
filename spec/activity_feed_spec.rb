require 'spec_helper'

describe ActivityFeed do
  it 'should have defaults set for :namespace and :key' do
    ActivityFeed.namespace.should eql('activity')
    ActivityFeed.key.should eql('feed')
    ActivityFeed.persistence = :memory_item
    ActivityFeed.persistence.should be(ActivityFeed::MemoryItem)
  end
  
  describe 'creating' do
    it 'should allow you to create a new item using :memory_item' do
      user_id = 1
      ActivityFeed.persistence = :memory_item
      
      ActivityFeed.redis.zcard("#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{user_id}").should be(0)
      ActivityFeed.create_item(:user_id => user_id, :text => 'This is text for my activity feed')
      ActivityFeed.redis.zcard("#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{user_id}").should be(1)      
    end
    
    it 'should allow you to create a new item using :mongo_mapper_item' do
      user_id = 1
      ActivityFeed.persistence = :mongo_mapper_item
      
      ActivityFeed::MongoMapperItem.count.should be(0)
      ActivityFeed.redis.zcard("#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{user_id}").should be(0)
      ActivityFeed.create_item(:user_id => user_id, :text => 'This is text for my activity feed')
      ActivityFeed.redis.zcard("#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{user_id}").should be(1)      
      ActivityFeed::MongoMapperItem.count.should be(1)
    end
  end
  
  describe 'loading' do
    it 'should allow you to load an item using :memory_item' do
      user_id = 1
      ActivityFeed.persistence = :memory_item
      
      item = ActivityFeed.create_item(:user_id => user_id, :text => 'This is text for my activity feed')
      loaded_item = ActivityFeed.load_item(item)
      loaded_item.should == item
    end
    
    it 'should allow you to load an item using :mongo_mapper_item' do
      user_id = 1
      ActivityFeed.persistence = :mongo_mapper_item
      
      item = ActivityFeed.create_item(:user_id => user_id, :text => 'This is text for my activity feed')
      loaded_item = ActivityFeed.load_item(item.id)
      loaded_item.should == item      
    end
  end
end