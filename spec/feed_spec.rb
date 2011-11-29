require 'spec_helper'

describe ActivityFeed::Feed do
  it 'should pull up the correct list of ActivityFeed::Memory::Item when calling #page using :memory' do    
    1.upto(5) do |index|
      item = ActivityFeed.create_item(:user_id => 1, :nickname => 'nickname_1', :text => "text_#{index}")
    end
    
    feed = ActivityFeed::Feed.new(1)
    feed.page(1).size.should be(5)
  end

  it 'should pull up the correct list of ActivityFeed::ActiveRecord::Item when calling #page using :active_record' do    
    ActivityFeed.persistence = :active_record
    ActivityFeed::ActiveRecord::Item.count.should be(0)
    1.upto(5) do |index|
      item = ActivityFeed.create_item(:user_id => 1, :nickname => 'nickname_1', :text => "text_#{index}")
    end
    ActivityFeed::ActiveRecord::Item.count.should be(5)
    
    feed = ActivityFeed::Feed.new(1)
    feed.page(1).size.should be(5)
  end

  it 'should pull up the correct list of ActivityFeed::MongoMapper::Item when calling #page using :mongo_mapper' do    
    ActivityFeed.persistence = :mongo_mapper
    ActivityFeed::MongoMapper::Item.count.should be(0)
    1.upto(5) do |index|
      item = ActivityFeed.create_item(:user_id => 1, :nickname => 'nickname_1', :text => "text_#{index}")
    end
    ActivityFeed::MongoMapper::Item.count.should be(5)
    
    feed = ActivityFeed::Feed.new(1)
    feed.page(1).size.should be(5)
  end

  it 'should pull up the correct list of ActivityFeed::Ohm::Item when calling #page using :ohm' do    
    ActivityFeed.persistence = :ohm
    ActivityFeed::Ohm::Item.all.count.should be(0)
    1.upto(5) do |index|
      item = ActivityFeed.create_item(:user_id => 1, :nickname => 'nickname_1', :text => "text_#{index}")
    end
    ActivityFeed::Ohm::Item.all.count.should be(5)
    
    feed = ActivityFeed::Feed.new(1)
    feed.page(1).size.should be(5)
  end
  
  it 'should return the correct number for #total_items' do
    1.upto(3) do |index|
      item = ActivityFeed.create_item(:user_id => 1, :nickname => 'nickname_1', :text => "text_#{index}")
    end
    
    feed = ActivityFeed::Feed.new(1)
    feed.total_items.should be(3)
  end
  
  it 'should return the correct number for #total_pages' do
    1.upto(Leaderboard::DEFAULT_PAGE_SIZE + 1) do |index|
      item = ActivityFeed.create_item(:user_id => 1, :nickname => 'nickname_1', :text => "text_#{index}")
    end
    
    feed = ActivityFeed::Feed.new(1)
    feed.total_pages.should be(2)
  end
  
  describe 'feed aggregation' do
    it 'should pull up the correct list of items from an aggregated activity feed' do
      ActivityFeed.persistence = :ohm
      1.upto(5) do |index|
        item = ActivityFeed.create_item(:user_id => 1, :nickname => 'nickname_1', :text => "text_#{index}")
        another_item = ActivityFeed.create_item(:user_id => 2, :nickname => 'nickname_2', :text => "test_another_item_#{index}")
        ActivityFeed.aggregate_item(another_item, 1)
      end
      
      feed = ActivityFeed::Feed.new(1)
      feed.total_pages(true).should be(1)
      feed.total_items(true).should be(10)
      feed.page(1, true).size.should be(10)
    end
  end
  
  describe 'custom persistence' do
    it 'should allow you to pull up the correct list of ActivityFeed::Custom::Item when calling #page using :custom' do
      ActivityFeed.persistence = :custom
      1.upto(5) do |index|
        item = ActivityFeed.create_item(:user_id => 1, :nickname => 'nickname_1', :text => "text_#{index}")
      end
      
      feed = ActivityFeed::Feed.new(1)
      feed.page(1).size.should be(5)
    end
  end
end