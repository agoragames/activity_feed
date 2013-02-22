require 'mongoid'

# If using Mongoid 2.x
# Mongoid.configure do |config|
#   config.master = Mongo::Connection.new.db("activity_feed_gem_test")
# end

# If using Mongoid 3.x
Mongoid.load!("#{File.dirname(__FILE__)}/mongoid.yml", :test)

DatabaseCleaner[:mongoid].strategy = :truncation

module ActivityFeed
  module Mongoid
    class Item
      include ::Mongoid::Document
      include ::Mongoid::Timestamps

      field :user_id, :type => String
      validates_presence_of :user_id

      field :nickname, :type => String
      field :type, :type => String
      field :title, :type => String
      field :text, :type => String
      field :url, :type => String
      field :icon, :type=> String
      field :sticky, :type=> Boolean

      # If using Mongoid 2.x
      # index :user_id

      # If using Mongoid 3.x
      index({ user_id: 1})

      after_save :update_activity_feed

      private

      def update_activity_feed
        ActivityFeed.update_item(self.user_id, self.id, self.created_at.to_i)
      end
    end
  end
end