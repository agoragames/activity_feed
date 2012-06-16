require 'mongoid'

module ActivityFeed
  module Mongoid
    class Item
      include ::Mongoid::Document    
      include ::Mongoid::Timestamps

      field :user_id, type: Integer
      validates_presence_of :user_id

      field :nickname, type: String
      field :type, type: String
      field :title, type: String
      field :text, type: String
      field :url, type: String
      field :icon, type: String
      field :sticky, type: Boolean

      index :user_id

      after_save :update_redis

      private

      def update_redis
        ActivityFeed.redis.zadd(ActivityFeed.feed_key(self.user_id), self.created_at.to_i, self.id)
      end
    end
  end
end