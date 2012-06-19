require 'spec_helper'

describe ActivityFeed do
  describe '#feed_key' do
    it 'should return the correct key for the non-aggregate feed' do
      ActivityFeed.feed_key('david').should == 'activity_feed:david'
    end

    it 'should return the correct key for an aggregate feed' do
      ActivityFeed.feed_key('david', true).should == 'activity_feed:aggregate:david'
    end
  end
end