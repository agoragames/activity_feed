module ActivityFeed
  module Feed
    def feed(user_id, page, aggregate = false)
      feed_items = []

      feederboard = ActivityFeed.feederboard_for(user_id, aggregate)
      feederboard.members(page).each do |feed_item|
        if ActivityFeed.item_loading
          feed_items << ActivityFeed.item_loading.call(feed_item[:member])
        else
          feed_items << feed_item[:member]
        end
      end

      feed_items
    end
  end
end