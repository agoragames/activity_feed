require 'activity_feed/version'
require 'activity_feed/configuration'

module ActivityFeed
  extend Configuration

  def self.feed_key(user_id, aggregate = false)
    aggregate ? 
      "#{ActivityFeed.namespace}:#{ActivityFeed.aggregate_key}:#{user_id}" :
      "#{ActivityFeed.namespace}:#{user_id}"
  end
end