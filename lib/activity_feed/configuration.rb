module ActivityFeed
  # Configuration settings for ActivityFeed.
  module Configuration
    # Redis instance.
    attr_accessor :redis

    # Proc that will be called for loading an item from an ORM, e.g. Mongoid. Proc will be called with the ID of the item from the feed.
    attr_accessor :item_loading

    # ActivityFeed namespace for Redis.
    attr_writer :namespace

    # Indicates whether or not aggregation is enabled.
    attr_writer :aggregate

    # Key used in Redis for an individual's aggregate feed.
    attr_writer :aggregate_key

    # Page size to be used when paging through the activity feed.
    attr_writer :page_size

    # Yield self to be able to configure ActivityFeed with block-style configuration.
    #
    # Example:
    #
    #   ActivityFeed.configure do |configuration|
    #     configuration.redis = Redis.new
    #     configuration.namespace = 'activity_feed'
    #     configuration.aggregate = true
    #     configuration.aggregate_key = 'aggregate'
    #     configuration.page_size = 25
    #   end
    def configure
      yield self
    end

    # ActivityFeed namespace for Redis.
    #
    # @return the ActivityFeed namespace or the default of 'activity_feed' if not set.
    def namespace
      @namespace ||= 'activity_feed'
    end

    # Indicates whether or not aggregation is enabled.
    #
    # @return whether or not aggregation is enabled or the default of +true+ if not set.
    def aggregate
      @aggregate ||= true
    end

    # Key used in Redis for an individul's aggregate feed.
    #
    # @return the key used in Redis for an individual's aggregate feed or the default of 'aggregate' if not set.
    def aggregate_key
      @aggregate_key ||= 'aggregate'
    end

    # Default page size.
    # 
    # @return the page size or the default of 25 if not set.
    def page_size
      @page_size ||= 25
    end

    # Page size to be used when paging through the activity feed.
    #
    # @return the page size to be used when paging through the activity feed or the default of 25 if not set.
    def page_size
      @page_size ||= 25
    end
  end
end