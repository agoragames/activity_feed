require 'spec_helper'

describe ActivityFeed do
  it 'should have defaults set' do
    ActivityFeed.namespace.should eql('activity')
    ActivityFeed.key.should eql('feed')
    ActivityFeed.persistence = :memory
    ActivityFeed.persistence.should be(ActivityFeed::Memory::Item)
    ActivityFeed.aggregate_key.should eql('aggregate')
    ActivityFeed.aggregate.should == []
  end
  
  describe 'creating' do
    it 'should allow you to create a new item using :memory' do
      user_id = 1
      ActivityFeed.persistence = :memory
      
      ActivityFeed.redis.zcard(ActivityFeed.feed_key(user_id)).should be(0)
      activity_feed_item = ActivityFeed.create_item(:user_id => user_id, :text => 'This is text for my activity feed')
      ActivityFeed.redis.zcard(ActivityFeed.feed_key(user_id)).should be(1)
      ActivityFeed.redis.zcard(ActivityFeed.feed_key(user_id, true)).should be(1)      
    end
    
    it 'should allow you to create a new item using :mongo_mapper' do
      user_id = 1
      ActivityFeed.persistence = :mongo_mapper
      
      ActivityFeed::MongoMapper::Item.count.should be(0)
      ActivityFeed.redis.zcard(ActivityFeed.feed_key(user_id)).should be(0)
      activity_feed_item = ActivityFeed.create_item(:user_id => user_id, :text => 'This is text for my activity feed')
      ActivityFeed.redis.zcard(ActivityFeed.feed_key(user_id)).should be(1)      
      ActivityFeed.redis.zcard(ActivityFeed.feed_key(user_id, true)).should be(1)      
      ActivityFeed::MongoMapper::Item.count.should be(1)
    end

    it 'should allow you to create a new item using :active_record' do
      user_id = 1
      ActivityFeed.persistence = :active_record
      
      ActivityFeed::ActiveRecord::Item.count.should be(0)
      ActivityFeed.redis.zcard(ActivityFeed.feed_key(user_id)).should be(0)
      activity_feed_item = ActivityFeed.create_item(:user_id => user_id, :text => 'This is text for my activity feed')
      ActivityFeed.redis.zcard(ActivityFeed.feed_key(user_id)).should be(1)      
      ActivityFeed.redis.zcard(ActivityFeed.feed_key(user_id, true)).should be(1)      
      ActivityFeed::ActiveRecord::Item.count.should be(1)
    end

    it 'should allow you to create a new item using :ohm' do
      user_id = 1
      ActivityFeed.persistence = :ohm
      
      ActivityFeed::Ohm::Item.all.count.should be(0)
      ActivityFeed.redis.zcard(ActivityFeed.feed_key(user_id)).should be(0)
      activity_feed_item = ActivityFeed.create_item(:user_id => user_id, :text => 'This is text for my activity feed')
      ActivityFeed.redis.zcard(ActivityFeed.feed_key(user_id)).should be(1)      
      ActivityFeed.redis.zcard(ActivityFeed.feed_key(user_id, true)).should be(1)      
      ActivityFeed::Ohm::Item.all.count.should be(1)
    end

    it 'should allow you to create a new item and not aggregate the item' do
      user_id = 1
      ActivityFeed.persistence = :ohm
      
      ActivityFeed::Ohm::Item.all.count.should be(0)
      ActivityFeed.redis.zcard(ActivityFeed.feed_key(user_id)).should be(0)
      activity_feed_item = ActivityFeed.create_item({:user_id => user_id, :text => 'This is text for my activity feed'}, false)
      ActivityFeed.redis.zcard(ActivityFeed.feed_key(user_id)).should be(1)
      ActivityFeed.redis.zcard(ActivityFeed.feed_key(user_id, true)).should be(0)
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

      ActivityFeed.redis.zcard(ActivityFeed.feed_key(user_id)).should be(0)
      activity_feed_item = ActivityFeed.create_item(:user_id => user_id, :text => 'This is text for my activity feed')
      ActivityFeed.redis.zcard(ActivityFeed.feed_key(user_id)).should be(1)      
      ActivityFeed.aggregate_item(activity_feed_item)
      ActivityFeed.redis.zcard(ActivityFeed.feed_key(user_id, true)).should be(1)      
    end
    
    it 'should allow you to load an item using a custom persistence handler class' do
      user_id = 1
      ActivityFeed.persistence = :custom
      
      item = ActivityFeed.create_item(:user_id => user_id, :text => 'This is text for my activity feed')
      loaded_item = ActivityFeed.load_item(item.to_json)
      loaded_item.should == JSON.parse(item.to_json)
    end
  end
  
  describe 'feed' do
    it 'should allow you to create a new ActivityFeed::Feed instance' do
      user_id = 1
      ActivityFeed.persistence = :ohm
      
      item = ActivityFeed.create_item(:user_id => user_id, :text => 'This is text for my activity feed')
      feed = ActivityFeed.feed(user_id)
      
      feed.total_items.should be(1)
    end
  end

  describe ".create_item" do
    let(:user_id) { 1 }
    let(:friend_ids) { [99, 1337] }
    let(:item_attrs) {
      { "user_id" => user_id, "text" => 'This is my happy activity' }
    }
    
    context "with no explicit aggregation set" do
      it "just creates the item and saves it to the user's feed" do
        ActivityFeed.create_item(item_attrs)
        ActivityFeed.redis.zcard(ActivityFeed.feed_key(user_id)).should be(1)
        feed = ActivityFeed::Feed.new(user_id)
        feed.page(1).first.should == item_attrs
      end
    end
    
    context "with the optional second parameter set to a falsy value" do
      it "only creates the item--without adding it to the aggregation feed" do
        ActivityFeed.create_item(item_attrs, false)
        feed = ActivityFeed::Feed.new(user_id)
        feed.page(1).size.should be(1) # user-only feed
        feed.page(1, true).should be_empty # aggregation feed
      end
    end
    
    context "with a list of aggregation ids as a second parameter" do
      it "creates the item and aggregates it out to all the feeds" do
        ActivityFeed.create_item(item_attrs, friend_ids)
        ( friend_ids << user_id ).each do |id|
          feed = ActivityFeed::Feed.new(id)
          feed.page(1, true).first.should == item_attrs
        end
      end
    end
    
  end
end