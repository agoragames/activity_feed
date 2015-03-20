require 'spec_helper'

describe ActivityFeed::Feed do
  describe '#feed and #for' do
    describe 'without aggregation' do
      it 'should return an activity feed with the items correctly ordered' do
        feed = ActivityFeed.feed('david', 1)
        expect(feed.length).to eql(0)

        add_items_to_feed('david')

        [:feed, :for].each do |method|
          feed = ActivityFeed.send(method, 'david', 1)
          expect(feed.length).to eql(5)
          expect(feed[0].to_i).to eql(5)
          expect(feed[4].to_i).to eql(1)
        end
      end
    end

    describe 'with aggregation' do
      it 'should return an aggregate activity feed with the items correctly ordered' do
        feed = ActivityFeed.feed('david', 1, true)
        expect(feed.length).to eql(0)

        add_items_to_feed('david', 5, true)

        feed = ActivityFeed.feed('david', 1, true)
        expect(feed.length).to eql(5)
        expect(feed[0].to_i).to eql(5)
        expect(feed[4].to_i).to eql(1)
      end
    end
  end

  describe '#full_feed' do
    describe 'without aggregation' do
      it 'should return the full activity feed' do
        feed = ActivityFeed.full_feed('david', false)
        expect(feed.length).to eql(0)

        add_items_to_feed('david', 30)

        feed = ActivityFeed.full_feed('david', false)
        expect(feed.length).to eql(30)
        expect(feed[0].to_i).to eql(30)
        expect(feed[29].to_i).to eql(1)
      end
    end

    describe 'with aggregation' do
      it 'should return the full activity feed' do
        feed = ActivityFeed.full_feed('david', true)
        expect(feed.length).to eql(0)

        add_items_to_feed('david', 30, true)

        feed = ActivityFeed.full_feed('david', true)
        expect(feed.length).to eql(30)
        expect(feed[0].to_i).to eql(30)
        expect(feed[29].to_i).to eql(1)
      end
    end
  end

  describe '#feed_between_timestamps and #between' do
    describe 'without aggregation' do
      it 'should return activity feed items between the starting and ending timestamps' do
        feed = ActivityFeed.feed_between_timestamps('david', Time.local(2012, 6, 19, 4, 43, 0).to_i, Time.local(2012, 6, 19, 8, 16, 0).to_i, false)
        expect(feed.length).to eql(0)

        Timecop.travel(Time.local(2012, 6, 19, 4, 0, 0))
        ActivityFeed.update_item('david', 1, Time.now.to_i)
        Timecop.travel(Time.local(2012, 6, 19, 4, 30, 0))
        ActivityFeed.update_item('david', 2, Time.now.to_i)
        Timecop.travel(Time.local(2012, 6, 19, 5, 30, 0))
        ActivityFeed.update_item('david', 3, Time.now.to_i)
        Timecop.travel(Time.local(2012, 6, 19, 6, 37, 0))
        ActivityFeed.update_item('david', 4, Time.now.to_i)
        Timecop.travel(Time.local(2012, 6, 19, 8, 17, 0))
        ActivityFeed.update_item('david', 5, Time.now.to_i)
        Timecop.return

        [:feed_between_timestamps, :between].each do |method|
          feed = ActivityFeed.send(method, 'david', Time.local(2012, 6, 19, 4, 43, 0).to_i, Time.local(2012, 6, 19, 8, 16, 0).to_i, false)
          expect(feed.length).to eql(2)
          expect(feed[0].to_i).to eql(4)
          expect(feed[1].to_i).to eql(3)
        end
      end
    end

    describe 'with aggregation' do
      it 'should return activity feed items between the starting and ending timestamps' do
        feed = ActivityFeed.feed_between_timestamps('david', Time.local(2012, 6, 19, 4, 43, 0).to_i, Time.local(2012, 6, 19, 8, 16, 0).to_i, true)
        expect(feed.length).to eql(0)

        Timecop.travel(Time.local(2012, 6, 19, 4, 0, 0))
        ActivityFeed.update_item('david', 1, Time.now.to_i, true)
        Timecop.travel(Time.local(2012, 6, 19, 4, 30, 0))
        ActivityFeed.update_item('david', 2, Time.now.to_i, true)
        Timecop.travel(Time.local(2012, 6, 19, 5, 30, 0))
        ActivityFeed.update_item('david', 3, Time.now.to_i, true)
        Timecop.travel(Time.local(2012, 6, 19, 6, 37, 0))
        ActivityFeed.update_item('david', 4, Time.now.to_i, true)
        Timecop.travel(Time.local(2012, 6, 19, 8, 17, 0))
        ActivityFeed.update_item('david', 5, Time.now.to_i, true)
        Timecop.return

        [:feed_between_timestamps, :between].each do |method|
          feed = ActivityFeed.send(method, 'david', Time.local(2012, 6, 19, 4, 43, 0).to_i, Time.local(2012, 6, 19, 8, 16, 0).to_i, true)
          expect(feed.length).to eql(2)
          expect(feed[0].to_i).to eql(4)
          expect(feed[1].to_i).to eql(3)
        end
      end
    end
  end

  describe '#total_pages_in_feed and #total_pages' do
    describe 'without aggregation' do
      it 'should return the correct number of pages in the activity feed' do
        expect(ActivityFeed.total_pages_in_feed('david')).to eql(0)
        expect(ActivityFeed.total_pages('david')).to eql(0)

        add_items_to_feed('david', Leaderboard::DEFAULT_PAGE_SIZE + 1)

        expect(ActivityFeed.total_pages_in_feed('david')).to eql(2)
        expect(ActivityFeed.total_pages('david')).to eql(2)
      end
    end

    describe 'with aggregation' do
      it 'should return the correct number of pages in the aggregate activity feed' do
        expect(ActivityFeed.total_pages_in_feed('david', true)).to eql(0)
        expect(ActivityFeed.total_pages('david', true)).to eql(0)

        add_items_to_feed('david', Leaderboard::DEFAULT_PAGE_SIZE + 1, true)

        expect(ActivityFeed.total_pages_in_feed('david', true)).to eql(2)
        expect(ActivityFeed.total_pages('david', true)).to eql(2)
      end
    end

    describe 'changing page_size parameter' do
      it 'should return the correct number of pages in the activity feed' do
        expect(ActivityFeed.total_pages_in_feed('david', false, 4)).to eql(0)
        expect(ActivityFeed.total_pages('david', false, 4)).to eql(0)

        add_items_to_feed('david', 25)

        expect(ActivityFeed.total_pages_in_feed('david', false, 4)).to eql(7)
        expect(ActivityFeed.total_pages('david', false, 4)).to eql(7)
      end
    end
  end

  describe '#remove_feeds and #remove' do
    it 'should remove the activity feeds for a given user ID' do
      add_items_to_feed('david', Leaderboard::DEFAULT_PAGE_SIZE + 1, true)

      expect(ActivityFeed.total_items_in_feed('david')).to eql(Leaderboard::DEFAULT_PAGE_SIZE + 1)
      expect(ActivityFeed.total_items_in_feed('david', true)).to eql(Leaderboard::DEFAULT_PAGE_SIZE + 1)

      ActivityFeed.remove_feeds('david')

      expect(ActivityFeed.total_items_in_feed('david')).to eql(0)
      expect(ActivityFeed.total_items_in_feed('david', true)).to eql(0)
    end
  end

  describe '#total_items_in_feed and #total_items' do
    describe 'without aggregation' do
      it 'should return the correct number of items in the activity feed' do
        expect(ActivityFeed.total_items_in_feed('david')).to eql(0)
        expect(ActivityFeed.total_items('david')).to eql(0)

        add_items_to_feed('david', Leaderboard::DEFAULT_PAGE_SIZE + 1)

        expect(ActivityFeed.total_items_in_feed('david')).to eql(Leaderboard::DEFAULT_PAGE_SIZE + 1)
        expect(ActivityFeed.total_items('david')).to eql(Leaderboard::DEFAULT_PAGE_SIZE + 1)
      end
    end

    describe 'with aggregation' do
      it 'should return the correct number of items in the aggregate activity feed' do
        expect(ActivityFeed.total_items_in_feed('david', true)).to eql(0)
        expect(ActivityFeed.total_items('david', true)).to eql(0)

        add_items_to_feed('david', Leaderboard::DEFAULT_PAGE_SIZE + 1, true)

        expect(ActivityFeed.total_items_in_feed('david', true)).to eql(Leaderboard::DEFAULT_PAGE_SIZE + 1)
        expect(ActivityFeed.total_items('david', true)).to eql(Leaderboard::DEFAULT_PAGE_SIZE + 1)
      end
    end
  end

  describe '#trim_feed' do
    describe 'without aggregation' do
      it 'should trim activity feed items between the starting and ending timestamps' do
        [:trim_feed, :trim].each do |method|
          Timecop.travel(Time.local(2012, 6, 19, 4, 0, 0))
          ActivityFeed.update_item('david', 1, Time.now.to_i)
          Timecop.travel(Time.local(2012, 6, 19, 4, 30, 0))
          ActivityFeed.update_item('david', 2, Time.now.to_i)
          Timecop.travel(Time.local(2012, 6, 19, 5, 30, 0))
          ActivityFeed.update_item('david', 3, Time.now.to_i)
          Timecop.travel(Time.local(2012, 6, 19, 6, 37, 0))
          ActivityFeed.update_item('david', 4, Time.now.to_i)
          Timecop.travel(Time.local(2012, 6, 19, 8, 17, 0))
          ActivityFeed.update_item('david', 5, Time.now.to_i)
          Timecop.return

          ActivityFeed.send(method, 'david', Time.local(2012, 6, 19, 4, 29, 0).to_i, Time.local(2012, 6, 19, 8, 16, 0).to_i)
          feed = ActivityFeed.feed('david', 1)
          expect(feed.length).to eql(2)
          expect(feed[0].to_i).to eql(5)
          expect(feed[1].to_i).to eql(1)
        end
      end
    end

    describe 'with aggregation' do
      it 'should trim activity feed items between the starting and ending timestamps' do
        [:trim_feed, :trim].each do |method|
          Timecop.travel(Time.local(2012, 6, 19, 4, 0, 0))
          ActivityFeed.update_item('david', 1, Time.now.to_i, true)
          Timecop.travel(Time.local(2012, 6, 19, 4, 30, 0))
          ActivityFeed.update_item('david', 2, Time.now.to_i, true)
          Timecop.travel(Time.local(2012, 6, 19, 5, 30, 0))
          ActivityFeed.update_item('david', 3, Time.now.to_i, true)
          Timecop.travel(Time.local(2012, 6, 19, 6, 37, 0))
          ActivityFeed.update_item('david', 4, Time.now.to_i, true)
          Timecop.travel(Time.local(2012, 6, 19, 8, 17, 0))
          ActivityFeed.update_item('david', 5, Time.now.to_i, true)
          Timecop.return

          ActivityFeed.send(method, 'david', Time.local(2012, 6, 19, 4, 29, 0).to_i, Time.local(2012, 6, 19, 8, 16, 0).to_i, true)
          feed = ActivityFeed.feed('david', 1, true)
          expect(feed.length).to eql(2)
          expect(feed[0].to_i).to eql(5)
          expect(feed[1].to_i).to eql(1)
        end
      end
    end
  end

  describe '#trim_to_size' do
    describe 'without aggregation' do
      it 'should allow you to trim activity feed items to a given size' do
        add_items_to_feed('david')

        expect(ActivityFeed.total_items('david')).to eql(5)
        ActivityFeed.trim_to_size('david', 3)
        expect(ActivityFeed.total_items('david')).to eql(3)
      end
    end

    describe 'with aggregation' do
      it 'should allow you to trim activity feed items to a given size' do
        add_items_to_feed('david', 5, true)

        expect(ActivityFeed.total_items('david', true)).to eql(5)
        ActivityFeed.trim_to_size('david', 3, true)
        expect(ActivityFeed.total_items('david', true)).to eql(3)
      end
    end
  end

  describe 'ORM or ODM loading' do
    describe 'ActiveRecord' do
      it 'should be able to load an item via ActiveRecord when requesting a feed' do
        ActivityFeed.items_loader = Proc.new do |ids|
          ActivityFeed::ActiveRecord::Item.find(ids)
        end

        feed = ActivityFeed.feed('david', 1)
        expect(feed.length).to eql(0)

        item = ActivityFeed::ActiveRecord::Item.create(
          :user_id => 'david',
          :nickname => 'David Czarnecki',
          :type => 'some_activity',
          :title => 'Great activity',
          :body => 'This is text for the feed item'
        )

        feed = ActivityFeed.feed('david', 1)
        expect(feed.length).to eql(1)
        expect(feed[0]).to eq(item)
      end
    end

    describe 'Mongoid' do
      it 'should be able to load an item via Mongoid when requesting a feed' do
        ActivityFeed.items_loader = Proc.new do |ids|
          ActivityFeed::Mongoid::Item.find(ids)
        end

        feed = ActivityFeed.feed('david', 1)
        expect(feed.length).to eql(0)

        item = ActivityFeed::Mongoid::Item.create(
          :user_id => 'david',
          :nickname => 'David Czarnecki',
          :type => 'some_activity',
          :title => 'Great activity',
          :text => 'This is text for the feed item',
          :url => 'http://url.com'
        )

        feed = ActivityFeed.feed('david', 1)
        expect(feed.length).to eql(1)
        expect(feed[0]).to eq(item)
      end
    end
  end

  describe '#expire_feed, #expire_in and #expire_feed_in' do
    it 'should set an expiration on an activity feed using #expire_feed' do
      add_items_to_feed('david', Leaderboard::DEFAULT_PAGE_SIZE)

      ActivityFeed.expire_feed('david', 10)
      ActivityFeed.redis.ttl(ActivityFeed.feed_key('david')).tap do |ttl|
        expect(ttl).to be > 1
        expect(ttl).to be <= 10
      end
    end

    it 'should set an expiration on an activity feed using #expire_in' do
      add_items_to_feed('david', Leaderboard::DEFAULT_PAGE_SIZE)

      ActivityFeed.expire_in('david', 10)
      ActivityFeed.redis.ttl(ActivityFeed.feed_key('david')).tap do |ttl|
        expect(ttl).to be > 1
        expect(ttl).to be <= 10
      end
    end

    it 'should set an expiration on an activity feed using #expire_feed_in' do
      add_items_to_feed('david', Leaderboard::DEFAULT_PAGE_SIZE)

      ActivityFeed.expire_feed_in('david', 10)
      ActivityFeed.redis.ttl(ActivityFeed.feed_key('david')).tap do |ttl|
        expect(ttl).to be > 1
        expect(ttl).to be <= 10
      end
    end
  end

  describe '#expire_feed_at and #expire_at' do
    it 'should set an expiration timestamp on an activity feed using #expire_feed' do
      add_items_to_feed('david', Leaderboard::DEFAULT_PAGE_SIZE)

      ActivityFeed.expire_feed_at('david', (Time.now + 10).to_i)
      ActivityFeed.redis.ttl(ActivityFeed.feed_key('david')).tap do |ttl|
        expect(ttl).to be > 1
        expect(ttl).to be <= 10
      end
    end

    it 'should set an expiration timestamp on an activity feed using #expire_at' do
      add_items_to_feed('david', Leaderboard::DEFAULT_PAGE_SIZE)

      ActivityFeed.expire_at('david', (Time.now + 10).to_i)
      ActivityFeed.redis.ttl(ActivityFeed.feed_key('david')).tap do |ttl|
        expect(ttl).to be > 1
        expect(ttl).to be <= 10
      end
    end
  end
end