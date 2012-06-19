module ActivityFeed
  module Utility
    # Feed key for a +user_id+ composed of:
    #
    # Feed: +ActivityFeed.namespace:user_id+
    # Aggregate feed: +ActivityFeed.namespace:ActivityFeed.aggregate_key:user_id+
    # 
    # @return feed key.
    def feed_key(user_id, aggregate = false)
      aggregate ? 
        "#{ActivityFeed.namespace}:#{ActivityFeed.aggregate_key}:#{user_id}" :
        "#{ActivityFeed.namespace}:#{user_id}"
    end

    # Retrieve a reference to the activity feed for a given +user_id+.
    #
    # @param user_id [String] User ID.
    # @param aggregate [boolean, false] Whether to retrieve the aggregate feed for +user_id+ or not.
    #
    # @return reference to the activity feed for a given +user_id+.
    def feederboard_for(user_id, aggregate = false)
      ::Leaderboard.new(feed_key(user_id, aggregate), ::Leaderboard::DEFAULT_OPTIONS, {:redis_connection => ActivityFeed.redis})
    end
  end
end