require 'spec_helper'

describe ActivityFeed::Feed do
  describe '#feed' do
    describe 'without aggregation' do
      it 'should return an activity feed with the items correctly ordered' do
        add_items_to_feed('david')

        feed = ActivityFeed.feed('david', 1)
        feed.length.should eql(5)
        feed[0].to_i.should eql(5)
        feed[4].to_i.should eql(1)
      end
    end

    describe 'with aggregation' do
      it 'should return an aggregate activity feed with the items correctly ordered' do
        add_items_to_feed('david', 5, true)

        feed = ActivityFeed.feed('david', 1, true)
        feed.length.should eql(5)
        feed[0].to_i.should eql(5)
        feed[4].to_i.should eql(1)
      end
    end
  end

  describe '#full_feed' do
    describe 'without aggregation' do
      it 'should return the full activity feed' do
        add_items_to_feed('david', 30)

        feed = ActivityFeed.full_feed('david', false)
        feed.length.should eql(30)
        feed[0].to_i.should eql(30)
        feed[29].to_i.should eql(1)
      end
    end

    describe 'with aggregation' do
      it 'should return the full activity feed' do
        add_items_to_feed('david', 30, true)

        feed = ActivityFeed.full_feed('david', true)
        feed.length.should eql(30)
        feed[0].to_i.should eql(30)
        feed[29].to_i.should eql(1)
      end
    end
  end

  describe '#feed_between_timestamps' do
    describe 'without aggregation' do
      it 'should return activity feed items between the starting and ending timestamps' do
        Timecop.travel(Time.local(2012, 6, 19, 4, 0, 0))
        ActivityFeed.update_item('david', 1, DateTime.now.to_i)
        Timecop.travel(Time.local(2012, 6, 19, 4, 30, 0))
        ActivityFeed.update_item('david', 2, DateTime.now.to_i)
        Timecop.travel(Time.local(2012, 6, 19, 5, 30, 0))
        ActivityFeed.update_item('david', 3, DateTime.now.to_i)
        Timecop.travel(Time.local(2012, 6, 19, 6, 37, 0))
        ActivityFeed.update_item('david', 4, DateTime.now.to_i)
        Timecop.travel(Time.local(2012, 6, 19, 8, 17, 0))
        ActivityFeed.update_item('david', 5, DateTime.now.to_i)
        Timecop.return

        feed = ActivityFeed.feed_between_timestamps('david', Time.local(2012, 6, 19, 4, 43, 0).to_i, Time.local(2012, 6, 19, 8, 16, 0).to_i)
        feed.length.should eql(2)
        feed[0].to_i.should eql(4)
        feed[1].to_i.should eql(3)
      end
    end

    describe 'with aggregation' do
      it 'should return activity feed items between the starting and ending timestamps' do
        Timecop.travel(Time.local(2012, 6, 19, 4, 0, 0))
        ActivityFeed.update_item('david', 1, DateTime.now.to_i, true)
        Timecop.travel(Time.local(2012, 6, 19, 4, 30, 0))
        ActivityFeed.update_item('david', 2, DateTime.now.to_i, true)
        Timecop.travel(Time.local(2012, 6, 19, 5, 30, 0))
        ActivityFeed.update_item('david', 3, DateTime.now.to_i, true)
        Timecop.travel(Time.local(2012, 6, 19, 6, 37, 0))
        ActivityFeed.update_item('david', 4, DateTime.now.to_i, true)
        Timecop.travel(Time.local(2012, 6, 19, 8, 17, 0))
        ActivityFeed.update_item('david', 5, DateTime.now.to_i, true)
        Timecop.return

        feed = ActivityFeed.feed_between_timestamps('david', Time.local(2012, 6, 19, 4, 43, 0).to_i, Time.local(2012, 6, 19, 8, 16, 0).to_i, true)
        feed.length.should eql(2)
        feed[0].to_i.should eql(4)
        feed[1].to_i.should eql(3)
      end
    end
  end

  describe '#total_pages_in_feed and #total_pages' do
    describe 'without aggregation' do
      it 'should return the correct number of pages in the activity feed' do
        add_items_to_feed('david', Leaderboard::DEFAULT_PAGE_SIZE + 1)

        ActivityFeed.total_pages_in_feed('david').should eql(2)
        ActivityFeed.total_pages('david').should eql(2)
      end
    end

    describe 'with aggregation' do
      it 'should return the correct number of pages in the aggregate activity feed' do
        add_items_to_feed('david', Leaderboard::DEFAULT_PAGE_SIZE + 1, true)

        ActivityFeed.total_pages_in_feed('david', true).should eql(2)
        ActivityFeed.total_pages('david', true).should eql(2)
      end
    end

    describe 'changing page_size parameter' do
      it 'should return the correct number of pages in the activity feed' do
        add_items_to_feed('david', 25)

        ActivityFeed.total_pages_in_feed('david', false, 4).should eql(7)
        ActivityFeed.total_pages('david', false, 4).should eql(7)
      end
    end
  end

  describe '#remove_feeds' do
    it 'should remove the activity feeds for a given user ID' do
      add_items_to_feed('david', Leaderboard::DEFAULT_PAGE_SIZE + 1, true)

      ActivityFeed.total_items_in_feed('david').should eql(Leaderboard::DEFAULT_PAGE_SIZE + 1)
      ActivityFeed.total_items_in_feed('david', true).should eql(Leaderboard::DEFAULT_PAGE_SIZE + 1)

      ActivityFeed.remove_feeds('david')

      ActivityFeed.total_items_in_feed('david').should eql(0)
      ActivityFeed.total_items_in_feed('david', true).should eql(0)
    end
  end

  describe '#total_items_in_feed and #total_items' do
    describe 'without aggregation' do
      it 'should return the correct number of items in the activity feed' do
        add_items_to_feed('david', Leaderboard::DEFAULT_PAGE_SIZE + 1)

        ActivityFeed.total_items_in_feed('david').should eql(Leaderboard::DEFAULT_PAGE_SIZE + 1)
        ActivityFeed.total_items('david').should eql(Leaderboard::DEFAULT_PAGE_SIZE + 1)
      end
    end

    describe 'with aggregation' do
      it 'should return the correct number of items in the aggregate activity feed' do
        add_items_to_feed('david', Leaderboard::DEFAULT_PAGE_SIZE + 1, true)

        ActivityFeed.total_items_in_feed('david', true).should eql(Leaderboard::DEFAULT_PAGE_SIZE + 1)
        ActivityFeed.total_items('david', true).should eql(Leaderboard::DEFAULT_PAGE_SIZE + 1)
      end
    end
  end

  describe '#trim_feed' do
    describe 'without aggregation' do
      it 'should trim activity feed items between the starting and ending timestamps' do
        Timecop.travel(Time.local(2012, 6, 19, 4, 0, 0))
        ActivityFeed.update_item('david', 1, DateTime.now.to_i)
        Timecop.travel(Time.local(2012, 6, 19, 4, 30, 0))
        ActivityFeed.update_item('david', 2, DateTime.now.to_i)
        Timecop.travel(Time.local(2012, 6, 19, 5, 30, 0))
        ActivityFeed.update_item('david', 3, DateTime.now.to_i)
        Timecop.travel(Time.local(2012, 6, 19, 6, 37, 0))
        ActivityFeed.update_item('david', 4, DateTime.now.to_i)
        Timecop.travel(Time.local(2012, 6, 19, 8, 17, 0))
        ActivityFeed.update_item('david', 5, DateTime.now.to_i)
        Timecop.return

        ActivityFeed.trim_feed('david', Time.local(2012, 6, 19, 4, 29, 0).to_i, Time.local(2012, 6, 19, 8, 16, 0).to_i)
        feed = ActivityFeed.feed('david', 1)
        feed.length.should eql(2)
        feed[0].to_i.should eql(5)
        feed[1].to_i.should eql(1)
      end
    end

    describe 'with aggregation' do
      it 'should trim activity feed items between the starting and ending timestamps' do
        Timecop.travel(Time.local(2012, 6, 19, 4, 0, 0))
        ActivityFeed.update_item('david', 1, DateTime.now.to_i, true)
        Timecop.travel(Time.local(2012, 6, 19, 4, 30, 0))
        ActivityFeed.update_item('david', 2, DateTime.now.to_i, true)
        Timecop.travel(Time.local(2012, 6, 19, 5, 30, 0))
        ActivityFeed.update_item('david', 3, DateTime.now.to_i, true)
        Timecop.travel(Time.local(2012, 6, 19, 6, 37, 0))
        ActivityFeed.update_item('david', 4, DateTime.now.to_i, true)
        Timecop.travel(Time.local(2012, 6, 19, 8, 17, 0))
        ActivityFeed.update_item('david', 5, DateTime.now.to_i, true)
        Timecop.return

        ActivityFeed.trim_feed('david', Time.local(2012, 6, 19, 4, 29, 0).to_i, Time.local(2012, 6, 19, 8, 16, 0).to_i, true)
        feed = ActivityFeed.feed('david', 1, true)
        feed.length.should eql(2)
        feed[0].to_i.should eql(5)
        feed[1].to_i.should eql(1)
      end
    end
  end

  describe 'ORM or ODM loading' do
    describe 'ActiveRecord' do
      it 'should be able to load an item via ActiveRecord when requesting a feed' do
        ActivityFeed.item_loader = Proc.new do |id|
          ActivityFeed::ActiveRecord::Item.find(id)
        end

        feed = ActivityFeed.feed('david', 1)
        feed.length.should eql(0)

        item = ActivityFeed::ActiveRecord::Item.create(
          :user_id => 'david',
          :nickname => 'David Czarnecki',
          :type => 'some_activity',
          :title => 'Great activity',
          :body => 'This is text for the feed item'
        )

        feed = ActivityFeed.feed('david', 1)
        feed.length.should eql(1)
        feed[0].should == item
      end
    end

    describe 'Mongoid' do
      it 'should be able to load an item via Mongoid when requesting a feed' do
        ActivityFeed.item_loader = Proc.new { |id| ActivityFeed::Mongoid::Item.find(id) }

        feed = ActivityFeed.feed('david', 1)
        feed.length.should eql(0)

        item = ActivityFeed::Mongoid::Item.create(
          :user_id => 'david',
          :nickname => 'David Czarnecki',
          :type => 'some_activity',
          :title => 'Great activity',
          :text => 'This is text for the feed item',
          :url => 'http://url.com'
        )

        feed = ActivityFeed.feed('david', 1)
        feed.length.should eql(1)
        feed[0].should == item
      end
    end
  end

  describe '#expire_feed' do
    it 'should set an expiration on an activity feed' do
      add_items_to_feed('david', Leaderboard::DEFAULT_PAGE_SIZE)

      ActivityFeed.expire_feed('david', 10)
      ActivityFeed.redis.ttl(ActivityFeed.feed_key('david')).tap do |ttl|
        ttl.should be > 1
        ttl.should be <= 10
      end
    end
  end

  describe '#expire_feed_at' do
    it 'should set an expiration timestamp on an activity feed' do
      add_items_to_feed('david', Leaderboard::DEFAULT_PAGE_SIZE)

      ActivityFeed.expire_feed_at('david', (Time.now + 10).to_i)
      ActivityFeed.redis.ttl(ActivityFeed.feed_key('david')).tap do |ttl|
        ttl.should be > 1
        ttl.should be <= 10
      end
    end
  end
end