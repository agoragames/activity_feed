require 'spec_helper'

describe ActivityFeed::Configuration do
  describe '#configure' do
    it 'should have default attributes' do
      ActivityFeed.configure do |configuration|
        expect(configuration.namespace).to eql('activity_feed')
        expect(configuration.aggregate).to be_falsey
        expect(configuration.aggregate_key).to eql('aggregate')
        expect(configuration.page_size).to eql(25)
      end
    end
  end
end