require 'spec_helper'

describe ActivityFeed::Configuration do
  describe '#configure' do
    it 'should have default attributes' do
      ActivityFeed.configure do |configuration|
        configuration.namespace.should eql('activity_feed')
        configuration.aggregate.should be_false
        configuration.aggregate_key.should eql('aggregate')
        configuration.page_size.should eql(25)
      end
    end
  end
end