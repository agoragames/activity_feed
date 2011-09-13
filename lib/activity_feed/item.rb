require 'mongo_mapper'

module ActivityFeed
  class Item
    include MongoMapper::Document

    key :user_id, Integer, :required => true, :numeric => true
    key :nickname, String
    key :type, String
    key :text, String

    timestamps!

    self.ensure_index(:user_id)

    after_save :update_redis

    private

    def update_redis
      ActivityFeed.redis.zadd("#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{self.user_id}", self.created_at.to_i, self.id)
    end
  end
end