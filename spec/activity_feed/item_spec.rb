require 'spec_helper'
require 'active_support/core_ext/date_time/conversions'

describe ActivityFeed::Item do
  describe '#update_item' do
    describe 'without aggregation' do
      it 'should correctly build an activity feed' do
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david')).should be_false
        ActivityFeed.update_item('david', 1, DateTime.now.to_i)
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david')).should be_true
      end
    end

    describe 'with aggregation' do
      it 'should correctly build an activity feed with an aggregate activity_feed' do
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david')).should be_false
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david', true)).should be_false
        ActivityFeed.update_item('david', 1, DateTime.now.to_i, true)
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david')).should be_true
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david', true)).should be_true
      end
    end
  end

  describe '#remove_item' do
    describe 'without aggregation' do
      it 'should remove an item from an activity feed' do
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david')).should be_false
        ActivityFeed.redis.zcard(ActivityFeed.feed_key('david')).should == 0
        ActivityFeed.update_item('david', 1, DateTime.now.to_i)
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david')).should be_true
        ActivityFeed.redis.zcard(ActivityFeed.feed_key('david')).should == 1
        ActivityFeed.remove_item('david', 1)
        ActivityFeed.redis.zcard(ActivityFeed.feed_key('david')).should == 0
      end
    end

    describe 'with aggregation' do
      it 'should remove an item from an activity feed and the aggregate feed' do
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david')).should be_false
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david', true)).should be_false
        ActivityFeed.redis.zcard(ActivityFeed.feed_key('david')).should == 0
        ActivityFeed.redis.zcard(ActivityFeed.feed_key('david', true)).should == 0
        ActivityFeed.update_item('david', 1, DateTime.now.to_i, true)
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david')).should be_true
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david', true)).should be_true
        ActivityFeed.redis.zcard(ActivityFeed.feed_key('david')).should == 1
        ActivityFeed.redis.zcard(ActivityFeed.feed_key('david', true)).should == 1
        ActivityFeed.remove_item('david', 1)
        ActivityFeed.redis.zcard(ActivityFeed.feed_key('david')).should == 0
        ActivityFeed.redis.zcard(ActivityFeed.feed_key('david', true)).should == 0
      end
    end
  end
end