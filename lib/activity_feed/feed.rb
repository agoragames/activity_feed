require 'leaderboard'

module ActivityFeed
  class Feed
    def initialize(user_id)
      @feederboard = Leaderboard.new(ActivityFeed.feed_key(user_id), Leaderboard::DEFAULT_OPTIONS, {:redis_connection => ActivityFeed.redis})
      @feederboard_aggregate = Leaderboard.new(ActivityFeed.feed_key(user_id, true), Leaderboard::DEFAULT_OPTIONS, {:redis_connection => ActivityFeed.redis})
    end
    
    def page(page, aggregate = false)
      feed_items = []
      
      feed = aggregate ? @feederboard_aggregate : @feederboard
      feed.leaders(page).each do |feed_item|
        feed_items << ActivityFeed.load_item(feed_item[:member])
      end

      feed_items
    end
    
    def total_pages(aggregate = false)
      aggregate ? @feederboard_aggregate.total_pages : @feederboard.total_pages
    end
    
    def total_items(aggregate = false)
      aggregate ? @feederboard_aggregate.total_members : @feederboard.total_members
    end
  end
end