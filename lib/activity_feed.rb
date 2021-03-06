require 'activity_feed/configuration'
require 'activity_feed/item'
require 'activity_feed/feed'
require 'activity_feed/utility'
require 'activity_feed/version'

require 'leaderboard'

module ActivityFeed
  extend Configuration
  extend Item
  extend Feed
  extend Utility  
end