require 'activity_feed/version'
require 'activity_feed/item'
require 'activity_feed/feed'

module ActivityFeed
  mattr_accessor :redis
  mattr_accessor :namespace
  mattr_accessor :key
  
  self.namespace = 'activity'
  self.key = 'feed'
end
