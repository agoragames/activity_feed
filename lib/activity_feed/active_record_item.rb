module ActivityFeed
  class ActiveRecordItem < ActiveRecord::Base
    set_table_name 'activity_feed_items'
        
    after_save :update_redis

    private

    def update_redis
      ActivityFeed.redis.zadd("#{ActivityFeed.namespace}:#{ActivityFeed.key}:#{self.user_id}", self.created_at.to_i, self.id)
    end    
  end
end