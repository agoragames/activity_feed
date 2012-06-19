module ActivityFeed
  module Item
    def update_item(user_id, item_id, timestamp, aggregate = false)
      feederboard = ActivityFeed.feederboard_for(user_id)
      feederboard.rank_member(item_id, timestamp)

      if aggregate
        feederboard = ActivityFeed.feederboard_for(user_id, aggregate)
        feederboard.rank_member(item_id, timestamp)
      end
    end

    def remove_item(user_id, item_id)
      feederboard = ActivityFeed.feederboard_for(user_id)
      feederboard.remove_member(item_id)
      feederboard = ActivityFeed.feederboard_for(user_id, true)
      feederboard.remove_member(item_id)
    end
  end
end