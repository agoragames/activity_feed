module ActivityFeed
  module Utility
    def feed_key(user_id, aggregate = false)
      aggregate ? 
        "#{ActivityFeed.namespace}:#{ActivityFeed.aggregate_key}:#{user_id}" :
        "#{ActivityFeed.namespace}:#{user_id}"
    end
  end
end