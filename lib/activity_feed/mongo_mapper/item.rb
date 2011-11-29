require 'mongo_mapper'

module ActivityFeed
  module MongoMapper
    class Item
      include ::MongoMapper::Document    

      key :user_id, Integer, :required => true, :numeric => true
      key :nickname, String
      key :type, String
      key :title, String
      key :text, String
      key :url, String
      key :icon, String
      key :sticky, Boolean

      timestamps!

      self.ensure_index(:user_id)

      after_save :update_redis

      private

      def update_redis
        ActivityFeed.redis.zadd(ActivityFeed.feed_key(self.user_id), self.created_at.to_i, self.id)
      end
    end
  end
end