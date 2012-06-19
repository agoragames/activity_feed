module ActivityFeed
  module Item
    # Add or update an item in the activity feed for a given +user_id+.
    #
    # @param user_id [String] User ID.
    # @param item_id [String] Item ID.
    # @param timestamp [int] Timestamp for the item being added or updated.
    # @param aggregate [boolean, false] Whether to add or update the item in the aggregate feed for +user_id+.
    def update_item(user_id, item_id, timestamp, aggregate = false)
      feederboard = ActivityFeed.feederboard_for(user_id)
      feederboard.rank_member(item_id, timestamp)

      if aggregate
        feederboard = ActivityFeed.feederboard_for(user_id, aggregate)
        feederboard.rank_member(item_id, timestamp)
      end
    end

    # Specifically aggregate an item in the activity feed for a given +user_id+. 
    # This is useful if you are going to background the process of populating 
    # a user's activity feed from friend's activities.
    #
    # @param user_id [String] User ID.
    # @param item_id [String] Item ID.
    # @param timestamp [int] Timestamp for the item being added or updated.
    def aggregate_item(user_id, item_id, timestamp)
      feederboard = ActivityFeed.feederboard_for(user_id, true)
      feederboard.rank_member(item_id, timestamp)
    end

    # Remove an item from the activity feed for a given +user_id+. This 
    # will also remove the item from the aggregate activity feed for the
    # user.
    # 
    # @param user_id [String] User ID.
    # @param item_id [String] Item ID.
    def remove_item(user_id, item_id)
      feederboard = ActivityFeed.feederboard_for(user_id)
      feederboard.remove_member(item_id)
      feederboard = ActivityFeed.feederboard_for(user_id, true)
      feederboard.remove_member(item_id)
    end
  end
end