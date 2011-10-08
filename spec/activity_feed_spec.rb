require 'spec_helper'

describe ActivityFeed do
  it 'should have defaults set for :namespace and :key' do
    ActivityFeed.namespace.should eql('activity')
    ActivityFeed.key.should eql('feed')
    ActivityFeed.persistence = :memory
    ActivityFeed.persistence.should be(ActivityFeed::Memory::Item)
  end
  
  describe 'creating' do
    it 'should allow you to create a new item using :memory' do
      user_id = 1
      ActivityFeed.persistence = :memory
      
      ActivityFeed.redis.zcard("#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{user_id}").should be(0)
      ActivityFeed.create_item(:user_id => user_id, :text => 'This is text for my activity feed')
      ActivityFeed.redis.zcard("#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{user_id}").should be(1)      
    end
    
    it 'should allow you to create a new item using :mongo_mapper' do
      user_id = 1
      ActivityFeed.persistence = :mongo_mapper
      
      ActivityFeed::MongoMapper::Item.count.should be(0)
      ActivityFeed.redis.zcard("#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{user_id}").should be(0)
      ActivityFeed.create_item(:user_id => user_id, :text => 'This is text for my activity feed')
      ActivityFeed.redis.zcard("#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{user_id}").should be(1)      
      ActivityFeed::MongoMapper::Item.count.should be(1)
    end

    it 'should allow you to create a new item using :active_record' do
      user_id = 1
      ActivityFeed.persistence = :active_record
      
      ActivityFeed::ActiveRecord::Item.count.should be(0)
      ActivityFeed.redis.zcard("#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{user_id}").should be(0)
      ActivityFeed.create_item(:user_id => user_id, :text => 'This is text for my activity feed')
      ActivityFeed.redis.zcard("#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{user_id}").should be(1)      
      ActivityFeed::ActiveRecord::Item.count.should be(1)
    end

    it 'should allow you to create a new item using :ohm' do
      user_id = 1
      ActivityFeed.persistence = :ohm
      
      ActivityFeed::Ohm::Item.all.count.should be(0)
      ActivityFeed.redis.zcard("#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{user_id}").should be(0)
      ActivityFeed.create_item(:user_id => user_id, :text => 'This is text for my activity feed')
      ActivityFeed.redis.zcard("#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{user_id}").should be(1)      
      ActivityFeed::Ohm::Item.all.count.should be(1)
    end
  end
  
  describe 'loading' do
    it 'should allow you to load an item using :memory' do
      user_id = 1
      ActivityFeed.persistence = :memory
      
      item = ActivityFeed.create_item(:user_id => user_id, :text => 'This is text for my activity feed')
      loaded_item = ActivityFeed.load_item(item.to_json)
      loaded_item.should == JSON.parse(item.to_json)
    end
    
    it 'should allow you to load an item using :mongo_mapper' do
      user_id = 1
      ActivityFeed.persistence = :mongo_mapper
      
      item = ActivityFeed.create_item(:user_id => user_id, :text => 'This is text for my activity feed')
      loaded_item = ActivityFeed.load_item(item.id)
      loaded_item.should == item
    end

    it 'should allow you to load an item using :active_record' do
      user_id = 1
      ActivityFeed.persistence = :active_record
      
      item = ActivityFeed.create_item(:user_id => user_id, :text => 'This is text for my activity feed')
      loaded_item = ActivityFeed.load_item(item.id)
      loaded_item.should == item
    end

    it 'should allow you to load an item using :ohm' do
      user_id = 1
      ActivityFeed.persistence = :ohm
      
      item = ActivityFeed.create_item(:user_id => user_id, :text => 'This is text for my activity feed')
      loaded_item = ActivityFeed.load_item(item.id)
      loaded_item.should == item
    end
  end
  
  describe 'custom persistence' do        
    it 'should allow you to define a custom persistence handler class' do
      ActivityFeed.persistence = :custom
    end
    
    it 'should allow you to create a new item using a custom persistence handler class' do
      user_id = 1
      ActivityFeed.persistence = :custom

      ActivityFeed.redis.zcard("#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{user_id}").should be(0)
      ActivityFeed.create_item(:user_id => user_id, :text => 'This is text for my activity feed')
      ActivityFeed.redis.zcard("#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{user_id}").should be(1)      
    end
    
    it 'should allow you to load an item using a custom persistence handler class' do
      user_id = 1
      ActivityFeed.persistence = :custom
      
      item = ActivityFeed.create_item(:user_id => user_id, :text => 'This is text for my activity feed')
      loaded_item = ActivityFeed.load_item(item.to_json)
      loaded_item.should == JSON.parse(item.to_json)
    end
  end
end