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
  end
end