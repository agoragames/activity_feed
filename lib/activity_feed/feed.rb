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
    def feed(user_id, page, aggregate = false)
      feed_items = []

      feederboard = ActivityFeed.feederboard_for(user_id, aggregate)
      feederboard.members(page).each do |feed_item|
        if ActivityFeed.item_loader
          feed_items << ActivityFeed.item_loader.call(feed_item[:member])
        else
          feed_items << feed_item[:member]
        end
      end

      feed_items
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
    def feed_between_timestamps(user_id, starting_timestamp, ending_timestamp, aggregate = false)
      feed_items = []

      feederboard = ActivityFeed.feederboard_for(user_id, aggregate)
      feederboard.members_from_score_range(starting_timestamp, ending_timestamp).each do |feed_item|
        if ActivityFeed.item_loader
          feed_items << ActivityFeed.item_loader.call(feed_item[:member])
        else
          feed_items << feed_item[:member]
        end
      end

      feed_items
    end

    # Return the total number of pages in the activity feed.
    #
    # @param user_id [String] User ID.
    # @param aggregate [boolean, false] Whether to check the total number of pages in the aggregate activity feed or not.
    #
    # @return the total number of pages in the activity feed.
    def total_pages_in_feed(user_id, aggregate = false)
      ActivityFeed.feederboard_for(user_id, aggregate).total_pages
    end

    # Return the total number of items in the activity feed.
    #
    # @param user_id [String] User ID.
    # @param aggregate [boolean, false] Whether to check the total number of items in the aggregate activity feed or not.
    #
    # @return the total number of items in the activity feed.
    def total_items_in_feed(user_id, aggregate = false)
      ActivityFeed.feederboard_for(user_id, aggregate).total_members
    end

    # Remove the activity feeds for a given +user_id+.
    #
    # @param user_id [String] User ID.
    def remove_feeds(user_id)
      ActivityFeed.redis.multi do |transaction|
        transaction.del(ActivityFeed.feed_key(user_id))
        transaction.del(ActivityFeed.feed_key(user_id, true))
      end
    end
  end
end