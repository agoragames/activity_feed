require 'spec_helper'

describe ActivityFeed::Configuration do
  describe '#configure' do
    it 'should have default attributes' do
      ActivityFeed.configure do |configuration|
        configuration.namespace.should == 'activity_feed'
        configuration.aggregate.should be_true
        configuration.aggregate_key.should == 'aggregate'
        configuration.page_size.should== 25
      end
    end
  end
end