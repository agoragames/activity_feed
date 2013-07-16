module ActivityFeed
  module Feed
    # Retrieve a page from the activity feed for a given +user_id+. You can configure
    # +ActivityFeed.items_loader+ with a Proc to retrieve items from, for example,
    # your ORM (e.g. ActiveRecord) or your ODM (e.g. Mongoid), and have the page
    # returned with loaded items rather than item IDs.
    #
    # @param user_id [String] User ID.
    # @param page [int] Page in the feed to be retrieved.
    # @param aggregate [boolean, false] Whether to retrieve the aggregate feed for +user_id+.
    #
    # @return page from the activity feed for a given +user_id+.
    def feed(user_id, page, aggregate = ActivityFeed.aggregate)
      feederboard = ActivityFeed.feederboard_for(user_id, aggregate)
      feed_items = feederboard.leaders(page, :page_size => ActivityFeed.page_size)
      load_feed_items(feed_items)
    end

    alias_method :for, :feed

    # Retrieve the entire activity feed for a given +user_id+. You can configure
    # +ActivityFeed.items_loader+ with a Proc to retrieve items from, for example,
    # your ORM (e.g. ActiveRecord) or your ODM (e.g. Mongoid), and have the page
    # returned with loaded items rather than item IDs.
    #
    # @param user_id [String] User ID.
    # @param aggregate [boolean, false] Whether to retrieve the aggregate feed for +user_id+.
    #
    # @return the full activity feed for a given +user_id+.
    def full_feed(user_id, aggregate = ActivityFeed.aggregate)
      feederboard = ActivityFeed.feederboard_for(user_id, aggregate)
      feed_items = feederboard.leaders(1, :page_size => feederboard.total_members)
      load_feed_items(feed_items)
    end

    # Retrieve a page from the activity feed for a given +user_id+ between a
    # +starting_timestamp+ and an +ending_timestamp+. You can configure
    # +ActivityFeed.items_loader+ with a Proc to retrieve items from, for example,
    # your ORM (e.g. ActiveRecord) or your ODM (e.g. Mongoid), and have the feed data
    # returned with loaded items rather than item IDs.
    #
    # @param user_id [String] User ID.
    # @param starting_timestamp [int] Starting timestamp between which items in the feed are to be retrieved.
    # @param ending_timestamp [int] Ending timestamp between which items in the feed are to be retrieved.
    # @param aggregate [boolean, false] Whether to retrieve items from the aggregate feed for +user_id+.
    #
    # @return feed items from the activity feed for a given +user_id+ between the +starting_timestamp+ and +ending_timestamp+.
    def feed_between_timestamps(user_id, starting_timestamp, ending_timestamp, aggregate = ActivityFeed.aggregate)
      feederboard = ActivityFeed.feederboard_for(user_id, aggregate)
      feed_items = feederboard.members_from_score_range(starting_timestamp, ending_timestamp)
      load_feed_items(feed_items)
    end

    alias_method :between, :feed_between_timestamps

    # Return the total number of pages in the activity feed.
    #
    # @param user_id [String] User ID.
    # @param aggregate [boolean, false] Whether to check the total number of pages in the aggregate activity feed or not.
    # @param page_size [int, ActivityFeed.page_size] Page size to be used in calculating the total number of pages in the activity feed.
    #
    # @return the total number of pages in the activity feed.
    def total_pages_in_feed(user_id, aggregate = ActivityFeed.aggregate, page_size = ActivityFeed.page_size)
      ActivityFeed.feederboard_for(user_id, aggregate).total_pages_in(ActivityFeed.feed_key(user_id, aggregate), page_size)
    end

    alias_method :total_pages, :total_pages_in_feed

    # Return the total number of items in the activity feed.
    #
    # @param user_id [String] User ID.
    # @param aggregate [boolean, false] Whether to check the total number of items in the aggregate activity feed or not.
    #
    # @return the total number of items in the activity feed.
    def total_items_in_feed(user_id, aggregate = ActivityFeed.aggregate)
      ActivityFeed.feederboard_for(user_id, aggregate).total_members
    end

    alias_method :total_items, :total_items_in_feed

    # Remove the activity feeds for a given +user_id+.
    #
    # @param user_id [String] User ID.
    def remove_feeds(user_id)
      ActivityFeed.redis.multi do |transaction|
        transaction.del(ActivityFeed.feed_key(user_id, false))
        transaction.del(ActivityFeed.feed_key(user_id, true))
      end
    end

    # Trim an activity feed between two timestamps.
    #
    # @param user_id [String] User ID.
    # @param starting_timestamp [int] Starting timestamp after which activity feed items will be cut.
    # @param ending_timestamp [int] Ending timestamp before which activity feed items will be cut.
    # @param aggregate [boolean, false] Whether or not to trim the aggregate activity feed or not.
    def trim_feed(user_id, starting_timestamp, ending_timestamp, aggregate = ActivityFeed.aggregate)
      ActivityFeed.feederboard_for(user_id, aggregate).remove_members_in_score_range(starting_timestamp, ending_timestamp)
    end

    alias_method :trim, :trim_feed

    # Expire an activity feed after a set number of seconds.
    #
    # @param user_id [String] User ID.
    # @param seconds [int] Number of seconds after which the activity feed will be expired.
    # @param aggregate [boolean, false] Whether or not to expire the aggregate activity feed or not.
    def expire_feed(user_id, seconds, aggregate = ActivityFeed.aggregate)
      ActivityFeed.redis.expire(ActivityFeed.feed_key(user_id, aggregate), seconds)
    end

    alias_method :expire_in, :expire_feed
    alias_method :expire_feed_in, :expire_feed

    # Expire an activity feed at a given timestamp.
    #
    # @param user_id [String] User ID.
    # @param timestamp [int] Timestamp after which the activity feed will be expired.
    # @param aggregate [boolean, false] Whether or not to expire the aggregate activity feed or not.
    def expire_feed_at(user_id, timestamp, aggregate = ActivityFeed.aggregate)
      ActivityFeed.redis.expireat(ActivityFeed.feed_key(user_id, aggregate), timestamp)
    end

    alias_method :expire_at, :expire_feed_at

    private

    # Load feed items from the `ActivityFeed.items_loader` if available,
    # otherwise return the individual members from the feed items.
    #
    # @param feed_items [Array] Array of hash feed items as `[{:member=>"5", :rank=>1, :score=>1373564960.0}, ...]`
    #
    # @return Array of feed items
    def load_feed_items(feed_items)
      feed_item_ids = feed_items.collect { |feed_item| feed_item[:member] }
      if ActivityFeed.items_loader
        ActivityFeed.items_loader.call(feed_item_ids)
      else
        feed_item_ids
      end
    end
  end
end