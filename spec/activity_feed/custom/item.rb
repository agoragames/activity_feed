module ActivityFeed
  module Custom
    class Item
      attr_accessor :user_id
      attr_accessor :nickname
      attr_accessor :type
      attr_accessor :title
      attr_accessor :text
      attr_accessor :url
      attr_accessor :icon
      attr_accessor :sticky

      def initialize(attributes = {})
        @attributes = attributes

        attributes.each do |key,value|
          self.send("#{key}=", value)
        end      
      end
      
      def attributes
        @attributes
      end

      def self.find(item)
        JSON.parse(item)
      end

      def save
        raise 'user_id MUST be defined in the attributes' if user_id.blank?

        ActivityFeed.redis.zadd(ActivityFeed.feed_key(self.user_id), DateTime.now.to_i, @attributes.to_json)
      end
    end
  end
end
