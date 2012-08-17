module ActivityFeed
  module Feed
    # Retrieve a page from the activity feed for a given +user_id+. You can configure
    # +ActivityFeed.item_loader+ with a Proc to retrieve an item from, for example,
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
      feed = feederboard.leaders(page, :page_size => ActivityFeed.page_size).inject([]) do |feed_items, feed_item|
        item = if ActivityFeed.item_loader
          ActivityFeed.item_loader.call(feed_item[:member])
        else
          feed_item[:member]
        end

        feed_items << item unless item.nil?
        feed_items
      end

      feed.nil? ? [] : feed
    end

    # Retrieve the entire activity feed for a given +user_id+. You can configure
    # +ActivityFeed.item_loader+ with a Proc to retrieve an item from, for example,
    # your ORM (e.g. ActiveRecord) or your ODM (e.g. Mongoid), and have the page
    # returned with loaded items rather than item IDs.
    #
    # @param user_id [String] User ID.
    # @param aggregate [boolean, false] Whether to retrieve the aggregate feed for +user_id+.
    #
    # @return the full activity feed for a given +user_id+.
    def full_feed(user_id, aggregate = ActivityFeed.aggregate)
      feederboard = ActivityFeed.feederboard_for(user_id, aggregate)
      feed = feederboard.leaders(1, :page_size => feederboard.total_members).inject([]) do |feed_items, feed_item|
        item = if ActivityFeed.item_loader
          ActivityFeed.item_loader.call(feed_item[:member])
        else
          feed_item[:member]
        end

        feed_items << item unless item.nil?
        feed_items
      end

      feed.nil? ? [] : feed
    end

    # Retrieve a page from the activity feed for a given +user_id+ between a
    # +starting_timestamp+ and an +ending_timestamp+. You can configure
    # +ActivityFeed.item_loader+ with a Proc to retrieve an item from, for example,
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
      feed = feederboard.members_from_score_range(starting_timestamp, ending_timestamp).inject([]) do |feed_items, feed_item|
        item = if ActivityFeed.item_loader
          ActivityFeed.item_loader.call(feed_item[:member])
        else
          feed_item[:member]
        end

        feed_items << item unless item.nil?
        feed_items
      end

      feed.nil? ? [] : feed
    end

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

    # Return the total number of items in the activity feed.
    #
    # @param user_id [String] User ID.
    # @param aggregate [boolean, false] Whether to check the total number of items in the aggregate activity feed or not.
    #
    # @return the total number of items in the activity feed.
    def total_items_in_feed(user_id, aggregate = ActivityFeed.aggregate)
      ActivityFeed.feederboard_for(user_id, aggregate).total_members
    end

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

    # Expire an activity feed after a set number of seconds.
    #
    # @param user_id [String] User ID.
    # @param seconds [int] Number of seconds after which the activity feed will be expired.
    # @param aggregate [boolean, false] Whether or not to expire the aggregate activity feed or not.
    def expire_feed(user_id, seconds, aggregate = ActivityFeed.aggregate)
      ActivityFeed.redis.expire(ActivityFeed.feed_key(user_id, aggregate), seconds)
    end

    # Expire an activity feed at a given timestamp.
    #
    # @param user_id [String] User ID.
    # @param timestamp [int] Timestamp after which the activity feed will be expired.
    # @param aggregate [boolean, false] Whether or not to expire the aggregate activity feed or not.
    def expire_feed_at(user_id, timestamp, aggregate = ActivityFeed.aggregate)
      ActivityFeed.redis.expireat(ActivityFeed.feed_key(user_id, aggregate), timestamp)
    end
  end
end