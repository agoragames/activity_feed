require 'spec_helper'

describe 'ActivityFeed::Item' do
  it 'should allow you to create a new Item' do
    item = Fabricate.build(ActivityFeed.persistence)
    item.save.should be_true
  end
  
  it 'should allow for a large amount of text' do
    item = Fabricate.build(ActivityFeed.persistence, :text => '*' * 8192)
    item.text.should eql('*' * 8192)
  end
  
  it 'should add the feed item ID to redis' do
    item = Fabricate.build(ActivityFeed.persistence)
          
    ActivityFeed.redis.zcard(ActivityFeed.feed_key(item.user_id)).should be(0)
    item.save
    ActivityFeed.redis.zcard(ActivityFeed.feed_key(item.user_id)).should be(1)
    ActivityFeed.aggregate_item(item)
    ActivityFeed.redis.zcard(ActivityFeed.feed_key(item.user_id, true)).should be(1)
  end
  
  it 'should have default attributes for .title .url .icon and .sticky' do
    item = Fabricate.build(ActivityFeed.persistence)
    
    item.title.should eql('item title')
    item.url.should eql('http://url')
    item.icon.should eql('http://icon')
    item.sticky.should be_false
  end
  
  it 'should not create a new item in Redis after saving, only on create' do
    item = Fabricate.build(ActivityFeed::Memory::Item)
    
    ActivityFeed.redis.zcard(ActivityFeed.feed_key(item.user_id)).should be(0)
    item.save
    ActivityFeed.redis.zcard(ActivityFeed.feed_key(item.user_id)).should be(1)
    ActivityFeed.aggregate_item(item)
    ActivityFeed.redis.zcard(ActivityFeed.feed_key(item.user_id, true)).should be(1)
    
    item.text = 'updated text'
    item.save
    ActivityFeed.redis.zcard(ActivityFeed.feed_key(item.user_id)).should be(1)
    ActivityFeed.aggregate_item(item)
    ActivityFeed.redis.zcard(ActivityFeed.feed_key(item.user_id, true)).should be(1)
  end
  
  it 'should output all the attributes for an item for Ohm' do
    item = Fabricate.build(ActivityFeed::Ohm::Item)
    
    hash = JSON.parse(item.to_json)
    hash.keys.size.should be(8)
  end
end