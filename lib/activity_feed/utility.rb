module ActivityFeed
  module Utility
    def feed_key(user_id, aggregate = false)
      aggregate ? 
        "#{ActivityFeed.namespace}:#{ActivityFeed.aggregate_key}:#{user_id}" :
        "#{ActivityFeed.namespace}:#{user_id}"
    end

    def feederboard_for(user_id, aggregate = false)
      ::Leaderboard.new(feed_key(user_id, aggregate), ::Leaderboard::DEFAULT_OPTIONS, {:redis_connection => ActivityFeed.redis})
    end
  end
end