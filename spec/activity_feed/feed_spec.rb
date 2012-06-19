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
end