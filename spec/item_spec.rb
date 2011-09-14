require 'spec_helper'

describe ActivityFeed::Item do
  it 'should allow you to create a new Item' do
    item = Fabricate.build(ActivityFeed::Item)
    item.save.should be_true
  end
  
  it 'should allow for a large amount of text' do
    item = Fabricate.build(ActivityFeed::Item, :text => '*' * 8192)
    item.text.should eql('*' * 8192)
  end
  
  it 'should add the feed item ID to redis' do
    item = Fabricate.build(ActivityFeed::Item)
          
    ActivityFeed.redis.zcard("#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{item.user_id}").should be(0)
    item.save
    ActivityFeed.redis.zcard("#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{item.user_id}").should be(1)
  end
  
  it 'should have default attributes for .title .url .icon and .sticky' do
    item = Fabricate.build(ActivityFeed::Item)
    
    item.title.should eql('item title')
    item.url.should eql('http://url')
    item.icon.should eql('http://icon')
    item.sticky.should be_false
  end
  
  it 'should not create a new item in Redis after saving, only on create' do
    item = Fabricate.build(ActivityFeed::Item)
    
    ActivityFeed.redis.zcard("#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{item.user_id}").should be(0)
    item.save
    ActivityFeed.redis.zcard("#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{item.user_id}").should be(1)
    
    item.text = 'updated text'
    item.save
    ActivityFeed.redis.zcard("#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{item.user_id}").should be(1)
  end
end