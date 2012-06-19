require 'spec_helper'

describe ActivityFeed::Feed do
  describe '#feed' do
    describe 'without aggregation' do
      it 'should return an activity feed with the items correctly ordered' do
        add_items_to_feed('david')

        feed = ActivityFeed.feed('david', 1)
        feed.length.should == 5
        feed[0].to_i.should == 5
        feed[4].to_i.should == 1
      end
    end

    describe 'with aggregation' do
      it 'should return an aggregate activity feed with the items correctly ordered' do
        add_items_to_feed('david', 5, true)

        feed = ActivityFeed.feed('david', 1, true)
        feed.length.should == 5
        feed[0].to_i.should == 5
        feed[4].to_i.should == 1
      end
    end
  end

  describe 'ORM loading' do
    describe 'Mongoid' do
      it 'should be able to load an item via Mongoid when requesting a feed' do
        ActivityFeed.item_loading = Proc.new { |id| ActivityFeed::Mongoid::Item.find(id) }
      
        feed = ActivityFeed.feed('david', 1)
        feed.length.should == 0

        item = ActivityFeed::Mongoid::Item.create(
          :user_id => 'david', 
          :nickname => 'David Czarnecki',
          :type => 'some_activity',
          :title => 'Great activity',
          :text => 'This is text for the feed item',
          :url => 'http://url.com'
        )

        feed = ActivityFeed.feed('david', 1)
        feed.length.should == 1
        feed[0].should == item
      end
    end
  end
end