require 'ohm'
require 'ohm/contrib'

module ActivityFeed
  module Ohm
    class Item < ::Ohm::Model
      include ::Ohm::Callbacks
      include ::Ohm::Timestamping
      
      attribute :user_id
      attribute :nickname
      attribute :type
      attribute :title
      attribute :text
      attribute :url
      attribute :icon
      attribute :sticky      
      
      after :save, :update_redis
      
      private

      def update_redis
        ActivityFeed.redis.zadd(ActivityFeed.feed_key(self.user_id), DateTime.parse(self.created_at).to_i, self.id)
      end
    end
  end
end