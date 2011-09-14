require 'leaderboard'

module ActivityFeed
  class Feed
    def initialize(user_id)
      @feederboard = Leaderboard.new("#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{user_id}", Leaderboard::DEFAULT_OPTIONS, {:redis_connection => ActivityFeed.redis})
    end
    
    def page(page)
      feed_items = []
      @feederboard.leaders(page).each do |feed_item|
        feed_items << ActivityFeed.load_item(feed_item[:member])
      end

      feed_items
    end
    
    def total_pages
      @feederboard.total_pages
    end
    
    def total_items
      @feederboard.total_members
    end
  end
end