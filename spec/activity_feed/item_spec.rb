require 'spec_helper'
require 'active_support/core_ext/date_time/conversions'

describe ActivityFeed::Item do
  describe '#update_item' do
    describe 'without aggregation' do
      it 'should correctly build an activity feed' do
        expect(ActivityFeed.redis.exists(ActivityFeed.feed_key('david'))).to be_falsey
        ActivityFeed.update_item('david', 1, Time.now.to_i)
        expect(ActivityFeed.redis.exists(ActivityFeed.feed_key('david'))).to be_truthy
      end
    end

    describe 'with aggregation' do
      it 'should correctly build an activity feed with an aggregate activity_feed' do
        expect(ActivityFeed.redis.exists(ActivityFeed.feed_key('david'))).to be_falsey
        expect(ActivityFeed.redis.exists(ActivityFeed.feed_key('david', true))).to be_falsey
        ActivityFeed.update_item('david', 1, Time.now.to_i, true)
        expect(ActivityFeed.redis.exists(ActivityFeed.feed_key('david'))).to be_truthy
        expect(ActivityFeed.redis.exists(ActivityFeed.feed_key('david', true))).to be_truthy
      end
    end
  end

  describe '#add_item' do
    describe 'without aggregation' do
      it 'should correctly build an activity feed' do
        expect(ActivityFeed.redis.exists(ActivityFeed.feed_key('david'))).to be_falsey
        ActivityFeed.add_item('david', 1, Time.now.to_i)
        expect(ActivityFeed.redis.exists(ActivityFeed.feed_key('david'))).to be_truthy
      end
    end
  end

  describe '#aggregate_item' do
    it 'should correctly add an item into an aggregate activity feed' do
      expect(ActivityFeed.redis.exists(ActivityFeed.feed_key('david'))).to be_falsey
      expect(ActivityFeed.redis.exists(ActivityFeed.feed_key('david', true))).to be_falsey
      ActivityFeed.aggregate_item('david', 1, Time.now.to_i)
      expect(ActivityFeed.redis.exists(ActivityFeed.feed_key('david'))).to be_falsey
      expect(ActivityFeed.redis.exists(ActivityFeed.feed_key('david', true))).to be_truthy
    end
  end

  describe '#remove_item' do
    describe 'without aggregation' do
      it 'should remove an item from an activity feed' do
        expect(ActivityFeed.redis.exists(ActivityFeed.feed_key('david'))).to be_falsey
        expect(ActivityFeed.redis.zcard(ActivityFeed.feed_key('david'))).to eql(0)
        ActivityFeed.update_item('david', 1, Time.now.to_i)
        expect(ActivityFeed.redis.exists(ActivityFeed.feed_key('david'))).to be_truthy
        expect(ActivityFeed.redis.zcard(ActivityFeed.feed_key('david'))).to eql(1)
        ActivityFeed.remove_item('david', 1)
        expect(ActivityFeed.redis.zcard(ActivityFeed.feed_key('david'))).to eql(0)
      end
    end

    describe 'with aggregation' do
      it 'should remove an item from an activity feed and the aggregate feed' do
        expect(ActivityFeed.redis.exists(ActivityFeed.feed_key('david'))).to be_falsey
        expect(ActivityFeed.redis.exists(ActivityFeed.feed_key('david', true))).to be_falsey
        expect(ActivityFeed.redis.zcard(ActivityFeed.feed_key('david'))).to eql(0)
        expect(ActivityFeed.redis.zcard(ActivityFeed.feed_key('david', true))).to eql(0)
        ActivityFeed.update_item('david', 1, Time.now.to_i, true)
        expect(ActivityFeed.redis.exists(ActivityFeed.feed_key('david'))).to be_truthy
        expect(ActivityFeed.redis.exists(ActivityFeed.feed_key('david', true))).to be_truthy
        expect(ActivityFeed.redis.zcard(ActivityFeed.feed_key('david'))).to eql(1)
        expect(ActivityFeed.redis.zcard(ActivityFeed.feed_key('david', true))).to eql(1)
        ActivityFeed.remove_item('david', 1)
        expect(ActivityFeed.redis.zcard(ActivityFeed.feed_key('david'))).to eql(0)
        expect(ActivityFeed.redis.zcard(ActivityFeed.feed_key('david', true))).to eql(0)
      end
    end
  end

  describe '#check_item?' do
    describe 'without aggregation' do
      it 'should return whether or not an item exists in the feed' do
        ActivityFeed.aggregate = false
        expect(ActivityFeed.check_item?('david', 1)).to be_falsey
        ActivityFeed.add_item('david', 1, Time.now.to_i)
        expect(ActivityFeed.check_item?('david', 1)).to be_truthy
      end
    end

    describe 'with aggregation' do
      it 'should return whether or not an item exists in the feed' do
        ActivityFeed.aggregate = true
        expect(ActivityFeed.check_item?('david', 1, true)).to be_falsey
        ActivityFeed.add_item('david', 1, Time.now.to_i)
        expect(ActivityFeed.check_item?('david', 1, true)).to be_truthy
      end
    end
  end
end